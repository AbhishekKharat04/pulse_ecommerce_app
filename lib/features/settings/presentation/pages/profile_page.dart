import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../bloc/theme_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User Card
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final user = state is Authenticated ? state.user : null;

                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.primary.withOpacity(0.15),
                        child: Text(
                          user != null
                              ? user.displayName.substring(0, 1).toUpperCase()
                              : 'G',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user != null ? user.displayName : 'Guest User',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user != null ? user.email : 'Sign in to sync your cart & orders',
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      if (user == null)
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginPage()),
                            );
                          },
                          child: const Text('Login'),
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                          tooltip: 'Sign Out',
                          onPressed: () {
                            context.read<AuthBloc>().add(SignOutRequestedEvent());
                          },
                        ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Settings Section
            _buildSectionHeader('Preferences & Appearance'),
            const SizedBox(height: 10),

            _buildTileContainer(
              isDark: isDark,
              children: [
                BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, state) {
                    return SwitchListTile.adaptive(
                      title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Switch between light and dark themes'),
                      secondary: Icon(
                        state.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        color: AppColors.primary,
                      ),
                      value: state.isDarkMode,
                      activeColor: AppColors.primary,
                      onChanged: (_) {
                        context.read<ThemeBloc>().add(ToggleThemeEvent());
                      },
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.cleaning_services_rounded, color: AppColors.primary),
                  title: const Text('Clear Offline Cache', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Reset locally saved JSON products & images'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () async {
                    final sp = sl<SharedPreferences>();
                    await sp.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Offline cache cleared successfully!')),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Architecture & Internship Specs
            _buildSectionHeader('Internship Architecture Spec'),
            const SizedBox(height: 10),

            _buildTileContainer(
              isDark: isDark,
              children: [
                _buildTechSpecRow(
                  icon: Icons.layers_outlined,
                  title: 'Clean Architecture',
                  subtitle: 'Domain, Data, and Presentation separation with Repositories',
                ),
                const Divider(height: 1),
                _buildTechSpecRow(
                  icon: Icons.architecture_rounded,
                  title: 'BLoC Pattern',
                  subtitle: 'Event-driven state management with Equatable',
                ),
                const Divider(height: 1),
                _buildTechSpecRow(
                  icon: Icons.api_rounded,
                  title: 'REST API & Caching',
                  subtitle: 'HTTP client, error mapping, and SharedPreferences fallback',
                ),
                const Divider(height: 1),
                _buildTechSpecRow(
                  icon: Icons.notifications_active_outlined,
                  title: 'Firebase & FCM',
                  subtitle: 'Token registration, message stream, and topic routing',
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              'PulseMarket v1.0.0 • Built with Flutter & Dart',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTileContainer({required bool isDark, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTechSpecRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    );
  }
}
