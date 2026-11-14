import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers/auth_provider.dart';
import '../../app/router/app_routes.dart';
import '../../data/api/app_exception.dart';
import '../../data/models/models.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _refresh(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authStateProvider.notifier).refreshUser();
    } on AppException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  // Onaydan sonra oturum kapanır; router giriş ekranına yönlendirir.
  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış yapılsın mı?'),
        content: const Text(
          'Bu cihazdaki oturumun kapanacak; tekrar giriş yapman gerekecek.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Çıkış yap'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authStateProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider.select((s) => s.user));
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: RefreshIndicator(
        onRefresh: () => _refresh(context, ref),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            if (user != null) _ProfileHeader(user: user),
            const Divider(),
            // Hafta 6 (Barış): İlanlarım ve Taleplerim ekranlarına git.
            const ListTile(
              enabled: false,
              leading: Icon(Icons.inventory_2_outlined),
              title: Text('İlanlarım'),
              subtitle: Text('Yakında'),
            ),
            const ListTile(
              enabled: false,
              leading: Icon(Icons.assignment_outlined),
              title: Text('Taleplerim'),
              subtitle: Text('Yakında'),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Ayarlar'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.settings),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: colors.error),
              title: Text('Çıkış yap', style: TextStyle(color: colors.error)),
              onTap: () => _confirmSignOut(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ad, e-posta ve öğrenci no (`/api/auth/me`).
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final User user;

  String get _initials => user.fullName
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .map((w) => w.characters.first)
      .take(2)
      .join();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final studentNo = user.studentNo;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: colors.primaryContainer,
            child: Text(
              _initials,
              style: theme.textTheme.titleLarge?.copyWith(
                color: colors.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.fullName, style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                if (studentNo != null && studentNo.isNotEmpty)
                  Text(
                    'Öğrenci no: $studentNo',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
