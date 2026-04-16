import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/services/session_service.dart';
import 'profile_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    final session = Get.find<SessionService>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(() {
              final user = session.currentUser.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'Unknown user',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(user?.email ?? 'No email'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text(user?.role ?? 'No role')),
                      for (final scope in user?.scopes ?? <String>[])
                        Chip(label: Text(scope)),
                    ],
                  ),
                ],
              );
            }),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          child: Obx(
            () => SwitchListTile(
              title: const Text('Queue approval notifications'),
              subtitle: const Text(
                'Another reactive toggle for the audit sample.',
              ),
              value: controller.notificationsEnabled.value,
              onChanged: (value) =>
                  controller.notificationsEnabled.value = value,
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: controller.showSupportSheet,
          icon: const Icon(Icons.support_agent_rounded),
          label: const Text('Support actions'),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: controller.confirmLogout,
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Logout'),
        ),
      ],
    );
  }
}
