// screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import 'auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  // Define a list of predefined theme colors (hex codes for clarity)
  static const List<Color> _themeColors = [
    Color(0xFF6C63FF), // Your existing primary (Purple-Blue)
    Color(0xFF4CAF50), // Green (e.g., from Scheme 2)
    Color(0xFFFF6F00), // Orange (e.g., from Scheme 3)
    Color(0xFF2196F3), // Blue
    Color(0xFF9C27B0), // Deep Purple
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          // --- Appearance Section ---
          _buildSectionTitle(context, 'Appearance'),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.dark_mode),
                    title: const Text('Dark Mode'),
                    subtitle: Text(
                      _getThemeModeString(themeProvider.themeMode),
                    ),
                    trailing: PopupMenuButton<ThemeMode>(
                      onSelected: (ThemeMode mode) {
                        themeProvider.setThemeMode(mode);
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: ThemeMode.system,
                          child: Text('System'),
                        ),
                        const PopupMenuItem(
                          value: ThemeMode.light,
                          child: Text('Light'),
                        ),
                        const PopupMenuItem(
                          value: ThemeMode.dark,
                          child: Text('Dark'),
                        ),
                      ],
                      child: const Icon(Icons.arrow_drop_down),
                    ),
                  ),
                  // NEW: Theme Colors Selection
                  ListTile(
                    leading: const Icon(Icons.color_lens),
                    title: const Text('App Color'),
                    subtitle: Text(
                      'Current: #${themeProvider.primarySeedColor.value.toRadixString(16).substring(2).toUpperCase()}',
                    ),
                    trailing: SizedBox(
                      width:
                          200, // <--- FIXED: Increased width to prevent overflow
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: _themeColors.map((color) {
                          return GestureDetector(
                            onTap: () {
                              themeProvider.setPrimarySeedColor(color);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        themeProvider.primarySeedColor.value ==
                                            color
                                                .value // Compare color values
                                        ? Theme.of(context)
                                              .colorScheme
                                              .onSurface // Highlight selected color
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child:
                                    themeProvider.primarySeedColor.value ==
                                        color.value
                                    ? Icon(
                                        Icons.check,
                                        size: 20,
                                        color: color.computeLuminance() > 0.5
                                            ? Colors.black
                                            : Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const Divider(),
          // --- Units Section ---
          _buildSectionTitle(context, 'Units'),
          Consumer<SettingsProvider>(
            builder: (context, settingsProvider, child) {
              return ListTile(
                leading: const Icon(Icons.fitness_center),
                title: const Text('Weight Unit'),
                subtitle: Text(settingsProvider.weightUnit.name.toUpperCase()),
                trailing: Switch(
                  value: settingsProvider.weightUnit == WeightUnit.lb,
                  onChanged: (value) {
                    settingsProvider.setWeightUnit(
                      value ? WeightUnit.lb : WeightUnit.kg,
                    );
                  },
                ),
              );
            },
          ),
          const Divider(),
          // --- Account Section ---
          _buildSectionTitle(context, 'Account'),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Email'),
                subtitle: Text(authProvider.user?.email ?? 'Not logged in'),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            onTap: () => _showSignOutDialog(context),
          ),
          const Divider(),
          // --- App Info Section ---
          _buildSectionTitle(context, 'App Info'),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Rate App'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thanks for your feedback!')),
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper methods (unchanged)
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getThemeModeString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
