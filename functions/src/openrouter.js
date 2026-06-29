/**
 * OpenRouter AI provider — text generation.
 * Model is read from Firebase Remote Config at runtime — no redeploy needed.
 *
 * To set the API key:
 *   firebase functions:secrets:set OPENROUTER_API_KEY
 *
 * To change the model without redeploying:
 *   Firebase Console → Remote Config → text_model
 *
 * OpenRouter supports ALL major providers via model name, e.g.:
 *   google/gemini-2.5-flash        → Google Gemini
 *   anthropic/claude-3-5-sonnet    → Anthropic Claude
 *   meta-llama/llama-3.1-70b-instruct → Meta Llama
 *   mistralai/mistral-large        → Mistral
 *   openai/gpt-4o                  → OpenAI GPT-4o
 */

const OpenAI = require('openai');
const logger = require('firebase-functions/logger');
const { getConfigValue, DEFAULTS } = require('./config');

const DEFAULT_MAX_TOKENS = 300;
const DEFAULT_TEMPERATURE = 0.7;

/**
 * Generates text via OpenRouter.
 * @param {object} params - { prompt, schema, maxTokens, temperature }
 * @returns {Promise<{rawText: string, json: object|null, tokensUsed: number, model: string}>}
 */
async function generateText({ prompt, schema, maxTokens, temperature }) {
  const apiKey = process.env.OPENROUTER_API_KEY;
  if (!apiKey) {
    throw new Error('OPENROUTER_API_KEY is not set. Run: firebase functions:secrets:set OPENROUTER_API_KEY');
  }

  // Fetch model from Remote Config (falls back to default if not set)
  const model = await getConfigValue('text_model');

  const client = new OpenAI({
    baseURL: 'https://openrouter.ai/api/v1',
    apiKey,
    defaultHeaders: {
      'HTTP-Referer': 'https://shortseo.ai',
      'X-Title': 'ShortSEO AI',
    },
  });

  const messages = [
    {
      role: 'system',
      content: schema
        ? `You are a helpful assistant. Respond ONLY with valid JSON matching this structure: ${schema}. No markdown, no extra text.`
        : 'You are a helpful assistant. Respond concisely.',
    },
    { role: 'user', content: prompt },
  ];

  const completion = await client.chat.completions.create({
    model,
    messages,
    max_tokens: maxTokens ?? DEFAULT_MAX_TOKENS,
    temperature: temperature ?? DEFAULT_TEMPERATURE,
    response_format: schema ? { type: 'json_object' } : undefined,
  });

  const rawText = completion.choices[0]?.message?.content ?? '';
  const finishReason = completion.choices[0]?.finish_reason;
  let json = null;

  if (schema) {
    json = extractJson(rawText);
    if (json === null) {
      logger.warn('Could not parse JSON from model output', {
        model,
        finishReason,
        preview: rawText.slice(0, 300),
      });
    }
  }

  const tokensUsed = completion.usage?.total_tokens ?? 0;

  return { rawText, json, tokensUsed, model };
}

/**
 * Robustly extracts a JSON object from a model response.
 * Handles ```json fences, leading/trailing prose, and stray whitespace.
 * Returns null if no valid JSON object can be parsed.
 */
function extractJson(text) {
  if (!text) return null;

  // 1. Strip markdown code fences (```json ... ``` or ``` ... ```).
  let cleaned = text.trim();
  const fence = cleaned.match(/```(?:json)?\s*([\s\S]*?)```/i);
  if (fence) cleaned = fence[1].trim();

  // 2. Direct parse.
  try {
    return JSON.parse(cleaned);
  } catch {
    // continue
  }

  // 3. Fallback: grab the outermost { ... } and parse.
  const start = cleaned.indexOf('{');
  const end = cleaned.lastIndexOf('}');
  if (start !== -1 && end > start) {
    try {
      return JSON.parse(cleaned.slice(start, end + 1));
    } catch {
      // continue
    }
  }

  return null;
}

module.exports = { generateText, DEFAULT_MODEL: DEFAULTS.text_model };
