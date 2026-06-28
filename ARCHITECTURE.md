# ShortSEO AI — Technical Blueprint (MVP v1.0)

> Status: **APPROVED — Phase 1 Implementation In Progress**
> Role: Senior Software Architect
> Scope: Architecture finalized; implementation underway feature-by-feature.

---

## 0. Executive Summary

ShortSEO AI is a Flutter MVP that helps YouTube Shorts creators generate SEO
content (titles, hashtags, descriptions, scripts, ideas, thumbnails, SEO
analysis) using AI.

The architecture is **feature-first Clean Architecture** with strict layer
separation, a single reusable AI service behind an abstraction, Riverpod for
state, GoRouter for navigation, Hive for local persistence, and Firebase for
auth/analytics/crashlytics/firestore.

**Final Tech Stack:**
- **Frontend:** Flutter (latest stable), Riverpod, GoRouter, Dio, Hive, Material 3
- **Backend:** Firebase Authentication, Cloud Functions, Firestore, Firebase Storage, Analytics, Crashlytics
- **AI:** OpenRouter (single gateway) — default model **Gemini 2.5 Flash**
- **Image:** Replicate — default model **FLUX.1 Schnell**
- **YouTube:** YouTube Data API v3 (metadata, channels, search, SEO analysis)

**Architecture Rules (non-negotiable):**
1. No API keys inside Flutter. All external APIs accessed through Cloud Functions.
2. Every service has an interface + concrete implementation.
3. App remains modular, scalable, production-ready.

The design is **future-ready**: Premium, AdMob, RevenueCat, cloud history,
multi-language, and advanced analytics can be added later without refactoring.

---

## 1. PRD Review — Resolved Decisions

All previously identified gaps are now resolved with final decisions:

| # | Issue | Final Resolution |
|---|-------|------------------|
| 1 | OpenRouter API key exposure | ✅ All AI calls through Cloud Functions. Key server-side only. |
| 2 | Thumbnail provider unspecified | ✅ **Replicate — FLUX.1 Schnell** via Cloud Functions. |
| 3 | SEO Analysis data source | ✅ **YouTube Data API v3** wrapped in `YouTubeService` (via Cloud Functions). |
| 4 | Firestore usage undefined | ✅ `users/{uid}`, `users/{uid}/usage/{date}`, `config/daily_budget`, `logs/{id}`. |
| 5 | No cost control | ✅ Per-feature daily quotas + rate limiting + budget kill switch. |
| 6 | No loading/empty/error states | ✅ Mandatory loading skeletons, empty states, reusable error system. |
| 7 | No splash/login flow | ✅ Splash → auto anonymous auth → Home. |
| 8 | No input validation | ✅ Validators: non-empty, char limits, trim, duplicate-request guard. |
| 9 | No share | ✅ Copy + Share + Save on every result. |
| 10 | No testing strategy | ✅ Unit/Repository/Service/Widget test structure (writing optional for MVP). |
| 11 | No catalogs | ✅ Language (8), Category (17), Country (10) catalogs. |
| 12 | No env config | ✅ Dev/Staging/Production via `Envied`; no secrets in Flutter. |

---

## 2. Folder Structure

```
lib/
├── main.dart
├── app.dart                         # MaterialApp.router + theme + init
│
├── core/
│   ├── config/
│   │   ├── app_config.dart          # flavor config (dev/prod)
│   │   └── env/                     # Envied env vars (API base URLs, flags)
│   ├── constants/
│   │   ├── app_constants.dart
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   └── app_sizes.dart
│   ├── theme/
│   │   ├── app_theme.dart           # ThemeData builder (M3)
│   │   ├── dark_theme.dart
│   │   └── light_theme.dart
│   ├── router/
│   │   ├── app_router.dart          # GoRouter config + refreshListener
│   │   └── routes.dart              # Route path constants
│   ├── network/
│   │   ├── dio_client.dart          # Dio singleton
│   │   ├── api_endpoints.dart
│   │   └── interceptors/
│   │       ├── auth_interceptor.dart
│   │       ├── logging_interceptor.dart
│   │       └── error_interceptor.dart
│   ├── error/
│   │   ├── failures.dart            # Failure hierarchy
│   │   ├── exceptions.dart
│   │   └── error_handler.dart       # → Crashlytics + user message mapping
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── date_utils.dart
│   │   ├── string_utils.dart
│   │   └── ui_utils.dart            # spacing, snackbar helpers
│   ├── widgets/                     # shared/generic UI
│   │   ├── common/
│   │   │   ├── app_button.dart
│   │   │   ├── app_card.dart
│   │   │   ├── app_text_field.dart
│   │   │   ├── app_dropdown.dart
│   │   │   ├── copy_button.dart
│   │   │   ├── share_button.dart
│   │   │   ├── loading_indicator.dart
│   │   │   ├── shimmer_loading.dart
│   │   │   ├── empty_state.dart
│   │   │   └── error_state.dart
│   │   └── layout/
│   │       └── responsive_builder.dart
│   └── services/                    # cross-feature infra services
│       ├── firebase_service.dart    # Firebase init
│       ├── analytics_service.dart
│       ├── crashlytics_service.dart
│       ├── connectivity_service.dart
│       ├── clipboard_service.dart
│       ├── share_service.dart
│       └── haptic_service.dart
│
├── features/
│   ├── auth/
│   │   ├── models/user_profile.dart
│   │   ├── repository/auth_repository.dart
│   │   ├── providers/auth_providers.dart
│   │   ├── screens/
│   │   │   ├── splash_screen.dart
│   │   │   └── login_screen.dart
│   │   └── widgets/
│   │
│   ├── home/
│   │   ├── providers/home_providers.dart
│   │   ├── screens/home_screen.dart
│   │   └── widgets/feature_card.dart
│   │
│   ├── title/
│   │   ├── models/generated_title.dart
│   │   ├── repository/title_repository.dart
│   │   ├── providers/title_providers.dart
│   │   ├── screens/title_generator_screen.dart
│   │   └── widgets/
│   │
│   ├── hashtags/        # same internal structure as title/
│   ├── description/     # same
│   ├── content/         # same
│   ├── viral_ideas/     # same
│   ├── trending/        # same
│   ├── thumbnail/       # same + image result model
│   ├── seo/             # same + analysis model
│   │
│   ├── history/
│   │   ├── models/history_item.dart
│   │   ├── repository/history_repository.dart
│   │   ├── providers/history_providers.dart
│   │   ├── screens/
│   │   │   ├── history_screen.dart
│   │   │   └── history_detail_screen.dart
│   │   └── widgets/history_tile.dart
│   │
│   └── settings/
│       ├── providers/settings_providers.dart
│       ├── screens/settings_screen.dart
│       └── widgets/
│
└── shared/
    ├── models/
    │   ├── language.dart
    │   ├── category.dart
    │   └── country.dart
    └── catalogs/
        ├── languages.dart            # curated language list
        ├── categories.dart           # curated category list
        └── countries.dart            # curated country list
```

**Rules:**
- A feature folder **never imports** another feature folder directly. Cross-feature communication goes through `core` or via Riverpod providers exposed at `core` level.
- `core/widgets` holds only generic, feature-agnostic UI.
- `shared/` holds pure data catalogs used by multiple features.

---

## 3. Feature Breakdown

Each feature follows the same contract: **Inputs → AI/Service call → Output model → Actions → States → Persistence**.

### 3.1 Home Dashboard
- **Purpose:** Entry hub with cards for every feature.
- **Data:** Static feature list (icon, title, route).
- **States:** Always ready (no async).
- **Future hook:** Reserved slot for premium banner / ad widget (not rendered now).

### 3.2 Title Generator
- **Inputs:** `topic` (required, 3–120 chars), `language` (from catalog).
- **Output:** `GeneratedTitle { id, topic, language, titles: List<String>(10), createdAt }`.
- **Actions:** Copy (single / all), Regenerate, Save to history.
- **Validation:** topic non-empty, length 3–120.

### 3.3 Hashtag Generator
- **Inputs:** `topic` (required, 3–120 chars).
- **Output:** `GeneratedHashtag { id, topic, hashtags: List<String>(20), createdAt }`.
- **Actions:** Copy (single / all), Save.

### 3.4 Description Generator
- **Inputs:** `topic` (required, 3–200 chars).
- **Output:** `GeneratedDescription { id, topic, description: String, createdAt }`.
- **Actions:** Copy, Save.

### 3.5 Content Generator
- **Inputs:** `topic` (required, 3–200 chars).
- **Output:** `GeneratedContent { id, topic, hook, mainContent, cta, createdAt }`.
- **Actions:** Copy per-section, Copy all, Save.

### 3.6 Viral Shorts Ideas
- **Inputs:** `category` (from catalog), `language`.
- **Output:** `ViralIdeas { id, category, language, ideas: List<String>(20), createdAt }`.
- **Actions:** Copy single, Save.

### 3.7 Trending Topics
- **Inputs:** `category`, `country`, `language`.
- **Output:** `TrendingTopics { id, category, country, language, topics: List<String>, createdAt }`.
- **Actions:** Copy single, Save.

### 3.8 Thumbnail Generator
- **Inputs:** `topic` (3–120), `category`, `style` (enum: vibrant, minimal, cinematic, cartoon, realistic).
- **Output:** `GeneratedThumbnail { id, topic, category, style, imageUrl, createdAt }`.
- **Actions:** Download (to gallery via `gal`/`image_gallery_saver`), Regenerate.
- **Note:** Image generated via `ImageGenerationService` abstraction (not OpenRouter).

### 3.9 SEO Analysis
- **Inputs:** `youtubeUrl` (validated YouTube Shorts URL).
- **Process:** Fetch metadata via YouTube oEmbed → pass to AI for analysis.
- **Output:** `SeoAnalysis { id, videoUrl, title, description, hashtags, score: int, suggestions: List<String>, createdAt }`.
- **Actions:** Copy suggestions, Save.

### 3.10 History
- **Storage:** Hive (local only for MVP).
- **Operations:** List (sorted by createdAt desc), Open detail, Copy, Delete (single + clear all).
- **Model:** `HistoryItem` polymorphic wrapper (see §5.11).

### 3.11 Settings
- **Options:** Theme mode (system/light/dark), Clear History, App Version, Privacy Policy, Terms, Contact Us.
- **Persistence:** Theme mode in Hive (`settings` box).

---

## 4. Navigation Flow

```
[Splash] ──(auth check)──► user exists? ──yes──► [Home]
                              │
                              no
                              ▼
                     auto anonymous sign-in ──► [Home]
                              │
                   (optional) Google Sign-In tap ──► [Login] ──► [Home]

[Home] ──card tap──► [Feature Screen] ──back──► [Home]
[Home] ──History──► [History] ──item tap──► [History Detail] ──back──► [History]
[Home] ──Settings──► [Settings] ──back──► [Home]
```

**Auth flow (automatic):**
- Splash screen checks auth state.
- If already authenticated → go directly to Home.
- If not → sign in anonymously automatically → go to Home.
- Google Sign-In is optional (user-initiated from login/settings).
- No user interaction required unless Google Sign-In is chosen.

**GoRouter design:**
- `GoRouter` with `refreshListenable` tied to auth state.
- `redirect` callback: if route is protected and user is null → `/login`.
- Routes use **typed** path constants from `routes.dart`.
- Transitions: custom fade/slide for premium feel.

**Route table:**

| Path | Screen | Protected |
|------|--------|-----------|
| `/splash` | SplashScreen | No |
| `/login` | LoginScreen | No |
| `/` | HomeScreen | Yes |
| `/title` | TitleGeneratorScreen | Yes |
| `/hashtags` | HashtagGeneratorScreen | Yes |
| `/description` | DescriptionGeneratorScreen | Yes |
| `/content` | ContentGeneratorScreen | Yes |
| `/viral-ideas` | ViralIdeasScreen | Yes |
| `/trending` | TrendingScreen | Yes |
| `/thumbnail` | ThumbnailGeneratorScreen | Yes |
| `/seo` | SeoAnalysisScreen | Yes |
| `/history` | HistoryScreen | Yes |
| `/history/:id` | HistoryDetailScreen | Yes |
| `/settings` | SettingsScreen | Yes |

---

## 5. Data Models

All models use **`freezed`** + **`json_serializable`** for immutability, copyWith, equality, and JSON (de)serialization. Hive adapters are generated via **`hive_ce`** (or `hive`) type adapters where local persistence is needed.

### 5.1 UserProfile
```dart
@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String uid,
    String? email,
    String? displayName,
    String? photoUrl,
    required bool isAnonymous,
    required DateTime createdAt,
  }) = _UserProfile;
  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
}
```

### 5.2 GeneratedTitle
```dart
@freezed
class GeneratedTitle with _$GeneratedTitle {
  const factory GeneratedTitle({
    required String id,
    required String topic,
    required String language,
    required List<String> titles,
    required DateTime createdAt,
  }) = _GeneratedTitle;
  factory GeneratedTitle.fromJson(Map<String, dynamic> json) => _$GeneratedTitleFromJson(json);
}
```

### 5.3 GeneratedHashtag
```dart
@freezed
class GeneratedHashtag with _$GeneratedHashtag {
  const factory GeneratedHashtag({
    required String id,
    required String topic,
    required List<String> hashtags,
    required DateTime createdAt,
  }) = _GeneratedHashtag;
  factory GeneratedHashtag.fromJson(Map<String, dynamic> json) => _$GeneratedHashtagFromJson(json);
}
```

### 5.4 GeneratedDescription
```dart
@freezed
class GeneratedDescription with _$GeneratedDescription {
  const factory GeneratedDescription({
    required String id,
    required String topic,
    required String description,
    required DateTime createdAt,
  }) = _GeneratedDescription;
  factory GeneratedDescription.fromJson(Map<String, dynamic> json) => _$GeneratedDescriptionFromJson(json);
}
```

### 5.5 GeneratedContent
```dart
@freezed
class GeneratedContent with _$GeneratedContent {
  const factory GeneratedContent({
    required String id,
    required String topic,
    required String hook,
    required String mainContent,
    required String cta,
    required DateTime createdAt,
  }) = _GeneratedContent;
  factory GeneratedContent.fromJson(Map<String, dynamic> json) => _$GeneratedContentFromJson(json);
}
```

### 5.6 ViralIdeas
```dart
@freezed
class ViralIdeas with _$ViralIdeas {
  const factory ViralIdeas({
    required String id,
    required String category,
    required String language,
    required List<String> ideas,
    required DateTime createdAt,
  }) = _ViralIdeas;
  factory ViralIdeas.fromJson(Map<String, dynamic> json) => _$ViralIdeasFromJson(json);
}
```

### 5.7 TrendingTopics
```dart
@freezed
class TrendingTopics with _$TrendingTopics {
  const factory TrendingTopics({
    required String id,
    required String category,
    required String country,
    required String language,
    required List<String> topics,
    required DateTime createdAt,
  }) = _TrendingTopics;
  factory TrendingTopics.fromJson(Map<String, dynamic> json) => _$TrendingTopicsFromJson(json);
}
```

### 5.8 GeneratedThumbnail
```dart
@freezed
class GeneratedThumbnail with _$GeneratedThumbnail {
  const factory GeneratedThumbnail({
    required String id,
    required String topic,
    required String category,
    required String style,
    required String imageUrl,
    required DateTime createdAt,
  }) = _GeneratedThumbnail;
  factory GeneratedThumbnail.fromJson(Map<String, dynamic> json) => _$GeneratedThumbnailFromJson(json);
}
```

### 5.9 SeoAnalysis
```dart
@freezed
class SeoAnalysis with _$SeoAnalysis {
  const factory SeoAnalysis({
    required String id,
    required String videoUrl,
    String? title,
    String? description,
    List<String> hashtags,
    @Default(0) int score,
    @Default([]) List<String> suggestions,
    required DateTime createdAt,
  }) = _SeoAnalysis;
  factory SeoAnalysis.fromJson(Map<String, dynamic> json) => _$SeoAnalysisFromJson(json);
}
```

### 5.10 AppSettings
```dart
@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default(ThemeMode.system) ThemeMode themeMode,
  }) = _AppSettings;
  factory AppSettings.fromJson(Map<String, dynamic> json) => _$AppSettingsFromJson(json);
}
```

### 5.11 HistoryItem (polymorphic wrapper)
```dart
enum HistoryType { title, hashtag, description, content, viralIdeas, trending, thumbnail, seo }

@freezed
class HistoryItem with _$HistoryItem {
  const factory HistoryItem({
    required String id,
    required HistoryType type,
    required String displayTitle,   // human label for the list tile
    required Map<String, dynamic> data, // serialized model JSON
    required DateTime createdAt,
  }) = _HistoryItem;
  factory HistoryItem.fromJson(Map<String, dynamic> json) => _$HistoryItemFromJson(json);
}
```
Storing `data` as a JSON map avoids complex polymorphic Hive adapters; the repository rehydrates the concrete model from `type` + `data`.

### 5.12 Shared Catalogs
```dart
class Language  { final String code; final String name;  ... }  // en, hi, es, pt, fr, de, ar, id
class Category  { final String id;   final String name;  ... }  // education, gaming, tech...
class Country   { final String code; final String name;  ... }  // IN, US, GB...
enum ThumbnailStyle { vibrant, minimal, cinematic, cartoon, realistic }
```

**Language catalog (8 initial — easily extendable):**
English, Hindi, Spanish, Portuguese, French, German, Arabic, Indonesian

**Category catalog (17 initial):**
Education, Gaming, Technology, AI, Motivation, Finance, Business, Health,
Fitness, Food, Travel, Comedy, Religion, News, Sports, Entertainment, Lifestyle

**Country catalog (10 initial):**
India, United States, United Kingdom, Canada, Australia, Germany, France,
Brazil, Indonesia, UAE

---

## 6. Repository Pattern

Each feature exposes a **repository interface** (abstract class) and a concrete
implementation. UI/providers depend on the interface; implementation is injected
via Riverpod `Provider`.

### 6.1 Generic contract example (Title)
```dart
abstract class TitleRepository {
  Future<GeneratedTitle> generate({required String topic, required String language});
  Future<void> saveToHistory(GeneratedTitle title);
}
```

### 6.2 Implementation pattern
```dart
class TitleRepositoryImpl implements TitleRepository {
  TitleRepositoryImpl(this._aiService, this._historyRepository);
  final AiService _aiService;
  final HistoryRepository _historyRepository;

  @override
  Future<GeneratedTitle> generate({...}) async {
    final result = await _aiService.generate(
      prompt: TitlePromptBuilder.build(topic, language),
      schema: TitleSchema.json,
    );
    return TitleMapper.fromAiResult(result, topic, language);
  }
  ...
}
```

### 6.3 Repository responsibilities
- Call the AI service with a feature-specific **prompt template**.
- Map raw AI JSON → typed model (**Mapper**).
- Persist to history via `HistoryRepository`.
- Never throw raw exceptions; convert to `Failure` (see §13).

### 6.4 HistoryRepository
```dart
abstract class HistoryRepository {
  List<HistoryItem> getAll();
  HistoryItem? getById(String id);
  Future<void> add(HistoryItem item);
  Future<void> delete(String id);
  Future<void> clearAll();
}
```

---

## 7. Service Layer

### 7.1 AiService (the single reusable AI service)
```dart
abstract class AiService {
  /// Generic text generation. Returns parsed JSON or raw text.
  Future<AiResult> generate({required AiRequest request});
}

class AiRequest {
  final String prompt;        // built by feature prompt builders
  final String? schema;       // JSON schema hint for structured output
  final int? maxTokens;
  final double? temperature;
}

class AiResult {
  final String rawText;
  final Map<String, dynamic>? json;  // parsed if schema provided
}
```
**Only one implementation** (`OpenRouterAiService` via Cloud Functions) is wired
for MVP. Switching providers = implementing `AiService` + changing the provider
in one Riverpod override. **No UI changes.**

### 7.2 ImageGenerationService
```dart
abstract class ImageGenerationService {
  Future<String> generateImage({required String prompt, required String style});
}
```
Abstracted separately from text AI because image providers differ (DALL-E,
Stability AI). Swappable in one file.

### 7.3 AuthRepository / AuthService
- Wraps `firebase_auth` + `google_sign_in`.
- Methods: `signInAnonymously()`, `signInWithGoogle()`, `signOut()`, `authStateChanges()`.

### 7.4 AnalyticsService
- Wraps `firebase_analytics`.
- Typed `logEvent(name, params)` methods per feature (e.g. `logTitleGenerated`).

### 7.5 CrashlyticsService
- Wraps `firebase_crashlytics`.
- `recordError(error, stack, reason)` + `setUser(uid)`.

### 7.6 ClipboardService / ShareService / HapticService
- Thin wrappers over `flutter` clipboard, `share_plus`, and `HapticFeedback`.
- Wrapping enables testing + future customization.

### 7.7 ConnectivityService
- `Stream<bool> get isOnline` via `connectivity_plus`.
- Guards AI calls with offline check → friendly error.

### 7.8 YouTubeService
```dart
abstract class YouTubeService {
  Future<YouTubeVideo> fetchVideoMetadata({required String videoUrl});
  Future<YouTubeChannel> fetchChannelInfo({required String channelId});
  Future<List<YouTubeSearchResult>> search({required String query, ...});
}
```
- Wraps YouTube Data API v3 (via Cloud Functions — key server-side).
- Used by SEO Analysis feature; reusable for future competitor analysis / keyword explorer / best upload time.
- Interface + concrete implementation; swappable.

---

## 8. AI Integration Architecture

### 8.1 Security model (CRITICAL — non-negotiable)
**Never** expose the OpenRouter or Replicate API key in the Flutter app. All AI
requests go through **Firebase Cloud Functions**:

```
Flutter ──HTTPS (Firebase ID token)──► Cloud Function
                                          │  1. Verify auth
                                          │  2. Check rate limit (1 req / 5–10s)
                                          │  3. Check per-feature daily quota
                                          │  4. Check budget kill switch
                                          │  5. Check cache
                                          ├─► OpenRouter (Gemini 2.5 Flash)  [text]
                                          └─► Replicate (FLUX.1 Schnell)     [image]
                                          │  6. Log request (uid, feature, model, tokens, cost, time)
                                          │  7. Increment usage counters
                                          └── returns JSON to app
```

### 8.2 Cloud Functions (Node.js)
Three callable functions for MVP:
- `generateContent(AiRequest)` → OpenRouter (Gemini 2.5 Flash), returns JSON.
- `generateImage(ImageRequest)` → Replicate (FLUX.1 Schnell), returns image URL.
- `analyzeSeo(SeoRequest)` → YouTube Data API v3 + OpenRouter analysis.

All functions:
1. Verify Firebase ID token (auth required).
2. Rate-limit: max 1 request per 5–10 seconds per user.
3. Per-feature daily quota check (Firestore `users/{uid}/usage/{date}`).
4. Budget kill switch check (Firestore `config/daily_budget`).
5. Cache check (Firestore `cache/{promptHash}` or Hive).
6. Call provider with server-side API key.
7. Log to Firestore `logs/{id}`.
8. Increment usage counters.
9. Return result.

### 8.3 AIService abstraction (OpenRouter — Gemini 2.5 Flash)
```dart
abstract class AiService {
  Future<AiResult> generate({required AiRequest request});
}

class AiRequest {
  final String prompt;
  final String? schema;       // JSON schema hint for structured output
  final int maxTokens;        // default 300
  final double temperature;   // default 0.7
}

class AiResult {
  final String rawText;
  final Map<String, dynamic>? json;
  final int tokensUsed;
  final double estimatedCost;
}
```
- Default model: **Gemini 2.5 Flash** via OpenRouter.
- Default params: `max_tokens = 300`, `temperature = 0.7`.
- 300 tokens is sufficient for titles/hashtags/descriptions.
- Swapping model/provider = implementing `AiService` + changing one Riverpod override.

### 8.4 ImageGenerationService (Replicate — FLUX.1 Schnell)
```dart
abstract class ImageGenerationService {
  Future<ImageResult> generateImage({required String prompt, required String style});
}

class ImageResult {
  final String imageUrl;
  final int width;
  final int height;
}
```
- Default model: **FLUX.1 Schnell** via Replicate.
- MVP resolution: **512×512** or **768×768** (cost control).
- Quota: **3 thumbnails/day** (image is the most expensive feature).
- Swappable provider in one file.

### 8.5 YouTubeService (YouTube Data API v3)
```dart
abstract class YouTubeService {
  Future<YouTubeVideo> fetchVideoMetadata({required String videoUrl});
  Future<YouTubeChannel> fetchChannelInfo({required String channelId});
  Future<List<YouTubeSearchResult>> search({required String query, ...});
}
```
- Used by SEO Analysis feature for video metadata + channel info.
- All calls routed through Cloud Functions (API key server-side).
- Wrapping enables future features (competitor analysis, keyword explorer).

### 8.6 Per-feature daily quotas
```
users/{uid}/usage/{date}
  title: 12
  hashtag: 8
  description: ...
  script: 4
  thumbnail: 1
```
| Feature | Daily limit |
|---------|------------|
| Title Generator | 20/day |
| Description Generator | 20/day |
| Hashtag Generator | 20/day |
| Content/Script Generator | 10/day |
| Viral Ideas | 20/day |
| Trending Topics | 20/day |
| SEO Analysis | 10/day |
| Thumbnail Generator | 3/day |

Cloud Function checks quota before calling provider. Client shows friendly
"daily limit reached" state.

### 8.7 Rate limiting
- Max **1 request every 5–10 seconds** per user (enforced in Cloud Function).
- Prevents spam/abuse.
- Client also debounces to prevent duplicate requests.

### 8.8 Budget kill switch ⭐
```
config/daily_budget
  enabled: true
  maxCost: 5.0   // USD
  currentCost: 0.0
```
- If `currentCost >= maxCost`, Cloud Function returns:
  "Daily limit reached. Please try tomorrow."
- Prevents uncontrolled billing.
- `enabled` flag allows manual kill switch.

### 8.9 Caching
- Same prompt → return cached result (Firestore `cache/{promptHash}` or Hive).
- Avoids duplicate AI calls.
- Example: "Jesus Facts" topic already generated → same result returned.
- Cache key: `sha256(prompt + params)`.
- TTL: 24 hours.

### 8.10 Timeout
- AI response timeout: **10–15 seconds**.
- On timeout: cancel request, show friendly timeout error with retry.
- Dio `receiveTimeout` + Cloud Function timeout both set.

### 8.11 Logging
Every AI request logged to Firestore:
```
logs/{id}
  uid
  feature       // title, hashtag, thumbnail...
  model         // gemini-2.5-flash, flux.1-schnell
  tokens
  cost
  timestamp
  durationMs
```
- Foundation for future analytics dashboard.
- No PII beyond uid.

### 8.12 Prompt engineering
Each feature has a **PromptBuilder** constructing a deterministic JSON-output
prompt. Example:
```
TitlePromptBuilder.build(topic: "gaming shorts", language: "English")
→ "You are a YouTube Shorts SEO expert. Generate exactly 10 SEO-friendly
   titles for the topic '<topic>' in <language>. Return JSON: {"titles":[...]}.
   No extra text."
```
Prompt builders live in each feature's `repository/` folder; transport
(`AiService`) stays generic.

---

## 9. Firebase Structure

### 9.1 Authentication
- **Anonymous sign-in (default):** automatic, frictionless. Every user gets a unique UID for usage tracking.
- **Google Sign-In (optional):** user-initiated upgrade.
- `idToken` sent to Cloud Functions for verification.

### 9.2 Firestore (MVP)
```
users/{uid}
  uid, email, displayName, photoUrl, isAnonymous, createdAt, lastSeen

users/{uid}/usage/{date}          # date = "2026-06-27"
  title: 12
  hashtag: 8
  description: 5
  script: 4
  viralIdeas: 3
  trending: 2
  seo: 1
  thumbnail: 1

config/daily_budget               # global kill switch
  enabled: true
  maxCost: 5.0
  currentCost: 0.0

cache/{promptHash}                # AI response cache
  promptHash, feature, result, createdAt, expiresAt

logs/{id}                         # request logging
  uid, feature, model, tokens, cost, timestamp, durationMs
```
History stays in Hive (local) for MVP. The `users` + `usage` collections are the
foundation for future cloud history / favorites / team accounts / premium quotas.

### 9.3 Cloud Functions
- `generateContent` (callable) — OpenRouter / Gemini 2.5 Flash
- `generateImage` (callable) — Replicate / FLUX.1 Schnell
- `analyzeSeo` (callable) — YouTube Data API v3 + OpenRouter
All enforce: auth, rate limit, quota, budget, cache, logging.

### 9.4 Firebase Storage
- Reserved for future: storing generated thumbnails per user (cloud history).
- Not actively used in MVP (thumbnails downloaded to device gallery).

### 9.5 Analytics
- Screen view logging (via `navigatorObservers`).
- Feature usage events: `title_generated`, `hashtag_generated`, etc.
- No PII in params.

### 9.6 Crashlytics
- Auto-init in `main.dart`.
- `FlutterError.onError` → Crashlytics.
- `PlatformDispatcher.instance.onError` → Crashlytics.
- User identifier set on login.

---

## 10. API Abstraction (Dio)

`Dio` is used for non-AI HTTP (oEmbed for SEO analysis, image downloads). AI
calls go through Cloud Functions (also via Dio or `cloud_functions` plugin).

### 10.1 DioClient
- Singleton `Dio` with base config (timeouts, headers).
- Interceptors:
  - **AuthInterceptor**: attaches Firebase ID token to Cloud Function calls.
  - **LoggingInterceptor**: dev-only pretty logging.
  - **ErrorInterceptor**: maps DioErrors → `Failure` types.

### 10.2 ApiEndpoints
- Centralized path/URL constants.
- oEmbed URL builder for SEO analysis.

### 10.3 Why Dio
- Interceptor pipeline, cancellation, FormData (image upload future), clean
  error types — better than `http` for a production app.

---

## 11. State Management Plan (Riverpod)

### 11.1 Approach
- `flutter_riverpod` with the modern **`Notifier`/`AsyncNotifier`** API.
- Each feature exposes its providers in `providers/<feature>_providers.dart`.
- No global mutable singletons; everything through providers.

### 11.2 Provider tiers
| Tier | Provider type | Example |
|------|---------------|---------|
| Infrastructure | `Provider` | `dioProvider`, `aiServiceProvider`, `firebaseAuthProvider` |
| Repository | `Provider` | `titleRepositoryProvider` (depends on infra) |
| Feature state | `AsyncNotifierProvider` | `titleGeneratorProvider` (handles generate/loading/result) |
| App state | `NotifierProvider` | `authProvider`, `settingsProvider`, `themeProvider` |

### 11.3 Async state shape
Each generator screen uses `AsyncValue<GeneratedX>`:
- `.loading` → shimmer / spinner.
- `.data` → result UI.
- `.error` → `ErrorState` with retry.

### 11.4 Settings/Theme
- `settingsProvider` (Notifier) reads/writes Hive `settings` box.
- `themeProvider` derives `ThemeMode` → consumed by `app.dart`.

---

## 12. Local Storage Strategy (Hive)

### 12.1 Boxes
| Box | Contents |
|-----|----------|
| `history` | `HistoryItem` records (all generation types) |
| `settings` | `AppSettings` (theme mode) |
| `cache` | Short-lived AI response cache (optional, keyed by prompt hash) |

### 12.2 Adapters
- `HistoryItemAdapter`, `HistoryTypeAdapter` (enum), `AppSettingsAdapter`.
- Generated via Hive type adapters (build_runner).

### 12.3 Cache strategy (optional MVP)
- Key: `sha256(prompt)`.
- TTL: 1 hour.
- Reduces duplicate AI calls when user taps Regenerate with same inputs.
- Can be disabled in settings (future).

### 12.4 History limits
- Cap at 200 items (FIFO eviction) to bound storage.
- Configurable in `app_constants.dart`.

---

## 13. Error Handling Strategy

### 13.1 Failure hierarchy (reusable error system)
```dart
sealed class Failure { String get message; }
class NetworkFailure        extends Failure { ... }  // no internet
class TimeoutFailure        extends Failure { ... }  // 10–15s AI timeout
class ApiFailure            extends Failure { final int? code; }
class FirebaseFailure       extends Failure { ... }  // auth/firestore errors
class QuotaExceededFailure  extends Failure { final String feature; }
class BudgetExceededFailure extends Failure { ... }  // daily budget kill switch
class RateLimitFailure      extends Failure { ... }  // 1 req / 5–10s
class ValidationFailure     extends Failure { final Map<String,String> fieldErrors; }
class UnknownFailure        extends Failure { ... }
```

### 13.2 Flow
```
Service/Repo throws → caught → mapped to Failure → AsyncValue.error(Failure)
                                                      → UI shows ErrorState(failure)
```

### 13.3 UI mapping (friendly messages + Retry)
- `NetworkFailure` → "You're offline. Check your connection." + Retry
- `TimeoutFailure` → "This is taking too long. Please try again." + Retry
- `ApiFailure` → "Something went wrong on our end." + Retry
- `FirebaseFailure` → "Authentication error. Please try again." + Retry
- `QuotaExceededFailure` → "Daily limit for <feature> reached. Try tomorrow."
- `BudgetExceededFailure` → "Daily limit reached. Please try tomorrow."
- `RateLimitFailure` → "Too many requests. Please wait a few seconds."
- `ValidationFailure` → inline field errors (no retry; fix input).
- `UnknownFailure` → "Something went wrong." + Retry

### 13.4 Crashlytics
- `UnknownFailure` and uncaught errors → `CrashlyticsService.recordError`.
- Expected failures (validation, offline, quota, budget, rate limit) are **not** reported.

---

## 14. Theme Architecture

### 14.1 Material 3
- `useMaterial3: true`.
- `ColorScheme.fromSeed` for light + dark, with a branded seed color.
- Custom `ThemeData` extensions for app-specific component styling.

### 14.2 Theme modes
- System / Light / Dark (user-selectable in Settings).
- `themeProvider` exposes `ThemeMode`; `app.dart` passes to `MaterialApp.router`.

### 14.3 Shared UI components (premium feel)
- `AppCard`: rounded, elevated, subtle shadow.
- `AppButton`: filled/outlined/text variants with loading state.
- `AppTextField`: outlined, with error + helper text.
- `ShimmerLoading`: skeleton placeholders during AI calls.
- `EmptyState` / `ErrorState`: consistent illustrations + actions.
- Smooth `AnimatedSwitcher` / `Hero` transitions.
- Consistent spacing scale (`AppSizes`).

### 14.4 Typography
- `google_fonts` (e.g. Inter / Poppins) for a modern look, with fallback.

---

## 15. Dependency List (pubspec)

### 15.1 Flutter SDK & core
- `flutter` (latest stable)
- `cupertino_icons`

### 15.2 State / routing
- `flutter_riverpod: ^2.5.1`
- `go_router: ^14.2.0`

### 15.3 Networking
- `dio: ^5.5.0`

### 15.4 Local storage
- `hive: ^2.2.3` (or `hive_ce`)
- `hive_flutter: ^1.1.0`

### 15.5 Firebase
- `firebase_core: ^3.3.0`
- `firebase_auth: ^5.2.0`
- `cloud_firestore: ^5.4.0`
- `firebase_analytics: ^11.3.0`
- `firebase_crashlytics: ^4.1.0`
- `cloud_functions: ^5.0.0`
- `google_sign_in: ^6.2.1`
- `firebase_storage: ^12.0.0` (reserved for future cloud thumbnails)

### 15.6 Models / codegen
- `freezed: ^2.5.2`
- `freezed_annotation: ^2.4.4`
- `json_annotation: ^4.9.0`
- `build_runner: ^2.4.11`
- `json_serializable: ^6.8.0`
- `hive_generator: ^2.0.1` (if using hive adapters)

### 15.7 UI / UX
- `google_fonts: ^6.2.1`
- `shimmer: ^3.0.0`
- `cached_network_image: ^3.4.1`
- `flutter_svg: ^2.0.10`
- `flutter_animate: ^4.5.0` (smooth animations)
- `gal: ^2.3.0` (save image to gallery)

### 15.8 Utilities
- `share_plus: ^10.0.0`
- `connectivity_plus: ^6.0.3`
- `uuid: ^4.4.0`
- `envied: ^0.5.4` (+ `envied_generator`)
- `logger: ^2.3.0`
- `url_launcher: ^6.3.0` (privacy policy, contact)
- `intl: ^0.19.0` (date formatting)

### 15.9 Dev / test
- `flutter_lints: ^4.0.0`
- `mocktail: ^1.0.4`
- `integration_test`

> Exact versions pinned at `flutter pub get` time; above are recent compatible versions.
> Note: OpenRouter, Replicate, and YouTube API keys are **never** in pubspec/env — they live server-side in Cloud Functions.

---

## 15B. Environment Configuration

Three environments: **Development**, **Staging**, **Production**.

Stored in Flutter (non-secret config only):
- Firebase config (google-services.json / GoogleService-Info.plist per flavor)
- Cloud Functions endpoint (region + callable names)
- App flavor name

**Never stored in Flutter:**
- OpenRouter API key
- Replicate API key
- YouTube Data API v3 key

These live as Cloud Functions config / Secret Manager.

Flavor setup via `--flavor` + `dart-define` / `Envied` for non-secret flags.
`main_dev.dart`, `main_staging.dart`, `main_production.dart` entry points.

---

## 16. Development Roadmap with Milestones

Implementation is **feature-by-feature**, one complete feature committed at a
time. Each milestone ends with a working, testable slice.

### Milestone 0 — Foundation (no UI)
- Flutter project init, folder structure, pubspec deps.
- Env config (`Envied`), flavor setup.
- Firebase init (core/auth/firestore/analytics/crashlytics).
- Dio client + interceptors.
- Hive init + boxes + adapters.
- Theme (M3 light/dark) + shared widgets.
- GoRouter skeleton + auth redirect.
- Error/Failure hierarchy.
- **Deliverable:** app launches → splash → (login) → empty home. Builds on all flavors.

### Milestone 1 — Auth
- Splash screen, login screen (anonymous + Google).
- `AuthRepository`, `authProvider`, router refresh.
- Firestore `users/{uid}` write on sign-in.
- **Deliverable:** user can sign in; route guards work.

### Milestone 2 — Home Dashboard
- Feature cards grid (responsive).
- Navigation to each feature route.
- Analytics screen-view logging.
- **Deliverable:** tappable home grid routing to placeholder feature screens.

### Milestone 3 — AI Service + Cloud Functions
- Deploy `generateContent` + `generateImage` Cloud Functions.
- `AiService` abstraction + `OpenRouterAiService` impl (via Cloud Functions).
- `ImageGenerationService` abstraction + impl.
- Quota enforcement (`usage/{uid}`).
- Connectivity guard.
- **Deliverable:** a hidden test screen can call AI end-to-end.

### Milestone 4 — Title Generator (reference feature)
- Model, repository, prompt builder, mapper, providers.
- Screen with input → generate → result → copy/regenerate/save.
- Loading shimmer, empty, error states.
- History save.
- Analytics event.
- **Deliverable:** fully working Title Generator; pattern established for all generators.

### Milestone 5 — Remaining Text Generators
- Hashtag, Description, Content, Viral Ideas, Trending.
- Each follows the Title Generator pattern.
- One commit per feature.
- **Deliverable:** all text generators working.

### Milestone 6 — Thumbnail Generator
- Image generation service wired.
- Style selector, preview, download, regenerate.
- **Deliverable:** user can generate + save a thumbnail.

### Milestone 7 — SEO Analysis
- oEmbed fetch via Dio.
- AI analysis prompt + mapper.
- Score + suggestions UI.
- **Deliverable:** user can analyze a Shorts URL.

### Milestone 8 — History
- `HistoryRepository`, list/detail/delete/clear.
- Polymorphic rehydration by type.
- **Deliverable:** full local history management.

### Milestone 9 — Settings
- Theme mode toggle, clear history, version, legal links.
- **Deliverable:** complete settings screen.

### Milestone 10 — Polish & Release Prep
- Animations, spacing pass, dark mode audit.
- App icons, splash, localization scaffolding (future-ready).
- Crashlytics verification, analytics audit.
- Play Store metadata, signing config.
- **Deliverable:** Play Store–ready APK/AAB.

---

## 17. Future-Ready Hooks (NOT implemented now)

The architecture reserves extension points so the following can be added without
refactoring:

| Future feature | Hook location |
|----------------|---------------|
| Premium plans / RevenueCat | `users/{uid}.isPremium`; quota limit read from Firestore; `PremiumProvider` stub |
| AdMob / Rewarded ads | `core/services/ads_service.dart` (empty stub interface); home reserved ad slot |
| Cloud history | `HistoryRepository` interface unchanged → add `CloudHistoryRepositoryImpl` |
| Multi-language | `easy_localization` ready; strings currently inline but isolated in widgets |
| Advanced analytics | `AnalyticsService` typed methods; add new events |
| Competitor analysis / Keyword explorer / Best upload time | New feature folders following the established pattern |
| Team accounts | `users` → `teams/{teamId}/members`; auth scope extension |

---

## 18. Testing Strategy

The architecture must support tests; writing them is optional for MVP but the
structure is mandatory.

- **Unit tests:** `test/unit/` — repositories (mocked `AiService`), mappers, prompt builders, validators, failure mappers.
- **Repository tests:** `test/repository/` — mock services, assert correct model mapping + failure conversion.
- **Service tests:** `test/service/` — mock Dio/Cloud Functions, assert request shape + error handling.
- **Widget tests:** `test/widget/` — each screen with `ProviderScope` overrides; assert loading/loaded/error/empty states.
- **Integration tests:** `test/integration/` — critical flows (splash → auto auth → home → generate → save → history).
- **Mocking:** `mocktail`.
- Cloud Functions: Firebase emulator for AI proxy / quota / budget tests.

---

## 19. Approval — APPROVED ✅

Architecture is finalized with the following locked decisions:

1. ✅ **Cloud Functions as AI proxy** — all external API calls server-side.
2. ✅ **OpenRouter (Gemini 2.5 Flash)** for text AI; `AiService` abstraction.
3. ✅ **Replicate (FLUX.1 Schnell)** for image generation; `ImageGenerationService` abstraction.
4. ✅ **YouTube Data API v3** for SEO analysis; `YouTubeService` abstraction.
5. ✅ **Per-feature daily quotas** (20/20/20/10/20/20/10/3) + rate limiting (1 req/5–10s) + budget kill switch ($5/day).
6. ✅ **Auto anonymous auth** — splash → auto sign-in → home.
7. ✅ **Mandatory loading/empty/error states** + input validation + share on every result.
8. ✅ **Catalogs:** 8 languages, 17 categories, 10 countries.
9. ✅ **Environments:** Dev/Staging/Production; no secrets in Flutter.
10. ✅ **Testing structure** (unit/repository/service/widget) — architecture supports, writing optional for MVP.
11. ✅ **freezed + json_serializable + Hive adapters** via build_runner.

**Proceeding to Phase 1 implementation, feature-by-feature, one commit per feature.**
