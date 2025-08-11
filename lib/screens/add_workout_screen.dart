// screens/add_workout_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../providers/settings_provider.dart';
import '../models/workout.dart';

class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({Key? key}) : super(key: key);

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _workoutNameController = TextEditingController();
  final _durationController = TextEditingController();
  final List<ExerciseData> _exercises = [];

  @override
  void initState() {
    super.initState();
    _addExercise();
  }

  @override
  void dispose() {
    _workoutNameController.dispose();
    _durationController.dispose();
    for (var exercise in _exercises) {
      exercise.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Workout'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saveWorkout,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Workout Name
              TextFormField(
                controller: _workoutNameController,
                decoration: const InputDecoration(
                  labelText: 'Workout Name',
                  prefixIcon: Icon(Icons.fitness_center),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a workout name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Duration
              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  prefixIcon: Icon(Icons.timer),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter duration';
                  }
                  if (int.tryParse(value!) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Exercises Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Exercises',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addExercise,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Exercise'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Exercises List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _exercises.length,
                itemBuilder: (context, index) {
                  return _buildExerciseCard(index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseCard(int exerciseIndex) {
    final exercise = _exercises[exerciseIndex];

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise Name and Delete Button
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: exercise.nameController,
                    decoration: const InputDecoration(
                      labelText: 'Exercise Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter exercise name';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _removeExercise(exerciseIndex),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sets Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sets',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _addSet(exerciseIndex),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Set'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Sets List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: exercise.sets.length,
              itemBuilder: (context, setIndex) {
                return _buildSetRow(exerciseIndex, setIndex);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetRow(int exerciseIndex, int setIndex) {
    final setData = _exercises[exerciseIndex].sets[setIndex];
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Set Number
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${setIndex + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Reps Input
          Expanded(
            child: TextFormField(
              controller: setData.repsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Reps',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                if (int.tryParse(value!) == null) return 'Invalid';
                return null;
              },
            ),
          ),
          const SizedBox(width: 8),

          // Weight Input
          Expanded(
            child: TextFormField(
              controller: setData.weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Weight (${settingsProvider.weightUnit.name})',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                if (double.tryParse(value!) == null) return 'Invalid';
                return null;
              },
            ),
          ),
          const SizedBox(width: 8),

          // Delete Set Button
          IconButton(
            onPressed: () => _removeSet(exerciseIndex, setIndex),
            icon: const Icon(Icons.remove_circle, color: Colors.red),
          ),
        ],
      ),
    );
  }

  void _addExercise() {
    setState(() {
      _exercises.add(ExerciseData());
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises[index].dispose();
      _exercises.removeAt(index);
    });
  }

  void _addSet(int exerciseIndex) {
    setState(() {
      _exercises[exerciseIndex].sets.add(SetData());
    });
  }

  void _removeSet(int exerciseIndex, int setIndex) {
    setState(() {
      _exercises[exerciseIndex].sets[setIndex].dispose();
      _exercises[exerciseIndex].sets.removeAt(setIndex);
    });
  }

  void _saveWorkout() async {
    if (_formKey.currentState?.validate() ?? false) {
      final workoutProvider = Provider.of<WorkoutProvider>(
        context,
        listen: false,
      );

      final exercises = _exercises.map((exerciseData) {
        final sets = exerciseData.sets.map((setData) {
          return Set(
            reps: int.parse(setData.repsController.text),
            weight: double.parse(setData.weightController.text),
          );
        }).toList();

        return Exercise(name: exerciseData.nameController.text, sets: sets);
      }).toList();

      final workout = Workout(
        name: _workoutNameController.text,
        date: DateTime.now(),
        exercises: exercises,
        duration: int.parse(_durationController.text),
      );

      await workoutProvider.addWorkout(workout);
      Navigator.pop(context);
    }
  }
}

class ExerciseData {
  final TextEditingController nameController = TextEditingController();
  final List<SetData> sets = [SetData()];

  void dispose() {
    nameController.dispose();
    for (var set in sets) {
      set.dispose();
    }
  }
}

class SetData {
  final TextEditingController repsController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  void dispose() {
    repsController.dispose();
    weightController.dispose();
  }
}
