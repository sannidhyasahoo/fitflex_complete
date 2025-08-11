class Workout {
  final String? id;
  final String name;
  final DateTime date;
  final List<Exercise> exercises;
  final int duration; // in minutes

  Workout({
    this.id,
    required this.name,
    required this.date,
    required this.exercises,
    required this.duration,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'date': date.toIso8601String(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'duration': duration,
    };
  }

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'],
      name: json['name'],
      date: DateTime.parse(json['date']),
      exercises: (json['exercises'] as List)
          .map((e) => Exercise.fromJson(e))
          .toList(),
      duration: json['duration'],
    );
  }
}

class Exercise {
  final String name;
  final List<Set> sets;

  Exercise({required this.name, required this.sets});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sets': sets.map((s) => s.toJson()).toList(),
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'],
      sets: (json['sets'] as List).map((s) => Set.fromJson(s)).toList(),
    );
  }
}

class Set {
  final int reps;
  final double weight;

  Set({required this.reps, required this.weight});

  Map<String, dynamic> toJson() {
    return {
      'reps': reps,
      'weight': weight,
    };
  }

  factory Set.fromJson(Map<String, dynamic> json) {
    return Set(
      reps: json['reps'],
      weight: json['weight'].toDouble(),
    );
  }
}
