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

/**
 * Fetches the latest Remote Config template and returns the value
 * for the given key. Falls back to DEFAULTS if anything goes wrong.
 *
 * @param {string} key - Remote Config parameter key
 * @returns {Promise<string>}
 */
async function getConfigValue(key) {
  try {
    const rc = getRemoteConfig();
    const template = await rc.getServerTemplate();
    const value = template.defaultConfig[key];
    if (value !== undefined && value !== '') return String(value);
  } catch (err) {
    logger.warn(`Remote Config fetch failed for key "${key}", using default.`, {
      error: err.message,
    });
  }
  return DEFAULTS[key];
}

module.exports = { getConfigValue, DEFAULTS };
