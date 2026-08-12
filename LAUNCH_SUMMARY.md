# Tubora — Launch Summary
_Date: 2026-06-30_

---

## ✅ Play Store Submission Complete

**App name:** Tubora: SEO Tools, Tags & AI
**Package:** `com.shortseo.short_seo_ai`
**Version:** 1.0.0 (version code 1)
**AAB size:** 27.8 MB
**Track:** Production (full rollout)
**Countries:** 177
**Submitted:** 2026-06-30
**Review time:** 3–7 days

---

## ✅ App Check — Complete

- Play app-signing SHA-256 added to Firebase App Check (2 fingerprints)
- `enforceAppCheck: true` uncommented in all 3 functions:
  - `generateContent`
  - `generateImage`
  - `analyzeSeo`
- Deployed via `firebase deploy --only functions` ✅

---

## ✅ Store Listing — Complete

| Field | Value |
|-------|-------|
| App name | Tubora: SEO Tools, Tags & AI |
| Short description | AI-powered SEO titles, tags & thumbnails for YouTube creators |
| Category | Tools |
| Privacy Policy | https://tubora.online/privacy.html |
| Contact email | geekyprem4@gmail.com |
| Website | https://tubora.online |
| Target audience | 18+ |

---

## ✅ App Content Declarations — Complete

| Declaration | Status |
|-------------|--------|
| Sign-in details | Yes (Email/Password) — test credentials provided |
| Content rating | All Other App Types — completed |
| Target audience | 18 and over, minors restricted |
| Ads | No |
| Financial features | No |
| Health declaration | No |
| Advertising ID | Yes (Firebase SDK) |
| Data Safety | Completed |

### Data Safety — Data collected:
| Data type | Purpose |
|-----------|---------|
| Name | App functionality |
| Email address | App functionality |
| Crash logs | Analytics |
| App interactions | Analytics |
| Device or other IDs | Analytics / Security |

---

## ⏳ Post-Launch Tasks (after Google approves)

1. **Firestore App Check** → Switch from Monitor → **Enforce**
2. **firebase-functions** → Run in `functions/` directory:
   ```
   npm install --save firebase-functions@latest
   ```
3. Replace placeholder `widget_test.dart` with real tests
4. Pro tier → re-enable when ready (update policy + IAP declaration)

---

## 🚀 Launch Day Sequence (completed)

- [x] AAB uploaded to Production
- [x] App-signing SHA-256 → Firebase App Check
- [x] `enforceAppCheck: true` → `firebase deploy --only functions`
- [x] Store listing filled (description, screenshots, icon)
- [x] App content declarations completed
- [x] Data Safety form completed
- [x] 13 changes submitted for review
- [ ] Google review pending (3–7 days)
- [ ] Promote to live once approved
