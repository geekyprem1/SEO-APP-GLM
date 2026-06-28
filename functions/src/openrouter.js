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
  let json = null;

  if (schema) {
    try {
      json = JSON.parse(rawText);
    } catch {
      const match = rawText.match(/\{[\s\S]*\}/);
      if (match) {
        try {
          json = JSON.parse(match[0]);
        } catch {
          // Leave json null; caller handles.
        }
      }
    }
  }

  const tokensUsed = completion.usage?.total_tokens ?? 0;

  return { rawText, json, tokensUsed, model };
}

module.exports = { generateText, DEFAULT_MODEL: DEFAULTS.text_model };
