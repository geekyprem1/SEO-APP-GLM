/**
 * Shared utilities for ShortSEO AI Cloud Functions.
 * Handles: auth verification, quota, budget, rate limit, cache, logging.
 */

const admin = require('firebase-admin');

// Initialize Firebase Admin once.
if (admin.apps.length === 0) {
  admin.initializeApp();
}

const db = admin.firestore();

// ─── Per-plan daily limits (per feature) ─────────────────────────────────
// Free users get 1 generation per feature per day; Pro users get 50.
// (These will be tuned later.)
const PLAN_LIMITS = {
  free: 1,
  pro: 50,
};

// ─── Rate limiting (1 request per 5 seconds) ─────────────────────────────
const RATE_LIMIT_SECONDS = 5;

// ─── Budget kill switch ──────────────────────────────────────────────────
const DEFAULT_MAX_COST = 5.0; // USD per day

// ─── Cache TTL ───────────────────────────────────────────────────────────
const CACHE_TTL_HOURS = 24;

// ─── Estimated costs per feature (USD) ───────────────────────────────────
const ESTIMATED_COSTS = {
  text: 0.0005,   // ~300 tokens Gemini 2.5 Flash
  image: 0.003,   // FLUX.1 Schnell 768x768
};

/**
 * Verifies the Firebase ID token and returns the uid.
 * Throws if unauthenticated.
 */
async function verifyAuth(context) {
  if (!context.auth) {
    throw new functionsHttpsError('unauthenticated', 'Authentication required.');
  }
  return context.auth.uid;
}

/**
 * Checks rate limit: max 1 request per RATE_LIMIT_SECONDS per user.
 */
async function checkRateLimit(uid) {
  const ref = db.collection('rateLimits').doc(uid);
  const snap = await ref.get();
  const now = Date.now();

  if (snap.exists) {
    const lastRequest = snap.data().lastRequest?.toMillis?.() ?? 0;
    const elapsed = (now - lastRequest) / 1000;
    if (elapsed < RATE_LIMIT_SECONDS) {
      throw new functionsHttpsError(
        'resource-exhausted',
        'Too many requests. Please wait a few seconds.',
        { errorCode: 'RATE_LIMIT' }
      );
    }
  }

  await ref.set({ lastRequest: admin.firestore.FieldValue.serverTimestamp() });
}

/**
 * Returns the user's plan ('free' | 'pro'). Defaults to 'free'.
 */
async function getUserPlan(uid) {
  const snap = await db.collection('users').doc(uid).get();
  const plan = snap.exists ? snap.data().plan : 'free';
  return plan === 'pro' ? 'pro' : 'free';
}

/**
 * Checks per-feature daily quota for the user, based on their plan.
 * Returns current count.
 */
async function checkQuota(uid, feature) {
  const plan = await getUserPlan(uid);
  const limit = PLAN_LIMITS[plan] ?? PLAN_LIMITS.free;

  const dateKey = new Date().toISOString().slice(0, 10); // yyyy-mm-dd
  const ref = db.collection('users').doc(uid).collection('usage').doc(dateKey);
  const snap = await ref.get();

  const current = snap.exists ? (snap.data()[feature] || 0) : 0;

  if (current >= limit) {
    throw new functionsHttpsError(
      'resource-exhausted',
      plan === 'pro'
        ? `Daily limit for ${feature} reached. Try tomorrow.`
        : `Free limit reached. Upgrade to Pro for more.`,
      { errorCode: 'QUOTA_EXCEEDED', feature, plan }
    );
  }

  return current;
}

/**
 * Increments the per-feature usage counter.
 */
async function incrementUsage(uid, feature) {
  const dateKey = new Date().toISOString().slice(0, 10);
  const ref = db.collection('users').doc(uid).collection('usage').doc(dateKey);

  await ref.set(
    { [feature]: admin.firestore.FieldValue.increment(1) },
    { merge: true }
  );
}

/**
 * Checks the global daily budget kill switch.
 */
async function checkBudget() {
  const ref = db.collection('config').doc('daily_budget');
  const snap = await ref.get();

  if (!snap.exists) return; // No budget config → allow.

  const data = snap.data();
  if (data.enabled === false) return;

  const maxCost = data.maxCost ?? DEFAULT_MAX_COST;
  const currentCost = data.currentCost ?? 0;

  if (currentCost >= maxCost) {
    throw new functionsHttpsError(
      'resource-exhausted',
      'Daily limit reached. Please try tomorrow.',
      { errorCode: 'BUDGET_EXCEEDED' }
    );
  }
}

/**
 * Adds to the daily cost counter.
 */
async function addCost(amount) {
  const ref = db.collection('config').doc('daily_budget');
  await ref.set(
    { currentCost: admin.firestore.FieldValue.increment(amount) },
    { merge: true }
  );
}

/**
 * Checks cache for a cached result. Returns null if not found / expired.
 */
async function getCache(cacheKey) {
  const ref = db.collection('cache').doc(cacheKey);
  const snap = await ref.get();

  if (!snap.exists) return null;

  const data = snap.data();
  const expiresAt = data.expiresAt?.toMillis?.() ?? 0;
  if (Date.now() > expiresAt) {
    await ref.delete();
    return null;
  }

  return data.result;
}

/**
 * Stores a result in cache with TTL.
 */
async function setCache(cacheKey, result) {
  const expiresAt = new Date(Date.now() + CACHE_TTL_HOURS * 60 * 60 * 1000);
  const ref = db.collection('cache').doc(cacheKey);
  await ref.set({
    cacheKey,
    result,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    expiresAt,
  });
}

/**
 * Logs a request to Firestore for analytics.
 */
async function logRequest({ uid, feature, model, tokens, cost, durationMs }) {
  await db.collection('logs').add({
    uid,
    feature,
    model,
    tokens: tokens || 0,
    cost: cost || 0,
    durationMs: durationMs || 0,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });
}

module.exports = {
  admin,
  db,
  verifyAuth,
  checkRateLimit,
  getUserPlan,
  checkQuota,
  incrementUsage,
  checkBudget,
  addCost,
  getCache,
  setCache,
  logRequest,
  ESTIMATED_COSTS,
};

// Helper to create HttpsError without importing functions in utils.
function functionsHttpsError(code, message, details) {
  // Lazy require to avoid circular deps.
  const { HttpsError } = require('firebase-functions/v2/https');
  return new HttpsError(code, message, details);
}
