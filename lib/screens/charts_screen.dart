// screens/charts_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // Make sure this is in your pubspec.yaml and you've run 'flutter pub get'
import '../providers/workout_provider.dart';
import '../providers/settings_provider.dart';
import '../models/workout.dart'; // Make sure your Workout model is correctly defined and imported

class ChartsScreen extends StatelessWidget {
  const ChartsScreen({Key? key}) : super(key: key);

  // Static variable to store legend items for the pie chart.
  // This is populated in _getDurationSections to ensure color consistency
  // between the chart and its legend.
  static List<Map<String, dynamic>> _staticBuildLegendItemsForPieChart = [];

  @override
  Widget build(BuildContext context) {
    // Access providers. listen: true ensures the UI rebuilds when provider data changes.
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: true);
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: true,
    );

    // This callback ensures that data loading is triggered only after the widget
    // has been built for the first time, preventing issues with BuildContext.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load workouts if they haven't been loaded yet and no loading is in progress.
      if (!workoutProvider.isLoading && workoutProvider.workouts.isEmpty) {
        print('ChartsScreen: Triggering loadWorkouts...');
        workoutProvider.loadWorkouts();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Charts'),
        centerTitle: true,
        elevation: 0, // No shadow under the app bar
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(
          context,
        ).colorScheme.onPrimary, // Text/icon color for contrast
      ),
      body: Builder(
        // Using Builder to ensure a proper BuildContext for checks below
        builder: (context) {
          // Display a loading indicator while workout data is being fetched
          if (workoutProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Display a message if no workout data is available after loading
          if (workoutProvider.workouts.isEmpty) {
            print(
              'ChartsScreen: No workouts available. Displaying empty state.',
            );
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart, // A generic chart icon
                    size: 64,
                    color: Colors.grey, // Grey color for empty state
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No data to display',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete some workouts to see your progress',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // --- Data Processing for All Charts (using real data where applicable) ---
          print(
            'ChartsScreen: Workouts loaded (${workoutProvider.workouts.length}). Processing data for charts...',
          );

          // Data for "Workouts per Week" (Bar Chart)
          final Map<int, double> workoutsPerWeekCounts =
              _getWorkoutsPerWeekCounts(workoutProvider.workouts);
          final List<BarChartGroupData> workoutBarGroups =
              _buildWorkoutBarGroups(workoutsPerWeekCounts, context);

          // Data for "Weight Progress" (Line Chart) - Remains SIMULATED as requested
          final List<FlSpot> weightData = _getWeightProgressData(
            workoutProvider.workouts,
            settingsProvider,
          );

          // Data for "Workout Duration Distribution" (Pie Chart)
          final List<PieChartSectionData> durationSections =
              _getDurationSections(workoutProvider.workouts, context);

          // NEW: Data for "Daily Workout Consistency" (Line Chart)
          final List<FlSpot> dailyConsistencyData =
              _getDailyWorkoutConsistencyData(workoutProvider.workouts);

          // --- Charts Display Area ---
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 1. Workouts per week chart (Bar Chart)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Workouts per Week (Last 4 Weeks)',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200, // Fixed height for the chart
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: workoutBarGroups.isEmpty
                                  ? 5 // Default max if no data
                                  : workoutBarGroups
                                            .map(
                                              (group) => group.barRods.isEmpty
                                                  ? 0.0
                                                  : group.barRods.first.toY,
                                            )
                                            .reduce((a, b) => a > b ? a : b) +
                                        1, // Max count + small buffer
                              barTouchData: BarTouchData(
                                touchTooltipData: BarTouchTooltipData(
                                  tooltipBgColor: Theme.of(
                                    context,
                                  ).colorScheme.surface,
                                  getTooltipItem:
                                      (group, groupIndex, rod, rodIndex) {
                                        return BarTooltipItem(
                                          '${rod.toY.round()} workouts',
                                          TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                          ),
                                        );
                                      },
                                ),
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: false,
                                  ), // Hide right axis titles
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: false,
                                  ), // Hide top axis titles
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      // Labels for the last 4 weeks (mapped: 0=oldest, 3=current)
                                      const weekLabels = [
                                        'Week -3',
                                        'Week -2',
                                        'Week -1',
                                        'Current Week',
                                      ];
                                      if (value.toInt() >= 0 &&
                                          value.toInt() < weekLabels.length) {
                                        return Text(weekLabels[value.toInt()]);
                                      }
                                      return const Text('');
                                    },
                                    reservedSize:
                                        30, // Space reserved for titles
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        value.toInt().toString(),
                                      ); // Display integer counts
                                    },
                                    interval:
                                        1, // Ensure integer labels on Y-axis
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(
                                show: false,
                              ), // Hide default border
                              barGroups:
                                  workoutBarGroups, // Use the list built from real data
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 2. NEW: Daily Workout Consistency Chart (Line Chart)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Workout Consistency (Last 30 Days)',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200, // Fixed height for the chart
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: true,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline.withOpacity(0.3),
                                    strokeWidth: 1,
                                  );
                                },
                                getDrawingVerticalLine: (value) {
                                  return FlLine(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline.withOpacity(0.3),
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    interval:
                                        7, // Show labels approximately every 7 days
                                    getTitlesWidget: (value, meta) {
                                      // value is the day index (0 to 29 for last 30 days)
                                      final date = DateTime.now().subtract(
                                        Duration(days: 29 - value.toInt()),
                                      );
                                      return Text(
                                        DateFormat('MM/dd').format(date),
                                      ); // Format date as Month/Day
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval:
                                        1, // Ensure integer workout counts on Y-axis
                                    getTitlesWidget: (value, meta) {
                                      if (value.toInt() == value) {
                                        // Only show whole numbers
                                        return Text('${value.toInt()}');
                                      }
                                      return const Text(
                                        '',
                                      ); // Hide decimals if any
                                    },
                                    reservedSize: 40,
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outline.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              minX: 0,
                              maxX: 29, // X-axis range for 30 days (0 to 29)
                              minY: 0,
                              maxY: dailyConsistencyData.isEmpty
                                  ? 3 // Default max if no data, or a reasonable starting point
                                  : dailyConsistencyData
                                            .map((spot) => spot.y)
                                            .reduce((a, b) => a > b ? a : b) +
                                        1, // Max workout count + buffer
                              lineBarsData: [
                                LineChartBarData(
                                  spots: dailyConsistencyData,
                                  isCurved: true,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .tertiary, // Use theme's tertiary color
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter:
                                        (spot, percent, barData, index) {
                                          return FlDotCirclePainter(
                                            radius: 4,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.tertiary,
                                            strokeWidth: 2,
                                            strokeColor: Colors.white,
                                          );
                                        },
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.tertiary.withOpacity(0.3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Weight progress chart (Line Chart - remains simulated)
                if (weightData
                    .isNotEmpty) // Only show if there's simulated data
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Weight Progress (${settingsProvider.weightUnit.name.toUpperCase()})',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200, // Fixed height for the chart
                            child: LineChart(
                              LineChartData(
                                gridData: const FlGridData(show: true),
                                titlesData: FlTitlesData(
                                  show: true,
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 30,
                                      interval: 5, // Show label every 5 days
                                      getTitlesWidget: (value, meta) {
                                        // Ensure value corresponds to a valid index in weightData
                                        if (value.toInt() >= 0 &&
                                            value.toInt() < weightData.length) {
                                          // Calculate date relative to current data for display
                                          final date = DateTime.now().subtract(
                                            Duration(
                                              days:
                                                  (weightData.length -
                                                  1 -
                                                  value.toInt()),
                                            ),
                                          );
                                          return Text(
                                            '${date.day}',
                                          ); // Show only the day
                                        }
                                        return const Text('');
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 50,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          '${value.toInt()}',
                                        ); // Display integer weight
                                      },
                                      interval: 1, // Ensure integer labels
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: weightData,
                                    isCurved: true,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary, // Using theme's primary color
                                    barWidth: 3,
                                    isStrokeCapRound: true,
                                    dotData: FlDotData(
                                      show: true,
                                      getDotPainter:
                                          (spot, percent, barData, index) {
                                            return FlDotCirclePainter(
                                              radius: 4,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                              strokeWidth: 2,
                                              strokeColor: Colors.white,
                                            );
                                          },
                                    ),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // 4. Workout duration pie chart
                if (durationSections.isNotEmpty)
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Workout Duration Distribution',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200, // Fixed height for the chart
                            child: PieChart(
                              PieChartData(
                                sections:
                                    durationSections, // Sections built from real data
                                borderData: FlBorderData(show: false),
                                sectionsSpace: 2,
                                centerSpaceRadius: 40,
                                pieTouchData: PieTouchData(
                                  touchCallback:
                                      (FlTouchEvent event, pieTouchResponse) {
                                        // Implement touch interaction if needed (e.g., showing details on tap)
                                      },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildLegend(context), // Legend for the pie chart
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Helper Methods for Data Processing ---

  // Calculates workouts per week for the last 4 weeks (including current week)
  Map<int, double> _getWorkoutsPerWeekCounts(List<Workout> workouts) {
    // Initialize counts for the last 4 weeks (0 = 3rd last week, 3 = current week)
    Map<int, double> workoutsPerWeek = {0: 0, 1: 0, 2: 0, 3: 0};

    // Determine the start of the current week (Sunday as the first day of the week)
    DateTime now = DateTime.now();
    DateTime startOfCurrentWeek = DateTime(now.year, now.month, now.day);
    if (startOfCurrentWeek.weekday != DateTime.sunday) {
      // If not Sunday, subtract days until Sunday
      startOfCurrentWeek = startOfCurrentWeek.subtract(
        Duration(days: startOfCurrentWeek.weekday),
      );
    }

    for (var workout in workouts) {
      // Normalize workout date to start of day for accurate comparison
      final workoutDateNormalized = DateTime(
        workout.date.year,
        workout.date.month,
        workout.date.day,
      );

      // Calculate the difference in days from the start of the current week
      int daysSinceStartOfCurrentWeek = workoutDateNormalized
          .difference(startOfCurrentWeek)
          .inDays;

      // Calculate raw week index (0 for current, -1 for last, etc.)
      int weekIndexRaw = (daysSinceStartOfCurrentWeek / 7).floor();

      // Map raw week index to chart's 0-3 range (0 = oldest of the 4, 3 = newest)
      int mappedWeekIndex = 3 + weekIndexRaw;

      if (mappedWeekIndex >= 0 && mappedWeekIndex < 4) {
        // Only consider the last 4 weeks
        workoutsPerWeek[mappedWeekIndex] =
            (workoutsPerWeek[mappedWeekIndex] ?? 0) + 1;
      }
    }
    print('Workouts per week counts: $workoutsPerWeek');
    return workoutsPerWeek;
  }

  // Builds BarChartGroupData list from processed weekly counts
  List<BarChartGroupData> _buildWorkoutBarGroups(
    Map<int, double> workoutsPerWeekCounts,
    BuildContext context,
  ) {
    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < 4; i++) {
      // Create a bar for each of the 4 weeks (0 to 3)
      barGroups.add(
        BarChartGroupData(
          x: i, // X-value corresponds to the mappedWeekIndex (0-3)
          barRods: [
            BarChartRodData(
              toY: workoutsPerWeekCounts[i] ?? 0, // Get the count for this week
              color: Theme.of(
                context,
              ).colorScheme.primary, // Use theme's primary color
              width: 20,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }
    print('Workout bar groups: $barGroups');
    return barGroups;
  }

  // NEW: Gets daily workout counts for the last 30 days for the consistency chart
  List<FlSpot> _getDailyWorkoutConsistencyData(List<Workout> workouts) {
    // Initialize counts for all 30 days (0 for 30 days ago, 29 for today)
    Map<int, double> dailyCounts = {};
    for (int i = 0; i < 30; i++) {
      dailyCounts[i] = 0;
    }

    DateTime now = DateTime.now();
    // Normalize 'now' to start of day for accurate comparison
    final todayNormalized = DateTime(now.year, now.month, now.day);

    for (var workout in workouts) {
      // Normalize workout date to start of day
      final workoutDateNormalized = DateTime(
        workout.date.year,
        workout.date.month,
        workout.date.day,
      );

      // Calculate difference in days from today (0 for today, 1 for yesterday, etc.)
      int daysDifference = todayNormalized
          .difference(workoutDateNormalized)
          .inDays;

      // Map daysDifference to chart's X-axis index (0 for 30 days ago, 29 for today)
      int xIndex = 29 - daysDifference;

      if (xIndex >= 0 && xIndex < 30) {
        // Only consider the last 30 days
        dailyCounts[xIndex] = (dailyCounts[xIndex] ?? 0) + 1;
      }
    }

    // Convert map of daily counts to List<FlSpot>
    List<FlSpot> spots = [];
    for (int i = 0; i < 30; i++) {
      spots.add(FlSpot(i.toDouble(), dailyCounts[i] ?? 0));
    }
    print('Daily consistency data spots: $spots');
    return spots;
  }

  // Weight progress chart data (remains simulated as requested)
  List<FlSpot> _getWeightProgressData(
    List<dynamic> workouts,
    SettingsProvider settingsProvider,
  ) {
    // This data is simulated. In a real application, you would fetch this from Firestore
    // (e.g., from a separate 'weight_logs' subcollection under each user).
    final List<double> baseWeights = [
      70,
      72,
      71,
      73,
      74,
      72,
      75,
      71.5,
    ]; // Example weights in KG
    print('Simulated base weights (KG): $baseWeights');
    return baseWeights.asMap().entries.map((entry) {
      final weight = settingsProvider.convertWeight(
        entry.value,
        WeightUnit.kg, // Assuming baseWeights are in KG
        settingsProvider.weightUnit,
      );
      return FlSpot(entry.key.toDouble(), weight);
    }).toList();
  }

  // Calculates workout duration distribution for the pie chart
  List<PieChartSectionData> _getDurationSections(
    List<Workout> workouts,
    BuildContext context,
  ) {
    if (workouts.isEmpty) {
      _staticBuildLegendItemsForPieChart =
          []; // Clear legend if no data for pie chart
      return [];
    }

    // Categorize workout durations
    Map<String, int> durationCounts = {
      '30-45min': 0,
      '45-60min': 0,
      '60+min': 0,
      // You can add more categories (e.g., '<30min') if needed
    };

    for (var workout in workouts) {
      if (workout.duration >= 60) {
        durationCounts['60+min'] = (durationCounts['60+min'] ?? 0) + 1;
      } else if (workout.duration >= 45) {
        durationCounts['45-60min'] = (durationCounts['45-60min'] ?? 0) + 1;
      } else if (workout.duration >= 30) {
        durationCounts['30-45min'] = (durationCounts['30-45min'] ?? 0) + 1;
      }
    }

    List<PieChartSectionData> sections = [];
    final colorScheme = Theme.of(context).colorScheme;
    // Define a list of distinct colors to use for pie chart sections
    final List<Color> sectionColors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      Colors.green.shade600,
      Colors.deepOrange.shade400,
      Colors.purple.shade300,
      Colors.blueGrey,
    ];
    int colorIndex = 0;

    // Build sections and simultaneously populate the static legend list
    List<Map<String, dynamic>> tempLegendItems = [];
    durationCounts.forEach((range, count) {
      if (count > 0) {
        // Only create a section if there are workouts in this duration range
        final sectionColor =
            sectionColors[colorIndex %
                sectionColors.length]; // Cycle through colors
        sections.add(
          PieChartSectionData(
            color: sectionColor,
            value: count.toDouble(),
            title: '$range\n($count)', // Display category and count
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            titlePositionPercentageOffset: 0.55,
          ),
        );
        tempLegendItems.add({'label': range, 'color': sectionColor});
        colorIndex++;
      }
    });

    _staticBuildLegendItemsForPieChart =
        tempLegendItems; // Update the static legend data
    print('Duration sections: $sections');
    return sections;
  }

  // Builds the legend for the pie chart using the static variable for consistency
  Widget _buildLegend(BuildContext context) {
    return Wrap(
      spacing: 12, // Horizontal spacing between legend items
      runSpacing: 8, // Vertical spacing between rows of legend items
      children: _staticBuildLegendItemsForPieChart.map((item) {
        return _buildLegendItem(
          context,
          item['label'] as String,
          item['color'] as Color,
        );
      }).toList(),
    );
  }

  // Helper widget for a single legend item (color box + label)
  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min, // Takes minimal horizontal space
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
