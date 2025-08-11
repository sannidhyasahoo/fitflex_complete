import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // NEW: Import Firestore

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // NEW: Firestore instance
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
      // Optional: If user signs in/up, fetch their additional data
      if (user != null) {
        _fetchUserData(user.uid); // Fetch user data after login/signup
      }
    });
  }

  // Method to fetch user data (NEW - could be more sophisticated)
  Future<void> _fetchUserData(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (userDoc.exists) {
        // You would typically store this data in a local model or another provider
        // For simplicity, just printing here.
        print('User Data: ${userDoc.data()}');
        // Example: _currentUserProfile = UserProfile.fromFirestore(userDoc.data() as Map<String, dynamic>);
        // then notifyListeners() if you want UI to react to profile data
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Modified signUp method to accept name, sex, dob
  Future<String?> signUp(
    String email,
    String password,
    String name, // NEW
    String sex, // NEW
    DateTime dob, // NEW
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      // 1. Create user with email and password
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // 2. Get the UID of the newly created user
      User? newUser = userCredential.user;
      if (newUser != null) {
        // 3. Store additional user data in Cloud Firestore
        await _firestore.collection('users').doc(newUser.uid).set({
          'email': email,
          'name': name,
          'sex': sex,
          'dob': dob, // Firestore can store DateTime directly
          'createdAt': FieldValue.serverTimestamp(), // Optional: timestamp
        });
      }

      return null; // Sign-up successful
    } on FirebaseAuthException catch (e) {
      // If Firebase Auth fails, return its message
      return e.message;
    } catch (e) {
      // Catch any other errors (e.g., Firestore write errors)
      return "An unexpected error occurred: $e";
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify UI that loading has finished
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
