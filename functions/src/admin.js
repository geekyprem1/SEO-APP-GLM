/**
 * Admin role management for the Tubora Admin console.
 *
 * setAdminRole — callable. Only a super_admin may grant/revoke admin roles.
 * Sets custom claims { admin, role, v } on the target user, mirrors to the
 * admins/{uid} doc, and writes an immutable adminLogs record.
 *
 * Bootstrap (first super_admin) is done ONCE via the Functions shell — see
 * the admin repo README runbook. This callable refuses to run for non-admins.
 */

const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { admin, db } = require('./utils');

const ROLES = ['super_admin', 'admin', 'moderator', 'support'];

exports.setAdminRole = onCall({ timeoutSeconds: 30, memory: '256MiB' }, async (request) => {
  const caller = request.auth;
  if (!caller) throw new HttpsError('unauthenticated', 'Sign in required.');

  // Caller must be a super_admin (verified from their token claims).
  if (caller.token.admin !== true || caller.token.role !== 'super_admin') {
    throw new HttpsError('permission-denied', 'Super admin only.');
  }

  const { targetUid, role, revoke } = request.data || {};
  if (!targetUid) throw new HttpsError('invalid-argument', 'targetUid required.');
  if (!revoke && !ROLES.includes(role)) {
    throw new HttpsError('invalid-argument', `role must be one of ${ROLES.join(', ')}`);
  }
  if (targetUid === caller.uid && (revoke || role !== 'super_admin')) {
    throw new HttpsError('failed-precondition', 'You cannot demote/revoke yourself.');
  }

  const user = await admin.auth().getUser(targetUid).catch(() => null);
  if (!user) throw new HttpsError('not-found', 'Target user not found.');

  const beforeSnap = await db.collection('admins').doc(targetUid).get();
  const before = beforeSnap.exists ? beforeSnap.data() : null;

  if (revoke) {
    await admin.auth().setCustomUserClaims(targetUid, null);
    await db.collection('admins').doc(targetUid).delete();
  } else {
    const v = (before?.v ?? 0) + 1;
    await admin.auth().setCustomUserClaims(targetUid, { admin: true, role, v });
    await db.collection('admins').doc(targetUid).set(
      {
        email: user.email || null,
        role,
        v,
        disabled: false,
        updatedBy: caller.uid,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
  }

  await db.collection('adminLogs').add({
    adminUid: caller.uid,
    adminEmail: caller.token.email || null,
    adminRole: 'super_admin',
    action: revoke ? 'admin.revoke' : 'admin.setRole',
    targetType: 'admin',
    targetId: targetUid,
    before,
    after: revoke ? null : { role },
    outcome: 'success',
    ip: request.rawRequest?.ip || 'unknown',
    userAgent: request.rawRequest?.headers?.['user-agent'] || 'unknown',
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { ok: true };
});
