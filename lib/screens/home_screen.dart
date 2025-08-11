import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Import for date formatting and time-based greetings
import 'dart:math'; // Import for random number generation for emoji/quote

import '../providers/workout_provider.dart';
import '../providers/settings_provider.dart'; // Keep if used elsewhere, not strictly for this change
import '../providers/auth_provider.dart'; // NEW: Import AuthProvider to get user name
import '../widgets/workout_card.dart';
import 'add_workout_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  // List of emojis to pick from
  static const List<String> _emojis = [
    '☀️',
    '🌤️',
    '🌇',
    '🌙',
    '💪',
    '🚀',
    '🌟',
  ];

  // List of motivational quotes
  static const List<String> _quotes = [
    "The only bad workout is the one that didn't happen.",
    "Believe you can and you're halfway there.",
    "The body achieves what the mind believes.",
    "Strive for progress, not perfection.",
    "Your fitness is 100% mental. Your body won't go where your mind doesn't push it.",
    "Success usually comes to those who are too busy to be looking for it.",
    "It's hard to beat a person who never gives up.",
    "Strength does not come from physical capacity. It comes from an indomitable will.",
    "Today's actions are tomorrow's results.",
    "The journey of a thousand miles begins with a single step.",
  ];

  // Helper method to get the greeting based on time
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else if (hour < 21) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  // Helper method to get a random emoji
  String _getRandomEmoji() {
    final random = Random();
    return _emojis[random.nextInt(_emojis.length)];
  }

  // Helper method to get a random motivational quote
  String _getRandomQuote() {
    final random = Random();
    return _quotes[random.nextInt(_quotes.length)];
  }

  @override
  Widget build(BuildContext context) {
    // Access providers
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: true);
    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    ); // Listen: false as we only need the user data once for greeting

    // Trigger loading of workouts if they haven't been loaded yet.
    // This runs once after the first frame is rendered, ensuring data is fetched.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!workoutProvider.isLoading && workoutProvider.workouts.isEmpty) {
        print('HomeScreen: Triggering loadWorkouts...');
        workoutProvider.loadWorkouts();
      }
    });

    // Get the user's display name or use a default
    final String userName =
        authProvider.user?.displayName ??
        authProvider.user?.email?.split('@').first ??
        'Fitness Enthusiast';
    final String greeting = _getGreeting();
    final String emoji = _getRandomEmoji();
    final String quote = _getRandomQuote();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        // Use Column to place greeting above the workout list
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting Section
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, $userName $emoji',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '"$quote"',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Workout History Title
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Text(
              'Workout History',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          // Separator
          const Divider(height: 1, indent: 16, endIndent: 16),
          // Expanded to make the ListView fill the remaining space
          Expanded(
            child: Consumer<WorkoutProvider>(
              // Using nested consumer for loading/empty state
              builder: (context, workoutProvider, child) {
                if (workoutProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (workoutProvider.workouts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No workouts yet',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start your fitness journey today!',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: workoutProvider.loadWorkouts,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ), // Adjust padding
                    itemCount: workoutProvider.workouts.length,
                    itemBuilder: (context, index) {
                      // Pass workout details to WorkoutCard
                      return WorkoutCard(
                        workout: workoutProvider.workouts[index],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddWorkoutScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Workout'),
      ),
    );
  }
}
