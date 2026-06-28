import 'package:flutter/material.dart';

import '../../../core/widgets/common/empty_state.dart';

/// Tab 3 placeholder — a future "Create" workflow to be built later.
class CreatePlaceholderScreen extends StatelessWidget {
  const CreatePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: EmptyState(
          icon: Icons.add_circle_outline_rounded,
          title: 'Create — Coming Soon',
          subtitle: 'A new creation workflow will live here in an upcoming update.',
        ),
      ),
    );
  }
}
