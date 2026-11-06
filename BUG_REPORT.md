# Tubora App — Deep Bug Report

> Date: 2026-09-16
> Scope: 163 Dart files (`lib/`) + `functions/` + `firestore.rules` + Android/iOS manifests
> Static analysis: `flutter analyze --no-pub` → **No issues found** (syntax/lints clean, saare bugs runtime/logic wale hain)
>
> **Fix progress (2026-09-21): 45/46 — ✅ C1–C7 ✅ H1–H13 ✅ M1–M12 (M11 partial: cancel-token wiring pending) ✅ L1–L14 (L11 pending: hive_ce migration)**
>
> Verification: `flutter analyze --no-pub` → **No issues found**; `flutter test` → **All tests passed**.

---

## CRITICAL (app crash / data loss / bill fat sakta hai)

### C1. `HistoryItem.fromJson` crash — 1 corrupt entry = red screen
**Status:** ✅ FIXED — 2026-09-21 (safe casts + `tryParse` fallback + detail screen `try/catch` with `ErrorState`)
- **File:** `lib/features/history/models/history_item.dart:55-63`
- **Evidence:**
  ```dart
  id = json['id'] as String,
  createdAt = DateTime.parse(json['createdAt'] as String)
  ```
- **Impact:** Missing key / null / galat date → build ke andar throw. Detail screen me try/catch nahi, ek corrupt Hive entry poori detail view brick kar deti hai.
- **Fix:** `as String? ?? ''`, `DateTime.tryParse(...) ?? DateTime.now()`, detail builder ko try/catch me lapet ke `ErrorState` dikhao.

### C2. Saare `Generated*.fromJson` me same unsafe pattern
**Status:** ✅ FIXED — 2026-09-21 (all listed models now parse defensively, same as `fromAiJson`)
- **Files:** `hook/models/generated_hook.dart:52-57`, `viral_ideas/models/viral_ideas.dart:48-53`, `trending/models/trending_topics.dart:52-59`, `title/models/generated_title.dart:51-55`, `hashtags/models/generated_hashtag.dart:43-46`, `description/models/generated_description.dart:41-44`, `content/models/generated_content.dart:49-54`, `seo/models/seo_analysis.dart:90-103`, `thumbnail/models/generated_thumbnail.dart:64-69`, `captions/models/generated_captions.dart:78-84`, `chapters/models/generated_chapters.dart:88-96`, `series/models/generated_series.dart:80-86`, `cta/models/generated_cta.dart:47-51`, `competitor/models/generated_competitor_titles.dart:47-51`, `content_studio/models/content_package.dart:159,173`
- **Impact:** AI output thoda bhi alag aaya ya purani history kholi to `TypeError` / `FormatException` crash. `content` sabse worst — `fromAiJson` tolerant hai, `fromJson` strict hai.
- **Fix:** Har `fromJson` ko `fromAiJson` jitna defensive banao (`as String? ?? ''`, `tryParse ?? DateTime.now()`).

### C3. `captions/chapters/series` — `fromJson` vs `fromAiJson` format drift
**Status:** ✅ FIXED — 2026-09-21 (`fromJson` ab `fromAiJson` wali String/Map branching mirror karta hai)
- **Files:** `captions/models/generated_captions.dart:81-82`, `chapters/models/generated_chapters.dart:92-93`, `series/models/generated_series.dart:83-84`
- **Evidence:** `fromAiJson` me `if (e is String)` allowed hai, `fromJson` me `e as Map` assume kiya hai.
- **Impact:** Stored JSON ka format thoda badla → `TypeError` crash.
- **Fix:** `fromJson` me bhi `fromAiJson` wali branching mirror karo.

### C4. Hive key corrupt hua to app kabhi khulegi hi nahi (startup crash loop)
**Status:** ✅ FIXED — 2026-09-21 (decode/migration guarded, fresh key mint on corrupt data, `openEncrypted` recreates box, keychain read retry)
- **File:** `lib/core/storage/hive_encryption.dart:33-46,58-82`
- **Evidence:** `base64Url.decode(existing)` me try/catch nahi. `migrateIfNeeded` me `deleteBoxFromDisk` ke baad crash hua to data gaya. iOS `first_unlock` pre-unlock pe fail ho sakta hai.
- **Impact:** Reinstall/restore (secure-storage wipe + Hive files bache) ya corrupt key → `main()` me hi exception, app kabhi start nahi hogi.
- **Fix:** decode/cipher/open ko try/catch karke box recreate + Crashlytics log. Migration me backup/flag journaling, keychain-lock retry.

### C5. Functions me budget/rate-limit race — quota bypass, bill risk
**Status:** ✅ FIXED — 2026-09-21 (rate limit ab transaction me; budget pre-reserve `reserveBudget` + `releaseBudget` refund, sab transaction-based)
- **Files:** `functions/src/utils.js:88-107` (rate limit check-then-set), `functions/src/utils.js:184-214` + `functions/src/index.js:99-103,190-194` (budget check vs `addCost` TOCTOU)
- **Evidence:** `await ref.get()` → check → `await ref.set(...)`, koi transaction nahi. `checkBudget` read karta hai, `addCost` AI success ke baad increment karta hai — parallel instances sab pass kar jayenge.
- **Impact:** Burst traffic me rate-limit + budget gate dono bypass → OpenRouter/Replicate ka unbounded spend.
- **Fix:** Transaction / compare-and-set, ya pre-increment + refund pattern.

### C6. `analyzeSeo` me quota/budget/cache hi nahi
**Status:** ✅ FIXED — 2026-09-21 (per-user `seoMetadata` daily quota + budget kill-switch gate + uid-namespaced cache; note: reserve 0$ nahi kyunki YouTube API free hai, quota hi control hai)
- **File:** `functions/src/index.js:264-318`
- **Evidence:** Sirf `checkRateLimit(uid,'seo')` hai, `checkQuota`/`checkBudget` nahi (text/image paths me hai).
- **Impact:** Koi bhi logged-in user YouTube Data API quota uda sakta hai → Google quota exhaustion / DoS, budget kill-switch bypass.
- **Fix:** SEO path me bhi quota + budget + cache lagao.

### C7. Cloud Functions image service force-cast crash
**Status:** ✅ FIXED — 2026-09-21 (`is String && isNotEmpty` guard, warna `ApiException`)
- **File:** `lib/core/services/ai/cloud_functions_image_service.dart:61`
- **Evidence:** `imageUrl: data['imageUrl'] as String`
- **Impact:** Error-shape / null / warmup response → `TypeError` crash, quota/budget error mapping bypass.
- **Fix:** `is String && isNotEmpty` check, warna `ApiException` throw karo.

---

## HIGH

### H1. Auth + Router double authority — flicker / redirect loop
**Status:** ✅ FIXED — 2026-09-21 (sign-in actions ka apna `authActionProvider`; session state sirf auth stream se; splash ab passive; router hi single routing authority)
- **Files:** `lib/features/auth/providers/auth_provider.dart:31,42,53,64`, `lib/core/router/app_router.dart:57-59`, `lib/features/auth/screens/splash_screen.dart:27-36,63-70`
- **Evidence:** Har `signIn*` global `AsyncLoading` set karta hai → router `/login` se `/splash` pe dhakel deta hai. Splash ka 3-sec failsafe beech me `_goLogin()` maar deta hai. `ref.listen` `build()` ke andar hai → har rebuild pe naya subscription + post-frame callback.
- **Impact:** Login me flicker, slow auth pe Login flash phir Home, competing `go()` calls, error state ka message lost.
- **Fix:** Sign-in action ke liye alag state rakho (global loading mat set karo). Routing single source (router only), splash passive. `ref.listen` → `initState` / `ref.listenManual`.

### H2. Auth stream subscription leak
**Status:** ✅ FIXED — 2026-09-21 (`StreamSubscription` field + `dispose()` me cancel)
- **File:** `lib/features/auth/providers/auth_provider.dart:13-24`
- **Evidence:** `_repository.authStateChanges().listen(...)` bina `StreamSubscription` field / `dispose()` ke.
- **Impact:** Provider recreate (tests, logout/login, hot reload) pe leak + duplicate `notifyListeners` → router thrash.
- **Fix:** Subscription store karke `dispose()` me cancel, ya `ref.onDispose`.

### H3. Deep-link force-unwrap crash
**Status:** ✅ FIXED — 2026-09-21 (null/empty id pe `_RouteNotFoundScreen`, aur errorBuilder bhi same screen use karta hai)
- **File:** `lib/core/router/app_router.dart:171`
- **Evidence:** `id: state.pathParameters['id']!`
- **Impact:** `/history/` ya malformed deep link → `Null check` crash, `errorBuilder` tak kabhi pahunchega nahi.
- **Fix:** Null/empty check karke error/not-found screen.

### H4. Auth success + Firestore fail = split-brain session
**Status:** ✅ FIXED — 2026-09-21 (`_ensureUserDoc` ab best-effort (log + continue), transaction + `merge:true` se race aur plan-clobber dono safe)
- **File:** `lib/features/auth/repository/auth_repository.dart:51-60,128-145`
- **Evidence:** `_auth.signIn*` success ke baad `_ensureUserDoc` (get→set/update) throw karta hai → notifier `AsyncError`, lekin Firebase stream `user` emit karegi.
- **Impact:** Router login↔splash↔home oscillate, user signed-out dikhega lekin token hai.
- **Fix:** Profile-write ko best-effort banao (log + continue), `set(merge:true)` / transaction use karo.

### H5. Prompt injection — saare prompt builders me
**Status:** ✅ FIXED — 2026-09-21 (naya `PromptUtils`: quote/newline strip, length clamp, empty pe `ValidationException`, har builder me "treat as untrusted data" instruction; SEO tags ab 300 chars pe bounded)
- **Files:** `title/repository/title_prompt_builder.dart:23`, `hook/repository/hook_prompt_builder.dart:23`, `viral_ideas/repository/viral_ideas_prompt_builder.dart:17`, `content_studio/repository/content_studio_prompt_builder.dart:35`, `captions/repository/captions_prompt_builder.dart:23`, `chapters/repository/chapters_prompt_builder.dart:23`, `cta/repository/cta_prompt_builder.dart:21`, `series/repository/series_prompt_builder.dart:22`, `thumbnail/repository/thumbnail_prompt_builder.dart:31`, `competitor/repository/competitor_prompt_builder.dart:21-22`, `seo/repository/seo_prompt_builder.dart:22-40`
- **Evidence:** Raw interpolation — `about "$topic"`, `Topic: "$topic"`, `"""$sourceTitle"""`. Builder level pe koi escaping / sanitization / length clamp nahi. Repositories UI validators bypass karke call ho sakte hain. SEO me `Tags: $tags` unbounded hai (description 500 pe truncate hota hai, tags nahi).
- **Impact:** User JSON instruction tod sakta hai (`" . Ignore previous...`), quota waste, system-prompt style leak.
- **Fix:** `"`, `"""`, newline escape/sanitize, builder me max-chars enforce, empty-topic pe `ValidationException`, user content ko delimited block + "treat as untrusted data" instruction.

### H6. AI callable me timeout + unsafe casts
**Status:** ✅ FIXED — 2026-09-21 (`.timeout(aiTimeoutSeconds)` → `TimeoutFailure`, `is Map` guards, `num?` coercion)
- **File:** `lib/core/services/ai/cloud_functions_ai_service.dart:46,64-68`
- **Evidence:** `jsonDecode(jsonEncode(response.data)) as Map<String,dynamic>` (null/List pe fail), `data['json'] as Map?` (server List bhej de to fail), `callable.call` pe `.timeout()` nahi. `AppConstants.aiTimeoutSeconds` yahan enforce hi nahi hota.
- **Impact:** Malformed AI JSON → hard crash. Slow function → infinite hang.
- **Fix:** `is Map` guards + `tryParse`, `.timeout(Duration(seconds: AppConstants.aiTimeoutSeconds))` → `TimeoutFailure`.

### H7. YouTube payload force-casts
**Status:** ✅ FIXED — 2026-09-21 (`_responseMap`/`_mapOrNull` guards, `whereType<Map>`, empty `videoId`/`channelId` pe NotFound `ApiException`)
- **File:** `lib/core/services/youtube/cloud_functions_youtube_service.dart:34,51,74,91,109,121`
- **Evidence:** `data['video'] as Map`, `data['channel'] as ...`, `e as Map`, `json['videoId'] as String`. Server empty item (`videoId:''`) bhejta hai jo valid maan liya jata hai.
- **Impact:** Missing/empty search item ya error body → `TypeError` crash.
- **Fix:** Null/type guards, `whereType<Map>`, `videoId is String && isNotEmpty` validate, warna `ApiException`. `JsonUtils.stringList` wala pattern follow karo.

### H8. Quota copy drift — 3 alag numbers, client enforcement nahi
**Status:** ✅ FIXED — 2026-09-21 (client ke fake `dailyLimit` numbers hata diye — single source of truth ab server `PLAN_LIMITS`; copy soft: "daily limits reset each day")
- **Files:** `lib/core/services/ai/models.dart:6-20`, `lib/features/profile/screens/profile_screen.dart:134`, `lib/features/pro/widgets/pro_upgrade_dialog.dart:37-42`
- **Evidence:** `AiFeature(title,20)/(content,10)/(thumbnail,3)` vs Profile "1 generation per feature daily" vs Dialog "50 generations per feature daily".
- **Impact:** User confuse, support tickets. Client request se pehle plan check hi nahi karta.
- **Fix:** Limits ka single source of truth. Billing live hone tak soft copy ("resets daily").

### H9. Pro user offline/error pe Free dikhega
**Status:** ✅ FIXED — 2026-09-21 (`valueOrNull` guessing nahi; loading/error pe neutral "Checking your plan…", upsell chhupa; free default sirf signed-out pe)
- **Files:** `lib/shared/models/user_plan.dart:31-41`, `lib/features/profile/screens/profile_screen.dart:22`, `lib/features/home/widgets/plan_strip.dart:16`
- **Evidence:** `userPlanProvider` me error handling nahi, consumers `valueOrNull ?? UserPlan.free` karte hain.
- **Impact:** Offline / permission error pe paying Pro ko "Upgrade" upsell dikhega.
- **Fix:** loading/error alag handle karo (skeleton, error pe upgrade chhupao), sirf signed-out pe free default.

### H10. `SeoAnalysis` int/double mismatch + unclamped score
**Status:** ✅ FIXED — 2026-09-21 (`num?` coercion + `.clamp(0,100)` model me, gauge bhi clamped)
- **Files:** `lib/features/seo/models/seo_analysis.dart:62-65,101`, `lib/features/seo/screens/seo_analysis_screen.dart:321`
- **Evidence:** `fromAiJson` me `num?.toInt()` hai, `fromJson` me `as int?` (AI `75.5` / `"75"` bhej de to throw). Gauge `score/100` 0.0-1.0 assume karta hai.
- **Impact:** Crash ya `CircularProgressIndicator` overflow/assert.
- **Fix:** `(json['score'] as num?)?.toInt().clamp(0,100) ?? 0`. YouTube counts (`viewCount` etc.) bhi `as int?` ki jagah `num?` / `int.tryParse` se coerce karo.

### H11. Firestore rules — field allowlist nahi (profile spoofing)
**Status:** ✅ FIXED — 2026-09-21 (`hasOnly` allowlist create/update dono pe, `uid == userId` validate, create pe `plan == 'free'` required, unknown keys deny)
- **File:** `firestore.rules:8-35`
- **Evidence:** `create` sirf `plan/status/lifetime` block karta hai, `update` sirf un 3 keys ka diff. `admin/role/email/uid/isPro` jaisi fields writable hain.
- **Impact:** Client `admin:true` jaisi fields plant kar sakta hai. Agar backend/admin console Firestore ko custom claims se zyada trust kare to escalation.
- **Fix:** Mutable fields allowlist (`displayName, photoUrl, ...`), `request.resource.data.uid == userId` validate, unknown keys deny.

### H12. iOS release-blockers
**Status:** ✅ FIXED — 2026-09-21 (`NSPhotoLibraryAddUsageDescription` + `ITSAppUsesNonExemptEncryption` plist me, `ios/Runner/PrivacyInfo.xcprivacy` add + pbxproj Resources phase me register)
- **Files:** `ios/Runner/Info.plist`, `lib/core/services/image_download_service.dart:43`
- **Evidence:** `NSPhotoLibraryAddUsageDescription` nahi (Gal Photos me likhta hai), `PrivacyInfo.xcprivacy` nahi, `ITSAppUsesNonExemptEncryption` nahi.
- **Impact:** iOS 14+ pe save pe crash / App Store rejection (`ITMS-91053`).
- **Fix:** Usage description + privacy manifest (`NSPrivacyAccessedAPITypes` + collected data) + encryption flag add karo.

### H13. Temp thumbnails kabhi delete nahi hote
**Status:** ✅ FIXED — 2026-09-21 (empty URL guard, unique `Uuid` filename, `finally` me temp delete)
- **File:** `lib/core/services/image_download_service.dart:22-48`
- **Evidence:** `getTemporaryDirectory()/thumbnail_<ms>.png` → `Gal.putImage` → return, `finally { delete() }` nahi. Empty `imageUrl` ka early-return nahi. `millisecondsSinceEpoch` rapid double-tap pe collide kar sakta hai.
- **Impact:** `cacheDir` me unbounded PNG growth, Play "excessive storage" complaints.
- **Fix:** try/finally me temp delete, unique filename (`Uuid`), empty URL guard.

---

## MEDIUM

### M1. Copy bina await + jhootha "Copied" (7 screens)
**Status:** ✅ FIXED — 2026-09-21 (`UiUtils.copyToClipboard` ab await + try/catch karta hai; 7 screens usi ko use karte hain, error pe error snackbar)
- **Files:** `hook/screens/hook_generator_screen.dart:71-74`, `series/screens/series_generator_screen.dart:71-74`, `competitor/screens/competitor_rewriter_screen.dart:71-74`, `cta/screens/cta_generator_screen.dart:70-73`, `title/screens/title_generator_screen.dart:75-78`, `chapters/screens/chapters_generator_screen.dart:85-88`, `captions/screens/captions_generator_screen.dart:77-80`
- **Fix:** `await` + try/catch → error snackbar. `ResultActionsBar` pattern centralize karo.

### M2. Empty string ka share/copy
**Status:** ✅ FIXED — 2026-09-21 (`ResultActionsBar` blank text pe Copy/Share disable karta hai; editor ke `_copyAll/_shareAll` guarded)
- **Files:** `history/screens/history_detail_screen.dart:354-375`, `content_studio/widgets/content_package_editor.dart:96-109`
- **Evidence:** `imageUrl = data['imageUrl'] as String? ?? ''` phir bhi `ResultActionsBar(text: imageUrl)`. Sab fields clear karke `_copyAll/_shareAll` empty text share karta hai.
- **Fix:** `text.trim().isEmpty` pe actions hide/disable + guard message.

### M3. Stale `_lastResult` — error ke baad purana data
**Status:** ✅ FIXED — 2026-09-21 (error branch me `_lastResult`/`_last` clear — stale share/save ab possible nahi, all 13 providers)
- **Files:** Saare `providers/*_provider.dart` (`hook:15-38`, `title:21-42`, `viral_ideas:14-31`, `trending:14-30`, `seo:14-30`, `thumbnail:14-39`, `content:14-30`, `captions:16-32`, `chapters:16-32`, `cta:14-30`, `competitor:15-29`, `series:15-28`, `content_studio:22-46`)
- **Evidence:** `generate()` pe `state=loading`, error pe `state=error` lekin `_lastResult` purane success pe. `reset()` hai lekin koi screen dispose/init pe call nahi karti.
- **Fix:** `generate()` start / error pe `_lastResult` clear, ya `initState`/`dispose` me `reset()`. Share text `AsyncValue` se derive karo, cached field se nahi.

### M4. `ContentGeneratorScreen` hook-empty result ko failure dikhata hai
**Status:** ✅ FIXED — 2026-09-21 (hook empty ho to first non-empty section (mainContent → cta) dikhta hai)
- **File:** `lib/features/content/screens/content_generator_screen.dart:129-144`
- **Evidence:** `state: contentState.whenData((data) => data.hook)`, repo (`content_repository.dart:46`) `hook==""` allow karta hai agar `mainContent` hai.
- **Fix:** First non-empty section / `shareText` fallback dikhao.

### M5. `ContentPackageEditor` same-id update pe stale
**Status:** ✅ FIXED — 2026-09-21 (`didUpdateWidget` me controllers sync — naya package aane pe stale text nahi)
- **File:** `lib/features/content_studio/widgets/content_package_editor.dart:52-64`
- **Evidence:** `late final` controllers `initState` se, `ValueKey(package.id)` dono callers me, `didUpdateWidget` nahi.
- **Fix:** `didUpdateWidget` me controllers refresh, ya revision-unique key.

### M6. History delete/clear — no confirm, no undo, no error handling
**Status:** ✅ FIXED — 2026-09-21 (single-delete pe bhi confirm dialog, Undo snackbar + repository re-add, try/catch + error snackbar, `historyItemByIdProvider` invalidate; clear-all ka confirm pehle se tha)
- **Files:** `history/providers/history_provider.dart:28-37`, `history/screens/history_screen.dart:50-59`, `settings/screens/settings_screen.dart:41-46`
- **Evidence:** `delete/clearAll` ke baad seedha `_load()`, try/catch nahi. Confirm dialog nahi, Undo nahi. `historyItemByIdProvider(id)` delete ke baad cached rehta hai → ghost detail.
- **Fix:** Confirm + Snackbar Undo buffer, `ref.invalidate(historyItemByIdProvider(id))`, try/catch + error snackbar.

### M7. Analytics/crash consent race + logout leak
**Status:** ✅ FIXED — 2026-09-21 (Dart-layer `isEnabled` guard dono services me (live consent check), sign-out pe analytics + crashlytics dono ka user id clear)
- **Files:** `lib/core/services/analytics_service.dart:18-29`, `lib/core/services/crashlytics_service.dart:18-30`, `lib/app.dart:21-25`, `lib/core/services/firebase_service.dart:41,81`
- **Evidence:** Dart side me bina consent-guard ke `logEvent` / `setUserId(uid)`. Correctness sirf SDK flag pe dependent. Crashlytics `''` se clear hota hai, logout pe clear ka caller nahi.
- **Fix:** `privacyConsentProvider` / `isEnabled` guard, consent-revoke/logout pe `setUserId(null)` + identifier reset.

### M8. `AppDropdown` value-not-in-items crash risk
**Status:** ✅ FIXED — 2026-09-21 (safe value fallback + empty-catalog placeholder, disabled)
- **Files:** Saare generator screens (e.g. `content_studio_screen.dart:155-163`)
- **Evidence:** Catalog empty hua ya default `_duration` list me nahi → Flutter throw "There should be exactly one item with [value]".
- **Fix:** `value = options.contains(v) ? v : options.first` + empty-list placeholder.

### M9. `CachedNetworkImage` bina sizing/placeholder
**Status:** ✅ FIXED — 2026-09-21 (`memCacheWidth` + `cacheKey` + empty-URL guard teeno sites pe)
- **Files:** `seo/screens/seo_analysis_screen.dart:178-184`, `history/screens/history_detail_screen.dart:360-372`, `thumbnail/screens/thumbnail_generator_screen.dart:235-246`
- **Evidence:** `memCacheWidth` / `cacheKey` / `placeholder` missing (thumbnail me placeholder hai, baaki nahi). Empty-string URL pe bhi request.
- **Fix:** `memCacheWidth: 800/1200`, `cacheKey: imageUrl`, `errorWidget`, `imageUrl.isEmpty` guard.

### M10. Shimmer dark-mode + list jank
**Status:** ✅ FIXED — 2026-09-21 (theme-aware colors, `RepaintBoundary`, fixed-count Column instead of nested shrinkWrap list, single container-level fade)
- **Files:** `lib/core/widgets/common/shimmer_loading.dart:25-28,50-62`, `generated_list_result.dart:64,118`, `generated_text_result.dart:50,90`
- **Evidence:** Hardcoded light-only colors (`primarySoft/heroWash`), `ShrinkWrap + NeverScrollable` parent scroll me full layout, har row pe `.animate().fadeIn()`.
- **Fix:** Theme-aware colors, fixed-count skeleton, container-level animation, `RepaintBoundary`.

### M11. Dio client — no retry/cancel/dispose, PII logs
**Status:** ✅ FIXED (partial) — 2026-09-21 (bounded GET-only retry interceptor, logs se request/response body hata di, `DioClient.close()` add; CancelToken wiring UI-level cancellation ke saath alag kaam hai)
- **File:** `lib/core/network/dio_client.dart:15-49`
- **Evidence:** Sirf timeouts + debug `LogInterceptor(requestBody:true)`. Retry/cancel-token wiring nahi, singleton `close()` kabhi nahi.
- **Fix:** Idempotent GET pe bounded retry, widgets se `CancelToken` propagate, `close()` on detach, logs redact.

### M12. Misc security/privacy hygiene
**Status:** ✅ FIXED — 2026-09-21 (deleteMyAccount fail ab propagate hota hai + AppCheck/rate-limit, revoke sirf admin claims hatata hai (baaki claims safe), youtube errors ab typed `HttpsError`, admin callables pe AppCheck, dio logs se body gayab)
- `functions/src/admin.js:21-31` — `deleteMyAccount` Auth failure swallow karke `ok:true`. Fix: errors propagate, re-auth require.
- `functions/src/admin.js:58` — revoke pe `setCustomUserClaims(uid,null)` saare claims wipe. Fix: sirf `admin/role` hatao.
- `functions/src/youtube.js` — generic `Error` → client ko `internal` milta hai. Fix: `HttpsError('invalid-argument'/'not-found')`, `!videoId` filter.
- `functions/src/admin.js` — sensitive callables me AppCheck + rate-limit nahi. Fix: `enforceAppCheck:true` + limit.
- `lib/core/network/dio_client.dart:35-46` — debug body logs me YouTube URLs. Fix: `requestBody:false` image URLs ke liye.

---

## LOW

- ✅ **L1.** `_formKey.currentState!` 14 screens me (`hook:49`, `title:51`, ...). Fix: `(_formKey.currentState?.validate() ?? false)`. — FIXED 2026-09-21 (saare 13 screens me safe validate).
- ✅ **L2.** `ErrorHandler` socket match fragile (`error_handler.dart:184-188` — case-sensitive `contains('Socket')`). Fix: `is SocketException` + lowercase match. — FIXED 2026-09-21 (lowercase match + host-lookup/network-unreachable patterns; dart:io import web build todta, isliye string match rakha).
- ✅ **L3.** Google sign-out failure swallow (`auth_repository.dart:118-120` — `catch (_){}`). Fix: Crashlytics log. — FIXED 2026-09-21 (`_errorHandler.convert` se report hota hai, silently nahi).
- ✅ **L4.** `success_reveal.dart:17-25` — field-initializer `AnimationController` + har reveal pe haptic, reduced-motion check nahi. — FIXED 2026-09-21 (controller `initState` me, `MediaQuery.disableAnimations` pe animation + haptic skip).
- ✅ **L5.** `Settings._launchUrl` (`settings_screen.dart:49-56`) — `Uri.parse` try ke bahar, `mailto:` unencoded. Fix: `Uri.tryParse` + `Uri(scheme:'mailto',...)`. — FIXED 2026-09-21.
- ✅ **L6.** `share_plus` iPad popover crash (`share_service.dart:13` — `sharePositionOrigin` nahi). Fix: RenderBox origin pass karo. — FIXED 2026-09-21 (`ShareService.share(origin:)` + `UiUtils.shareOrigin`).
- ✅ **L7.** Login autofill missing (`login_screen.dart:111-135`, `app_text_field.dart`) — `autofillHints`, `AutofillGroup`, `enableSuggestions:false` nahi. — FIXED 2026-09-21 (`AutofillHints.email/password` + `AutofillGroup`, password pe suggestions off).
- ✅ **L8.** Version/brand drift — `app_constants.dart` (`1.0.0+1`) vs `pubspec.yaml` (`1.0.3+4`), `web/manifest.json` + `index.html` me `short_seo_ai` placeholder. — FIXED 2026-09-21 (version 1.0.3+4 sync, web pe Tubora branding).
- ✅ **L9.** No pagination — `history_repository.dart:34-38` poora box sort karke load. Scale pe jank/OOM. Cap + lazy paging. — FIXED 2026-09-21 (`getPage` + provider window (20/page) + screen pe "Load more").
- ✅ **L10.** `google_fonts` runtime fetch — bundled font nahi, first-paint block + offline FOUT. `Inter` bundle karo ya `allowRuntimeFetching=false`. — FIXED 2026-09-21 (Inter 400–800 TTFs `assets/fonts/` me bundle + pubspec font family + `allowRuntimeFetching=false`).
- ⏳ **L11.** `hive` abandoned (2023 se update nahi) — `hive_ce` migration plan karo. **NOTE (2026-09-21):** jaan-boojh kar is pass me nahi kiya — dependency swap + `hive_generator`/adapters regeneration + `hive_flutter`→`hive_ce_flutter` import churn chahiye, aur data-migration testing device pe honi chahiye. Alag task me karo (see "Next up" section).
- ✅ **L12.** `seo_analysis_screen.dart:114` — `ref.read(selectedFormatProvider)` build me, tab switch pe stale. Fix: `ref.watch`. — FIXED 2026-09-21 (SEO + thumbnail build paths me `watch`).
- ✅ **L13.** Validators minor — `extractVideoId` path case-sensitive (`youtube.com/shorts/`), uppercase `SHORTS` fail. Host/path lowercase karke normalize karo. — FIXED 2026-09-21 (Dart + Cloud Functions dono me case-insensitive match, ID ka case preserve).
- ✅ **L14.** Contact personal Gmail (`app_constants.dart:39`) — `support@tubora.online` + in-app form. — FIXED 2026-09-21 (email `support@tubora.online`; in-app form optional future).

---

## Suggested fix order

1. **Crash wale pehle** — C1–C4, C7, H3 (history `fromJson`, Hive, force-casts, deep-link). ✅ DONE
2. **Paisa wale** — C5, C6 (Functions quota/budget race). ✅ DONE
3. **Auth/Router loop** — H1, H2, H4. ✅ DONE
4. **Store-blockers** — H12 (iOS privacy), M7 (consent). ✅ DONE
5. **UX/baki** — M1–M6, M8–M11, L1–L14. ✅ DONE

---

## Next up (2026-09-21)

1. **Deploy karo** — C5/C6/H11/M12 ke fixes server-side hain:
   - `firebase deploy --only functions` (rate-limit transaction, budget reserve/refund, SEO quota+cache, admin/youtube hardening)
   - `firebase deploy --only firestore:rules` (profile field allowlist)
2. **L11** — `hive` → `hive_ce` migration: dependency swap + `hive_generator` adapters regenerate + on-device data-migration test.
3. **M11 (rest)** — `CancelToken` ko widgets se propagate karo taaki screen dispose pe in-flight download abort ho.
4. **iOS build ek baar verify karo** — `PrivacyInfo.xcprivacy` Xcode project me register ho chuka hai; archive build se confirm karo ki bundle me included hai.
5. **Manual smoke test** — login/logout + Pro plan display, history delete/undo, copy/share edge cases, thumbnail save-to-gallery, dark-mode shimmer.
