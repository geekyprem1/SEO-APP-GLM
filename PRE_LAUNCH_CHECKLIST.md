# Tubora — Pre-Play-Store Launch Checklist

_Last updated: 2026-06-30. Tracks what's DONE and what's REMAINING before the
first Play Store production release. Pair this with
[PLAY_CONSOLE_PRIVACY_CHECKLIST.md](PLAY_CONSOLE_PRIVACY_CHECKLIST.md) for the
Data Safety form details._

---

## ✅ DONE (code-complete & verified)

### App quality / stability
- [x] Privacy Policy URL fixed to apex `https://tubora.online/privacy.html` (verified live)
- [x] Analytics + Crashlytics **opt-in consent** flow (first-run gate, Settings toggle, persisted in Hive)
- [x] Safe auth handling — no `credential.user!` force-unwrap; typed failures
- [x] Logger: `PrettyPrinter` off + logs silenced in release; release `debugPrint` guarded
- [x] GoRouter refresh fixed (built once, auth bridged via refreshListenable)
- [x] Dead code / unused deps / assets / files removed
- [x] `flutter analyze` → **0 issues**; `flutter test` → pass
- [x] **Dark theme** enabled (System/Light/Dark in Settings, persisted) + all dark-mode color fixes
- [x] External links work on Android 11+ (manifest `<queries>` for https/mailto)
- [x] **Thumbnail sizes**: long-form 1280×720 (16:9), Shorts 1080×1920 (9:16); backend clamp raised to 1920; Replicate fallback uses aspect_ratio

### Security / infra
- [x] Hive boxes **encrypted at rest** (AES key in secure storage)
- [x] Network security config: no cleartext, system CAs only (HTTPS-only)
- [x] Firestore rules locked (no self-granted plan/quota; server-only writes; delete via function)
- [x] API keys in **Secret Manager** only (OPENROUTER, SILICONFLOW, REPLICATE, YOUTUBE all SET)
- [x] Cloud Functions deployed (auth + rate limit + quota + budget + server-side cache keys)
- [x] Release signing config + guard (refuses to debug-sign a release)
- [x] GDPR account deletion (in-app + email)
- [x] CI: analyze + test + debug build (release signed locally)
- [x] Signed **release AAB builds clean** (`app-release.aab`) + tested on device

---

## ☐ REMAINING (must do before / during launch)

### Critical - Play review login access
1. [ ] Firebase Console -> Authentication -> Sign-in method: enable **Email/Password**, **Anonymous**, and **Google**.
2. [ ] Firebase Console -> Authentication -> Users: create the exact reviewer account that will be entered in Play Console App access. Verify it by logging into the Play-installed build, not a sideloaded APK.
3. [ ] Play Console -> Setup -> App integrity -> App signing: copy both **SHA-1** and **SHA-256** for the **App signing key certificate**.
4. [ ] Firebase Console -> Project settings -> Your apps -> Android app (`com.shortseo.short_seo_ai`): add the Play app-signing SHA-1 and SHA-256. Download the refreshed `google-services.json` and replace `android/app/google-services.json`.
5. [ ] Google Cloud Console -> APIs & Services -> Credentials: if the Firebase Web API key is restricted by Android apps, add package `com.shortseo.short_seo_ai` with the Play app-signing SHA-1 there too.
6. [ ] Google Cloud Console -> OAuth consent screen / Branding: make sure publishing status is **In production** or the reviewer Google account is added as a test user.
7. [ ] Rebuild and upload a new AAB. Install from Play internal testing/production track and verify: email sign-in, Google sign-in, and "Skip - continue as Guest" all open the app.
8. [ ] Play Console -> App content -> App access: provide the verified reviewer email/password and add a note: "Guest access is available from the login screen via Skip - continue as Guest."

### 🔴 Critical — App Check (do in this order, or users get blocked)
1. [ ] Create app in Play Console + upload `app-release.aab` to **Internal testing**
2. [ ] Play Console → Setup → App Integrity → copy **App signing key SHA-256**
3. [ ] Firebase → App Check → **Add another fingerprint** (app-signing SHA) → Save
4. [ ] Uncomment `enforceAppCheck: true` in [functions/src/index.js](functions/src/index.js) (3 places) → `firebase deploy --only functions`
5. [ ] Verify AI features work from the **Play-signed** internal-testing build (NOT the sideload APK)

> Note: the production AAB already has App Check ON (client). Only the *test*
> APK uses `ENABLE_APP_CHECK=false`. Do NOT upload the test APK to Play.

### 🟠 Play Console — store setup
6. [ ] **App content** declarations: Privacy Policy URL, App access (test login creds), Ads = **No**, Content rating questionnaire, Target audience, **Data Safety** form (see privacy checklist)
7. [ ] **Store listing**: app icon 512×512, feature graphic 1024×500, **2+ phone screenshots**, short + full description, category (Tools/Productivity)
8. [ ] Countries/regions + Free pricing
9. [ ] Production → Create release → upload AAB → **Start rollout**

### 🟢 Post-launch / later (not blockers)
- [ ] Firestore App Check: switch from Monitor → Enforce once % verified is healthy
- [ ] Pro tier: re-enable when ready (update policy + IAP declaration + Data Safety)
- [ ] Replace placeholder `widget_test.dart` with real tests
- [ ] Bump `firebase-functions` to latest (deploy showed an outdated-version notice)

---

## 🚀 Launch-day sequence (quick reference)
1. Upload AAB → Internal testing
2. App-signing SHA → App Check
3. Re-enable `enforceAppCheck` → `firebase deploy --only functions`
4. Test AI on internal build
5. Fill App content + Store listing
6. Promote to Production → rollout
7. Wait for Google review (first review can take up to ~7 days)

## ✅ Account note
Developer account is from **2015** (established) → exempt from the 12-tester ×
14-day closed-testing rule. Can publish straight to production.
