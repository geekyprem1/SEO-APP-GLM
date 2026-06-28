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
} = require('./utils');

const { generateText, DEFAULT_MODEL: TEXT_MODEL } = require('./openrouter');
const { generateImage: generateImageReplicate, DEFAULT_MODEL: IMAGE_MODEL_REPLICATE } = require('./replicate');
const { generateImage: generateImageSiliconFlow, DEFAULT_MODEL: IMAGE_MODEL_SILICONFLOW } = require('./siliconflow');
const { fetchVideo, fetchChannel, searchVideos } = require('./youtube');

// Define secrets (only loaded when functions execute).
const openrouterKey = defineSecret('OPENROUTER_API_KEY');
const replicateToken = defineSecret('REPLICATE_API_TOKEN');
const siliconflowKey = defineSecret('SILICONFLOW_API_KEY');
const youtubeKey = defineSecret('YOUTUBE_API_KEY');

// ─── generateContent ─────────────────────────────────────────────────────
exports.generateContent = onCall(
  {
    secrets: [openrouterKey],
    timeoutSeconds: 30,
    memory: '256MiB',
  },
  async (request) => {
    const startTime = Date.now();
    const { feature, prompt, schema, maxTokens, temperature, cacheKey } = request.data;

    // 1. Auth
    const uid = await verifyAuth(request);

    // 2. Rate limit
    await checkRateLimit(uid);

    // 3. Quota
    await checkQuota(uid, feature);

    // 4. Budget
    await checkBudget();

    // 5. Cache check
    const cached = await getCache(cacheKey);
    if (cached) {
      logger.info('Cache hit', { uid, feature, cacheKey });
      return cached;
    }

    // 6. Call OpenRouter
    try {
      const result = await generateText({ prompt, schema, maxTokens, temperature });
      const cost = ESTIMATED_COSTS.text;

      const response = {
        rawText: result.rawText,
        json: result.json,
        tokensUsed: result.tokensUsed,
        estimatedCost: cost,
      };

      // 7. Cache store
      await setCache(cacheKey, response);

      // 8. Increment usage
      await incrementUsage(uid, feature);

      // 9. Add cost
      await addCost(cost);

      // 10. Log
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
      logger.error('generateContent failed', { uid, feature, error: error.message });
      throw new HttpsError('internal', error.message || 'AI generation failed.', {
        errorCode: 'API_ERROR',
      });
    }
  }
);

// ─── generateImage ───────────────────────────────────────────────────────
exports.generateImage = onCall(
  {
    secrets: [siliconflowKey, replicateToken],
    timeoutSeconds: 60,
    memory: '512MiB',
  },
  async (request) => {
    const startTime = Date.now();
    const { feature, prompt, width, height, cacheKey } = request.data;

    // 1. Auth
    const uid = await verifyAuth(request);

    // 2. Rate limit
    await checkRateLimit(uid);

    // 3. Quota (thumbnail: 3/day)
    await checkQuota(uid, feature);

    // 4. Budget
    await checkBudget();

    // 5. Cache check
    const cached = await getCache(cacheKey);
    if (cached) {
      logger.info('Cache hit (image)', { uid, feature, cacheKey });
      return cached;
    }

    // 6. Call SiliconFlow (primary) → Replicate (fallback)
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
          replicateError: repError.message,
        });
        throw new HttpsError('internal', 'Image generation failed on all providers.', {
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

    // 7. Cache store
    await setCache(cacheKey, response);

    // 8. Increment usage
    await incrementUsage(uid, feature);

    // 9. Add cost
    await addCost(cost);

    // 10. Log
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
    timeoutSeconds: 30,
    memory: '256MiB',
  },
  async (request) => {
    const startTime = Date.now();
    const { action, videoUrlOrId, channelId, query, maxResults } = request.data;

    // 1. Auth
    const uid = await verifyAuth(request);

    // 2. Rate limit
    await checkRateLimit(uid);

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
          throw new HttpsError('invalid-argument', `Unknown action: ${action}`);
      }
    } catch (error) {
      logger.error('analyzeSeo failed', { uid, action, error: error.message });
      throw new HttpsError('internal', error.message || 'YouTube request failed.', {
        errorCode: 'API_ERROR',
      });
    }
  }
);
