/**
 * ShortSEO AI — Cloud Functions (v2)
 *
 * Three callable functions:
 *   - generateContent  → OpenRouter (Gemini 2.5 Flash) for text
 *   - generateImage    → Replicate (FLUX.1 Schnell) for images
 *   - analyzeSeo       → YouTube Data API v3 + OpenRouter for SEO analysis
 *
 * All functions enforce:
 *   1. Auth verification
 *   2. Rate limiting (1 req / 5s)
 *   3. Per-feature daily quota
 *   4. Budget kill switch
 *   5. Cache (same prompt → cached result)
 *   6. Request logging (uid, feature, model, tokens, cost, time)
 *
 * API keys are NEVER exposed to the client.
 * Set secrets via:
 *   firebase functions:secrets:set OPENROUTER_API_KEY
 *   firebase functions:secrets:set SILICONFLOW_API_KEY
 *   firebase functions:secrets:set REPLICATE_API_TOKEN
 *   firebase functions:secrets:set YOUTUBE_API_KEY
 */

const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { defineSecret } = require('firebase-functions/params');
const logger = require('firebase-functions/logger');

const {
  verifyAuth,
  checkRateLimit,
  checkQuota,
  incrementUsage,
  checkBudget,
  addCost,
  getCache,
  setCache,
  logRequest,
  ESTIMATED_COSTS,
  validateGenerateContent,
  validateGenerateImage,
  validateAnalyzeSeo,
  buildCacheKey,
} = require('./utils');

// Admin console: role management (super_admin only).
exports.setAdminRole = require('./admin').setAdminRole;
// Account deletion (user deletes their own account — GDPR/Play).
exports.deleteMyAccount = require('./admin').deleteMyAccount;

const { generateText, DEFAULT_MODEL: TEXT_MODEL } = require('./openrouter');
const { generateImage: generateImageReplicate, DEFAULT_MODEL: IMAGE_MODEL_REPLICATE } = require('./replicate');
const { generateImage: generateImageSiliconFlow, DEFAULT_MODEL: IMAGE_MODEL_SILICONFLOW } = require('./siliconflow');
const { fetchVideo, fetchChannel, searchVideos } = require('./youtube');

// Define secrets (only loaded when functions execute).
const openrouterKey = defineSecret('OPENROUTER_API_KEY');
const siliconflowKey = defineSecret('SILICONFLOW_API_KEY');
const replicateKey = defineSecret('REPLICATE_API_TOKEN');
const youtubeKey = defineSecret('YOUTUBE_API_KEY');

// ─── generateContent ─────────────────────────────────────────────────────
exports.generateContent = onCall(
  {
    secrets: [openrouterKey],
    // enforceAppCheck: true, // ⚠️ RE-ENABLE before Play production (after the
    // Play app-signing SHA-256 is added to Firebase App Check). Kept OFF during
    // dev so sideloaded test builds (ENABLE_APP_CHECK=false) can call functions.
    timeoutSeconds: 30,
    memory: '256MiB',
  },
  async (request) => {
    const startTime = Date.now();

    // 1. Auth
    const uid = await verifyAuth(request);

    // 2. Validate + sanitize input (rejects malformed input, clamps numbers).
    const { feature, prompt, schema, maxTokens, temperature } =
      validateGenerateContent(request.data);

    // 3. Rate limit
    await checkRateLimit(uid);

    // 4. Quota
    await checkQuota(uid, feature);

    // 5. Budget
    await checkBudget();

    // 6. Server-generated cache key (client cacheKey is never trusted).
    const cacheKey = buildCacheKey(uid, {
      kind: 'text',
      feature,
      prompt,
      schema,
      maxTokens,
      temperature,
    });

    // 7. Cache check
    const cached = await getCache(cacheKey);
    if (cached) {
      logger.info('Cache hit', { uid, feature });
      return cached;
    }

    // 8. Call OpenRouter
    try {
      const result = await generateText({ prompt, schema, maxTokens, temperature });
      const cost = ESTIMATED_COSTS.text;

      const response = {
        rawText: result.rawText,
        json: result.json,
        tokensUsed: result.tokensUsed,
        estimatedCost: cost,
      };

      // 9. Cache store
      await setCache(cacheKey, response);

      // 10. Increment usage
      await incrementUsage(uid, feature);

      // 11. Add cost
      await addCost(cost);

      // 12. Log
      await logRequest({
        uid,
        feature,
        model: TEXT_MODEL,
        tokens: result.tokensUsed,
        cost,
        durationMs: Date.now() - startTime,
      });

      return response;
    } catch (error) {
      // Log full detail server-side; return a generic message to the client.
      logger.error('generateContent failed', {
        uid,
        feature,
        error: error.message,
        stack: error.stack,
      });
      throw new HttpsError('internal', 'AI generation failed. Please try again.', {
        errorCode: 'API_ERROR',
      });
    }
  }
);

// ─── generateImage ───────────────────────────────────────────────────────
exports.generateImage = onCall(
  {
    secrets: [siliconflowKey, replicateKey],
    // enforceAppCheck: true, // ⚠️ RE-ENABLE before Play production (after the
    // Play app-signing SHA-256 is added to Firebase App Check). Kept OFF during
    // dev so sideloaded test builds (ENABLE_APP_CHECK=false) can call functions.
    timeoutSeconds: 60,
    memory: '512MiB',
  },
  async (request) => {
    const startTime = Date.now();

    // 1. Auth
    const uid = await verifyAuth(request);

    // 2. Validate + sanitize input (rejects malformed input, clamps dimensions).
    const { feature, prompt, width, height } =
      validateGenerateImage(request.data);

    // 3. Rate limit
    await checkRateLimit(uid);

    // 4. Quota (thumbnail: 3/day)
    await checkQuota(uid, feature);

    // 5. Budget
    await checkBudget();

    // 6. Server-generated cache key (client cacheKey is never trusted).
    const cacheKey = buildCacheKey(uid, {
      kind: 'image',
      feature,
      prompt,
      width,
      height,
    });

    // 7. Cache check
    const cached = await getCache(cacheKey);
    if (cached) {
      logger.info('Cache hit (image)', { uid, feature });
      return cached;
    }

    // 8. Call SiliconFlow (primary) → Replicate (fallback)
    let result;
    let usedModel;
    try {
      result = await generateImageSiliconFlow({ prompt, width, height });
      usedModel = IMAGE_MODEL_SILICONFLOW;
      logger.info('Image generated via SiliconFlow', { uid, feature });
    } catch (sfError) {
      logger.warn('SiliconFlow failed, falling back to Replicate', {
        uid,
        feature,
        error: sfError.message,
      });
      try {
        result = await generateImageReplicate({ prompt, width, height });
        usedModel = IMAGE_MODEL_REPLICATE;
        logger.info('Image generated via Replicate (fallback)', { uid, feature });
      } catch (repError) {
        logger.error('Both image providers failed', {
          uid,
          feature,
          siliconflowError: sfError.message,
          siliconflowStack: sfError.stack,
          replicateError: repError.message,
          replicateStack: repError.stack,
        });
        throw new HttpsError('internal', 'Image generation failed. Please try again.', {
          errorCode: 'API_ERROR',
        });
      }
    }

    const cost = ESTIMATED_COSTS.image;

    const response = {
      imageUrl: result.imageUrl,
      width: result.width,
      height: result.height,
      estimatedCost: cost,
    };

    // 9. Cache store
    await setCache(cacheKey, response);

    // 10. Increment usage
    await incrementUsage(uid, feature);

    // 11. Add cost
    await addCost(cost);

    // 12. Log
    await logRequest({
      uid,
      feature,
      model: usedModel,
      tokens: 0,
      cost,
      durationMs: Date.now() - startTime,
    });

    return response;
  }
);

// ─── analyzeSeo ──────────────────────────────────────────────────────────
exports.analyzeSeo = onCall(
  {
    secrets: [youtubeKey, openrouterKey],
    // enforceAppCheck: true, // ⚠️ RE-ENABLE before Play production (after the
    // Play app-signing SHA-256 is added to Firebase App Check). Kept OFF during
    // dev so sideloaded test builds (ENABLE_APP_CHECK=false) can call functions.
    timeoutSeconds: 30,
    memory: '256MiB',
  },
  async (request) => {
    // 1. Auth
    const uid = await verifyAuth(request);

    // 2. Validate + sanitize input (rejects malformed input, clamps maxResults).
    const { action, videoUrlOrId, channelId, query, maxResults } =
      validateAnalyzeSeo(request.data);

    // 3. Rate limit on a dedicated 'seo' bucket. This protects the shared
    // YouTube Data API v3 quota from abuse, while keeping its window separate
    // from the default bucket so the follow-up generateContent call (which
    // uses the default bucket) is not tripped by this metadata fetch.
    await checkRateLimit(uid, 'seo');

    try {
      switch (action) {
        case 'fetchVideo': {
          const video = await fetchVideo(videoUrlOrId);
          return { video };
        }
        case 'fetchChannel': {
          const channel = await fetchChannel(channelId);
          return { channel };
        }
        case 'search': {
          const results = await searchVideos(query, maxResults);
          return { results };
        }
        default:
          // Unreachable: action is allowlisted in validateAnalyzeSeo.
          throw new HttpsError('invalid-argument', 'Unknown action.');
      }
    } catch (error) {
      // Preserve explicit client errors (e.g. invalid-argument); hide the rest.
      if (error instanceof HttpsError) throw error;
      logger.error('analyzeSeo failed', {
        uid,
        action,
        error: error.message,
        stack: error.stack,
      });
      throw new HttpsError('internal', 'YouTube request failed. Please try again.', {
        errorCode: 'API_ERROR',
      });
    }
  }
);
