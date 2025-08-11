//providers/workout_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/workout.dart';

class WorkoutProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Workout> _workouts = [];
  bool _isLoading = false;

  List<Workout> get workouts => _workouts;
  bool get isLoading => _isLoading;

  Future<void> loadWorkouts() async {
    if (_auth.currentUser == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('workouts')
          .orderBy('date', descending: true)
          .get();

      _workouts = snapshot.docs.map((doc) => Workout.fromJson({
        'id': doc.id,
        ...doc.data(),
      })).toList();
    } catch (e) {
      print('Error loading workouts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addWorkout(Workout workout) async {
    if (_auth.currentUser == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('workouts')
          .add(workout.toJson());
      await loadWorkouts();
    } catch (e) {
      print('Error adding workout: $e');
    }
  }

  Future<void> deleteWorkout(String workoutId) async {
    if (_auth.currentUser == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('workouts')
          .doc(workoutId)
          .delete();
      await loadWorkouts();
    } catch (e) {
      print('Error deleting workout: $e');
    }
  }
}