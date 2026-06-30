/**
 * Remote Config helper — reads image model names at runtime.
 *
 * Keys to set in Firebase Console → Remote Config:
 *   image_model_siliconflow  →  black-forest-labs/FLUX.1-schnell
 *   image_model_replicate    →  black-forest-labs/flux-schnell
 *
 * If a key is missing or Remote Config fetch fails, hardcoded defaults are used.
 */

const { getRemoteConfig } = require('firebase-admin/remote-config');
const logger = require('firebase-functions/logger');

const DEFAULTS = {
  // Text generation
  text_model: 'google/gemini-2.5-flash',

  // Image generation
  image_model_siliconflow: 'black-forest-labs/FLUX.1-schnell',
  image_model_replicate: 'black-forest-labs/flux-schnell',
};

// Cache the fetched template params briefly. Cloud Functions instances are
// reused, so this avoids a Remote Config fetch on every single request while
// still picking up Console changes within a few minutes.
let _cache = { params: null, at: 0 };
const CACHE_MS = 5 * 60 * 1000; // 5 minutes

/**
 * Returns the published Remote Config value for the given key, read from the
 * project's (client) template — the one edited in Firebase Console → Remote
 * Config. Falls back to DEFAULTS on error or if the key is unset/empty.
 *
 * @param {string} key - Remote Config parameter key
 * @returns {Promise<string>}
 */
async function getConfigValue(key) {
  try {
    const now = Date.now();
    if (!_cache.params || now - _cache.at > CACHE_MS) {
      const template = await getRemoteConfig().getTemplate();
      _cache = { params: template.parameters || {}, at: now };
    }
    const param = _cache.params[key];
    const value =
      param && param.defaultValue ? param.defaultValue.value : undefined;
    if (value !== undefined && value !== '') return String(value);
  } catch (err) {
    logger.warn(`Remote Config fetch failed for key "${key}", using default.`, {
      error: err.message,
    });
  }
  return DEFAULTS[key];
}

module.exports = { getConfigValue, DEFAULTS };
