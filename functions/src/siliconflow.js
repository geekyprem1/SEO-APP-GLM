/**
 * SiliconFlow image provider — model is read from Firebase Remote Config at runtime.
 * Uses the OpenAI-compatible endpoint so no extra dependency is needed.
 *
 * To set the API key:
 *   firebase functions:secrets:set SILICONFLOW_API_KEY
 *
 * To change the model without redeploying:
 *   Firebase Console → Remote Config → image_model_siliconflow
 *
 * Docs: https://docs.siliconflow.com/en/api-reference/images/images-generations
 */

const { OpenAI } = require('openai');
const { getConfigValue, DEFAULTS } = require('./config');

const DEFAULT_WIDTH = 768;
const DEFAULT_HEIGHT = 768;

/**
 * Generates an image via SiliconFlow.
 * @param {object} params - { prompt, width, height }
 * @returns {Promise<{imageUrl: string, width: number, height: number, provider: string, model: string}>}
 */
async function generateImage({ prompt, width, height }) {
  const apiKey = process.env.SILICONFLOW_API_KEY;
  if (!apiKey) {
    throw new Error('SILICONFLOW_API_KEY is not set. Run: firebase functions:secrets:set SILICONFLOW_API_KEY');
  }

  // Fetch model from Remote Config (falls back to default if not set)
  const model = await getConfigValue('image_model_siliconflow');

  const client = new OpenAI({
    apiKey,
    baseURL: 'https://api.siliconflow.com/v1',
  });

  const w = width ?? DEFAULT_WIDTH;
  const h = height ?? DEFAULT_HEIGHT;

  const response = await client.images.generate({
    model,
    prompt,
    image_size: `${w}x${h}`,
    num_inference_steps: 4,
    output_format: 'png',
    n: 1,
  });

  const imageUrl = response.data[0]?.url;
  if (!imageUrl) {
    throw new Error('SiliconFlow returned no image URL.');
  }

  return { imageUrl, width: w, height: h, provider: 'siliconflow', model };
}

module.exports = { generateImage, DEFAULT_MODEL: DEFAULTS.image_model_siliconflow };
