# Tubora: App Improvements and Download Growth Findings

Date: 23 October 2026

## Scope and evidence

Reviewed the public Play Store listing and selected files in the local Flutter project. Features found in local code are not necessarily available in the published app. The current screenshot designs were not visually verified. No Play Console acquisition or retention data was available.

Listing: https://play.google.com/store/apps/details?id=com.shortseo.short_seo_ai&hl=en_IN

Observed listing details:

- Name: **Tubora: SEO Tools, Tags & AI**
- Displayed download band: **50+ downloads**
- Last updated: **31 August 2026**
- Description emphasizes titles, descriptions, tags, hashtags and thumbnails.
- Release notes focus on Android compatibility and security-related updates.

## Main recommendation

Position Tubora around helping a creator turn one topic into a complete video content package. Improve the existing workflow and give users a reason to return before adding many more standalone generators.

Suggested promise:

> Apna video topic daalo. Titles, hook, script aur description ek jagah taiyar karo.

The listing should clearly explain why a creator would use Tubora instead of a general-purpose chatbot: remembered channel preferences, a connected workflow, editable outputs and saved projects.

Avoid making tags the main growth promise. YouTube says tags play a limited role, while titles, thumbnails and descriptions matter more for discovery.

Source: https://support.google.com/youtube/answer/146402?hl=en

## Existing capabilities found in the project

The code includes screens or implementation for titles, descriptions, hashtags, thumbnails, hooks, captions, series, content generation, SEO analysis, history and Content Studio. Guest sign-in and an analytics service also exist.

Content Studio already supports generating an all-in-one content package. Improve its visibility and usability rather than treating it as a missing feature. Verify release availability before advertising any capability.

## App improvements, in priority order

| Priority | Improvement | Intended benefit |
|---|---|---|
| P0 | Make Content Studio the primary home action | One topic becomes a complete package without opening many separate tools |
| P0 | Simplify first use to topic, language and generation | Reach the first useful result quickly |
| P0 | Make outputs easy to edit, save and regenerate individually | Fix a weak section without regenerating everything |
| P1 | Add a project workflow: Draft → Ready → Published | Let users continue their work on a later visit |
| P1 | Measure generation success, copy/save actions and return visits | Identify where users receive value and where they drop off |

Suggested primary home action: **Create my next video**.

## Recommended feature additions

| Feature | Proposed behavior | Priority |
|---|---|---|
| Channel profile / brand memory | Save niche, audience, language and tone; reuse them in future generations | First |
| Improve my draft | Accept a user's title or script and provide specific improvements and alternatives | High |
| 7-day content planner | Generate ideas for the saved niche and convert an idea into a script/project | High |
| Thumbnail + title preview | Compare title and thumbnail combinations at mobile viewing size | Medium |
| Own-channel performance insights | Use an authorized YouTube connection to inform suggestions with actual performance | Later |

Strongest initial combination: **Channel Profile + Content Studio + Saved Projects**.

Hindi/Hinglish support should include natural hooks, local examples and the creator's speaking style, rather than translation alone. Treat this as a positioning hypothesis to validate with Indian creators.

## Play Store listing direction

Suggested title to evaluate:

> Tubora: AI Tools for YouTube

Suggested short description:

> Create YouTube titles, scripts, descriptions and thumbnails with AI.

Only advertise scripts and other capabilities once confirmed in the published version.

### Proposed screenshot sequence

Use real app outputs and one clear benefit per screenshot:

1. One topic. Your video content, ready.
2. Find a stronger title
3. Write your opening hook
4. Create in Hindi & English
5. Design your next thumbnail
6. Save your next video idea

This is a proposed sequence, not a verified critique of the current screenshot artwork.

Replace vague or unsupported claims such as “algorithm loves” and “titles that rank” with concrete benefits: editable drafts, language options and fewer repeated steps. Release notes should describe actual shipped improvements.

Test a Hindi localized listing and screenshots. For Play Console experiments, change one asset at a time and wait for sufficient evidence. Low traffic can make experiments slow; a few installs do not establish a winner.

Source: https://support.google.com/googleplay/android-developer/answer/12053285?hl=en&page_id=111073

## Download acquisition recommendations

- **Demo Shorts:** Show a real creator task and actual output, such as three title options for a Hindi cooking video or improving a weak intro.
- **Creator feedback:** Recruit 10–15 small creators to use Tubora for their next upload. Check whether they return without reminders.
- **Relevant creator partnerships:** Test tutorials or workflow demonstrations with a distinct tracking link for each partnership.
- **Website-to-app flow:** Offer a useful free title/hook result, then provide a clear reason to install, such as saving the project in Tubora.
- **Review requests:** Request an honest native review after meaningful use rather than at first launch. Do not reward ratings with credits.

Expand paid promotion after checking that acquired users generate useful outputs and return. These are proposed experiments, not guaranteed download outcomes.

## 30-day action plan

| Period | Work |
|---|---|
| Week 1 | Improve listing copy and screenshot assets; establish install-to-first-result measurement |
| Week 2 | Make Content Studio prominent; improve onboarding and saving |
| Week 3 | Add channel profile; collect hands-on feedback from 10 creators |
| Week 4 | Publish demo content and test small creator campaigns; start a listing experiment if traffic supports it |

## Measurement and unresolved questions

Track this funnel:

**Store visitors → installs → successful generation → copy/save → return after 7 days**

Request the last 28 days of store visitors, acquisitions and returning-user data to determine whether the main constraint is traffic, listing conversion or retention.

The existing `ORGANIC_DOWNLOADS_TODO.md` contains claims such as needing 20–30 ratings to rank and fixed percentage uplifts. Do not treat those as established rules or guaranteed outcomes.

## First implementation priority

Improve the Content Studio experience and listing, then add Channel Profile. Use actual acquisition and retention data to refine the next priorities.
