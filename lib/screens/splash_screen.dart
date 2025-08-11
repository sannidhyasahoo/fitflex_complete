// screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math'; // NEW: Import for random number generation

import '../providers/auth_provider.dart';
import 'auth/login_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // List of motivational quotes (reused from HomeScreen for consistency)
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

  // Store the randomly selected quote
  String _randomQuote = '';

  @override
  void initState() {
    super.initState();
    _setRandomQuote(); // NEW: Set a random quote when the state initializes
    _navigateToHome();
  }

  // NEW: Method to select a random quote
  void _setRandomQuote() {
    final random = Random();
    setState(() {
      _randomQuote = _quotes[random.nextInt(_quotes.length)];
    });
  }

  _navigateToHome() async {
    // It's good practice to ensure initial provider data is loaded before navigating
    // especially if MainScreen depends on it immediately.
    // authProvider.isLoggedIn would have finished initializing due to Firebase.initializeApp in main.
    await Future.delayed(
      const Duration(seconds: 2),
    ); // Display splash screen for 2 seconds
    if (mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => authProvider.isLoggedIn
              ? const MainScreen()
              : const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fitness_center, size: 80, color: Colors.white),
              const SizedBox(height: 20),
              Text(
                'FitFlex',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Track Your Progress',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 30), // NEW: More space before the quote
              // NEW: Display the random quote
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  _randomQuote.isEmpty
                      ? 'Loading inspiration...'
                      : '"$_randomQuote"', // Display quote, or placeholder
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.white.withOpacity(
                      0.9,
                    ), // Slightly transparent white
                  ),
                ),
              ),
              const SizedBox(height: 20), // NEW: Space after the quote
            ],
          ),
        ),
      ),
    );
  }
}
