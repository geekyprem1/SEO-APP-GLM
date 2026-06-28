import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/common/empty_state.dart';

/// Placeholder screen for features not yet implemented.
/// Shown until each feature is built in its milestone.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(title),
      ),
      body: EmptyState(
        icon: Icons.construction_rounded,
        title: '$title — Coming Soon',
        subtitle: 'This feature is being built and will be available in an upcoming update.',
        actionLabel: 'Go back',
        onAction: () => context.pop(),
      ),
    );
  }
}
