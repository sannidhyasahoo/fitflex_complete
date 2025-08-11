// screens/about_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About FitFlex'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // App Logo and Info
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'FitFlex',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your Personal Fitness Companion',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Version 1.2.0',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Features
            _buildSection(context, 'Features', [
              _buildFeatureItem(
                context,
                Icons.track_changes,
                'Track Workouts',
                'Log and monitor your exercise sessions',
              ),
              _buildFeatureItem(
                context,
                Icons.bar_chart,
                'Progress Charts',
                'Visualize your fitness journey with beautiful charts',
              ),
              _buildFeatureItem(
                context,
                Icons.dark_mode,
                'Dark Mode',
                'Easy on the eyes with dark theme support',
              ),
              _buildFeatureItem(
                context,
                Icons.swap_horiz,
                'Unit Conversion',
                'Switch between metric and imperial units',
              ),
              _buildFeatureItem(
                context,
                Icons.security,
                'Secure Sync',
                'Your data is safely backed up with Firebase',
              ),
            ]),

            const SizedBox(height: 24),

            // Mission
            _buildSection(context, 'Our Mission', [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'FitFlex is designed to make fitness tracking simple, beautiful, and motivating. We believe that everyone deserves access to tools that help them achieve their health and wellness goals.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ]),
            _buildSection(context, 'Who are we ?', [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'FitFlex an awesome app to track workout developed by \nSannidhya Sahoo [1MS24IS108]\nand\nMohammad Shadab [1MS24EE035]\nas Final project of Intra-Institutional Internship of Mobile App Development for the year 2024-25. ',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ]),

            const SizedBox(height: 24),

            // Contact & Support
            _buildSection(context, 'Contact & Support', [
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email Support'),
                subtitle: const Text('sannidhyasahoo@gmail.com'),
                onTap: () async {
                  // Make onTap async
                  final Uri emailLaunchUri = Uri(
                    scheme: 'mailto',
                    path: 'sannidhyasahoo@gmail.com',
                    queryParameters: {
                      'subject':
                          'FitFlex App Support Request', // Pre-fill subject
                      'body':
                          'Dear Support Team,\n\nI am writing to report...', // Pre-fill body
                    },
                  );
                  // Check if the email client can be launched
                  if (await canLaunchUrl(emailLaunchUri)) {
                    await launchUrl(emailLaunchUri);
                  } else {
                    // Fallback if no email client is available
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not launch email client.'),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.bug_report),
                title: const Text('Report Bug'),
                subtitle: const Text('Help us improve the app'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Thank you for helping us improve!'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Rate FitFlex'),
                subtitle: const Text('Show your support on the app store'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thanks for your support!')),
                  );
                },
              ),
            ]),

            const SizedBox(height: 24),

            // Credits
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Crafted in 🇮🇳 with ❤️',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '© 2025 FitFlex. All rights reserved.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(description),
    );
  }
}
