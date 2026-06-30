/**
 * Replicate image provider — model is read from Firebase Remote Config at runtime.
 * API key is stored server-side.
 *
 * To set the API key:
 *   firebase functions:secrets:set REPLICATE_API_TOKEN
 *
 * To change the model without redeploying:
 *   Firebase Console → Remote Config → image_model_replicate
 */

const Replicate = require('replicate');
const { getConfigValue, DEFAULTS } = require('./config');

const DEFAULT_WIDTH = 768;
const DEFAULT_HEIGHT = 768;

/**
 * FLUX.1 Schnell on Replicate does NOT accept raw width/height — it only takes
 * an `aspect_ratio` from a fixed set. Map the requested pixels to the closest
 * supported ratio so thumbnails come out 16:9 / 9:16 instead of square.
 */
function toAspectRatio(width, height) {
  const r = width / height;
  if (Math.abs(r - 16 / 9) < 0.06) return '16:9';
  if (Math.abs(r - 9 / 16) < 0.06) return '9:16';
  if (r >= 1) return '16:9';
  return '9:16';
}

/**
 * Generates an image via Replicate.
 * @param {object} params - { prompt, width, height }
 * @returns {Promise<{imageUrl: string, width: number, height: number, model: string}>}
 */
async function generateImage({ prompt, width, height }) {
  const apiToken = process.env.REPLICATE_API_TOKEN;
  if (!apiToken) {
    throw new Error('REPLICATE_API_TOKEN is not set. Run: firebase functions:secrets:set REPLICATE_API_TOKEN');
  }

  // Fetch model from Remote Config (falls back to default if not set)
  const model = await getConfigValue('image_model_replicate');

  const replicate = new Replicate({ auth: apiToken });

  const w = width ?? DEFAULT_WIDTH;
  const h = height ?? DEFAULT_HEIGHT;

  const output = await replicate.run(model, {
    input: {
      prompt,
      aspect_ratio: toAspectRatio(w, h),
      num_outputs: 1,
      output_format: 'png',
      // Largest quality tier so 16:9 output stays ≥1280px wide (YouTube min).
      megapixels: '1',
      go_fast: true,
    },
  });

  // FLUX returns an array of image URLs.
  const imageUrl = Array.isArray(output) ? output[0] : output;

  return { imageUrl, width: w, height: h, model };
}

module.exports = { generateImage, DEFAULT_MODEL: DEFAULTS.image_model_replicate };
