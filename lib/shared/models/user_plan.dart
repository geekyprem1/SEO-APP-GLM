import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/auth_provider.dart';

/// The user's subscription plan.
enum UserPlan {
  free('Free'),
  pro('Pro');

  const UserPlan(this.label);
  final String label;

  bool get isPro => this == UserPlan.pro;
  bool get isFree => this == UserPlan.free;

  static UserPlan fromString(String? value) =>
      value == 'pro' ? UserPlan.pro : UserPlan.free;
}

/// Pricing (display only for now; payment wired later via Play Store).
const int kProPriceRupees = 299;

/// Streams the current user's plan from `users/{uid}.plan`.
/// Falls back to [UserPlan.free] when signed out or the field is missing.
final userPlanProvider = StreamProvider<UserPlan>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) {
    return Stream.value(UserPlan.free);
  }
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((snap) => UserPlan.fromString(snap.data()?['plan'] as String?));
});

/// Sets the current user's plan in Firestore.
///
/// Used by the hidden test toggle until real Play Store billing is wired.
Future<void> setUserPlan(String uid, UserPlan plan) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .set({'plan': plan.isPro ? 'pro' : 'free'}, SetOptions(merge: true));
}
