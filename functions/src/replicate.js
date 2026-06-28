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
      width: w,
      height: h,
      num_outputs: 1,
      output_format: 'png',
      go_fast: true,
    },
  });

  // FLUX returns an array of image URLs.
  const imageUrl = Array.isArray(output) ? output[0] : output;

  return { imageUrl, width: w, height: h, model };
}

module.exports = { generateImage, DEFAULT_MODEL: DEFAULTS.image_model_replicate };
