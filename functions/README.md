# ShortSEO AI — Cloud Functions

Firebase Cloud Functions that act as a secure proxy for all external APIs.

## Architecture

```
Flutter app ──► Cloud Function ──► OpenRouter (Gemini 2.5 Flash)  [text]
                              ──► Replicate (FLUX.1 Schnell)      [image]
                              ──► YouTube Data API v3              [metadata]
```

## Functions

| Function | Purpose |
|----------|---------|
| `generateContent` | Text AI via OpenRouter (Gemini 2.5 Flash) |
| `generateImage` | Image AI via Replicate (FLUX.1 Schnell) |
| `analyzeSeo` | YouTube Data API v3 (video/channel/search) |

## Security

- **No API keys in the Flutter app.** All keys are server-side.
- All functions verify Firebase ID tokens.
- Per-feature daily quotas enforced.
- Global budget kill switch ($5/day default).
- Rate limiting (1 request / 5 seconds).
- Request logging for analytics.

## Setup

### 1. Install dependencies

```bash
cd functions
npm install
```

### 2. Set API keys as secrets

```bash
firebase functions:secrets:set OPENROUTER_API_KEY
firebase functions:secrets:set REPLICATE_API_TOKEN
firebase functions:secrets:set YOUTUBE_API_KEY
```

### 3. Initialize budget config (one-time)

```bash
firebase firestore:set config/daily_budget '{enabled: true, maxCost: 5.0, currentCost: 0.0}'
```

### 4. Deploy

```bash
npm run deploy
```

### 5. Local emulator (optional)

```bash
npm run serve
```

## Firestore Collections

```
users/{uid}                          # user profile
users/{uid}/usage/{date}             # daily per-feature counters
config/daily_budget                  # global budget kill switch
cache/{cacheKey}                     # AI response cache (24h TTL)
logs/{id}                            # request logs
rateLimits/{uid}                     # rate limit timestamps
```
