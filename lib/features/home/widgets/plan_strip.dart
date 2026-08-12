import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../shared/models/user_plan.dart';
import '../../pro/widgets/pro_upgrade_dialog.dart';

/// Compact plan badge under the home hero — soft copy only (no exact quota).
class PlanStrip extends ConsumerWidget {
  const PlanStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(userPlanProvider).valueOrNull ?? UserPlan.free;
    final isPro = plan.isPro;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isPro
            ? null
            : () => showProUpgradeDialog(
                  context,
                  reason: ProUpgradeReason.explore,
                ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm + 2,
          ),
          decoration: BoxDecoration(
            color: isPro ? AppColors.primarySoft : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(
              color: isPro
                  ? AppColors.primary.withValues(alpha: 0.25)
                  : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isPro ? AppColors.primary : AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
                child: Text(
                  isPro ? 'Pro' : 'Free',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isPro ? Colors.white : AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  isPro
                      ? 'Full access · higher daily limits'
                      : 'Free plan · resets daily',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              if (!isPro) ...[
                const SizedBox(width: AppSizes.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                  child: Text(
                    'Pro',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
