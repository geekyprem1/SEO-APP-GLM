# Play Console — Privacy & Data Safety Checklist (Tubora)

Generated 2026-06-30. Use this when filling out the Play Console **App content** and
**Data safety** sections. Values below reflect what the app actually does (verified
against the codebase) and what the published Privacy Policy states.

Privacy Policy URL to enter: **https://tubora.online/privacy.html**
(Apex domain — `www.` is NOT served by GitHub Pages. Verify it returns HTTP 200 in a
browser before submitting.)

---

## 1. Privacy Policy (App content → Privacy policy)
- [x] URL points to a live, publicly reachable page (no login wall): `https://tubora.online/privacy.html`
- [x] URL constant in app matches the live URL (`AppConstants.privacyPolicyUrl`)
- [x] Policy names the developer (P Square Developer) and a contact email
- [x] Policy describes data collected, use, sharing, retention, and deletion
- [ ] Open the URL in an incognito browser and confirm it loads (manual)

## 2. Data safety form — Data collection & sharing
Declare the following **collected** data types (all transmitted to Firebase/OpenRouter):

| Category | Data type | Collected | Shared | Purpose | Optional? |
|---|---|---|---|---|---|
| Personal info | Name | Yes | No | Account management | Required (if signed in) |
| Personal info | Email address | Yes | No | Account management | Required (if signed in) |
| Personal info | User IDs | Yes | No | Account management, Analytics | Required |
| App activity | App interactions / usage | Yes | No | Analytics, App functionality | **Optional (consent)** |
| App info & perf | Crash logs | Yes | No | Crash reporting / stability | **Optional (consent)** |
| App info & perf | Diagnostics | Yes | No | Performance / stability | **Optional (consent)** |
| Device/other IDs | Device info / OS version | Yes | No | Compatibility, diagnostics | Optional (consent) |
| App content | User-entered text (prompts/topics/URLs) | Yes | Yes* | App functionality (AI generation) | Required to use feature |

\* Prompts are sent to **OpenRouter** for AI processing — declare as **shared with a
third party for app functionality**, not as sold. Confirm whether Play classifies this
as "shared"; processing-only transfers can be excluded, but OpenRouter is a separate
controller, so declaring it as shared is the safe choice.

### Encryption & deletion (Data safety → Security practices)
- [x] **Data is encrypted in transit** — `usesCleartextTraffic="false"` + network security config; HTTPS only
- [x] **Data encrypted at rest on device** — Hive boxes are AES-encrypted (key in platform secure store)
- [x] **Users can request data deletion** — in-app *Profile → Delete Account* (Cloud Function) + email fallback
- [x] Provide the account-deletion URL/instructions: in-app **Delete Account**, or email geekyprem4@gmail.com

## 3. Consent flow (verify before release)
- [x] Analytics & Crashlytics are **opt-in**: collection stays OFF until the user allows it
  - `FirebaseService.initialize` sets `collectionAllowed = analyticsConsent == true`
  - Undecided (`null`) and declined (`false`) both keep collection disabled
- [x] First-launch consent prompt shown (`ConsentGate` overlay) with a Privacy Policy link
- [x] User choice is **persisted** (Hive `analyticsConsent` key) and re-applied at startup (`main.dart`)
- [x] Choice is **reversible** anytime: Settings → Privacy toggle (`privacyConsentProvider.setConsent`)
- [x] Declining **disables both** Analytics and Crashlytics live (`PrivacyConsent.applyToFirebase`)

## 4. Permissions (App content → declarations)
- [x] `INTERNET`, `ACCESS_NETWORK_STATE` — Firebase + AI calls
- [x] `WRITE_EXTERNAL_STORAGE` capped at `maxSdkVersion=29` — save thumbnails only (no gallery read)
- [x] No sensitive/restricted permissions (GET_ACCOUNTS removed; no READ_MEDIA_IMAGES)
- [x] No `QUERY_ALL_PACKAGES`, location, contacts, camera, or mic

## 5. App content declarations
- [ ] **Ads**: declare **No ads** (policy confirms no third-party advertising)
- [x] **In-app purchases**: declare **No** — Pro tier is **disabled for this release** (billing not live,
      no billing library in the project; `pro_upgrade_dialog` shows a "coming soon" chip, no price).
      Policy's "no IAP/subscriptions" is accurate now. ⚠️ When Pro is resumed, update BOTH the policy
      and this declaration (and the Data safety form if purchase data is collected).
- [ ] **Target audience / content rating**: not for children under 13 (matches policy's Children's Privacy)
- [ ] **Account creation**: app supports account sign-in → provide test credentials / deletion instructions
- [x] **Data deletion**: in-app + email path documented in policy

## 6. Pre-submission manual verification
- [ ] Load `https://tubora.online/privacy.html` (incognito) → 200 OK, content visible
- [ ] Confirm `https://www.tubora.online/privacy.html` is NOT what's submitted anywhere
- [ ] Fresh install → consent prompt appears; "No thanks" keeps analytics off (verify in Firebase DebugView)
- [ ] Toggle Settings → Privacy off/on and confirm collection state follows
- [ ] Profile → Delete Account removes the account and signs out

---

### ⚠️ Open items
1. **Pro tier — disabled for now, resuming later.** No billing is live and no billing
   library is bundled, so "No ads / No IAP" is correct for this submission. When you
   re-enable Pro: update the Privacy Policy, the Play IAP declaration, and the Data
   safety form (if you collect purchase history / payment-related data).
2. **DNS** — apex `https://tubora.online/privacy.html` confirmed loading. ✅
