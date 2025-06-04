import 'package:flutter/material.dart';
import 'models/workout_models.dart';
import 'data/workout_data.dart';
import 'widgets/modern_workout_widgets.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  final List<Exercise> _exercises = WorkoutData.getAllExercises();
  final List<WorkoutRoutine> _routines = WorkoutData.getWorkoutRoutines();
  Exercise? _selectedExercise;
  bool _isExercising = false;
  ExerciseCategory _selectedCategory = ExerciseCategory.morning;
  
  final Map<ExerciseCategory, IconData> _categoryIcons = {
    ExerciseCategory.morning: Icons.wb_sunny,
    ExerciseCategory.office: Icons.work,
    ExerciseCategory.meditation: Icons.spa,
    ExerciseCategory.eyecare: Icons.remove_red_eye,
    ExerciseCategory.posture: Icons.accessibility_new,
  };

  final Map<ExerciseCategory, Color> _categoryColors = {
    ExerciseCategory.morning: Colors.orange,
    ExerciseCategory.office: Colors.blue,
    ExerciseCategory.meditation: Colors.purple,
    ExerciseCategory.eyecare: Colors.teal,
    ExerciseCategory.posture: Colors.green,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategorySelector(),
                _buildDailyProgress(),
                _buildSectionTitle('Exerciții Recomandate'),
                _buildExercisesList(),
                _buildSectionTitle('Rutine de Antrenament'),
                _buildRoutinesList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: Theme.of(context).primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text('Exerciții & Wellness'),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/workout_background.jpg',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border),
          onPressed: () {
            // TODO: Implement favorites
          },
        ),
        IconButton(
          icon: const Icon(Icons.insights),
          onPressed: () {
            // TODO: Show statistics
          },
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: ExerciseCategory.values.map((category) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CategoryChip(
              label: _getCategoryName(category),
              icon: _categoryIcons[category] ?? Icons.fitness_center,
              color: _categoryColors[category] ?? Colors.blue,
              isSelected: _selectedCategory == category,
              onTap: () => setState(() => _selectedCategory = category),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getCategoryName(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.morning:
        return 'Dimineață';
      case ExerciseCategory.office:
        return 'Birou';
      case ExerciseCategory.meditation:
        return 'Mindfulness';
      case ExerciseCategory.eyecare:
        return 'Ochi';
      case ExerciseCategory.posture:
        return 'Postură';
      default:
        return 'General';
    }
  }

  Widget _buildDailyProgress() {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progresul Tău Astăzi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              AnimatedProgressRing(
                progress: 0.7,
                color: Colors.blue,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      '70%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Obiectiv',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              _buildProgressStat(
                Icons.timer,
                '45',
                'minute',
                Colors.orange,
              ),
              _buildProgressStat(
                Icons.local_fire_department,
                '150',
                'calorii',
                Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildExercisesList() {
    final filteredExercises = _exercises
        .where((e) => e.category == _selectedCategory)
        .toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredExercises.length,
      itemBuilder: (context, index) {
        final exercise = filteredExercises[index];
        return ModernWorkoutCard(
          exercise: exercise,
          isSelected: exercise == _selectedExercise,
          onTap: () => _showExerciseModal(exercise),
        );
      },
    );
  }

  Widget _buildRoutinesList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _routines.length,
      itemBuilder: (context, index) {
        final routine = _routines[index];
        return ModernRoutineCard(
          routine: routine,
          onTap: () => _showRoutineModal(routine),
        );
      },
    );
  }

  void _showExerciseModal(Exercise exercise) {
    setState(() => _selectedExercise = exercise);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildExerciseModalContent(exercise),
    );
  }

  Widget _buildExerciseModalContent(Exercise exercise) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildExerciseHeader(exercise),
                  _buildExerciseDetails(exercise),
                  if (_isExercising) _buildExerciseProgress(exercise),
                ],
              ),
            ),
          ),
          _buildStartButton(exercise),
        ],
      ),
    );
  }

  Widget _buildExerciseHeader(Exercise exercise) {
    return Stack(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: exercise.color.withOpacity(0.1),
          ),
          child: Image.asset(
            exercise.animationPath,
            fit: BoxFit.contain,
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // TODO: Implement favorite
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseDetails(Exercise exercise) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exercise.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            exercise.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          _buildExerciseStats(exercise),
          const SizedBox(height: 24),
          _buildExerciseSteps(exercise),
          const SizedBox(height: 24),
          _buildExerciseTips(exercise),
        ],
      ),
    );
  }

  Widget _buildExerciseStats(Exercise exercise) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          Icons.timer,
          '${exercise.duration.inMinutes} min',
          'Durată',
          exercise.color,
        ),
        _buildStatItem(
          Icons.local_fire_department,
          '${exercise.caloriesBurn}',
          'Calorii',
          exercise.color,
        ),
        _buildStatItem(
          Icons.speed,
          _getDifficultyText(exercise.difficulty),
          'Nivel',
          exercise.color,
        ),
      ],
    );
  }

  String _getDifficultyText(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.beginner:
        return 'Ușor';
      case ExerciseDifficulty.intermediate:
        return 'Mediu';
      case ExerciseDifficulty.advanced:
        return 'Avansat';
    }
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseSteps(Exercise exercise) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pași de urmat',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...exercise.steps.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: exercise.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${entry.key + 1}',
                      style: TextStyle(
                        color: exercise.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    entry.value,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildExerciseTips(Exercise exercise) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sfaturi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...exercise.tips.map((tip) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.tips_and_updates,
                  color: exercise.color,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tip,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildExerciseProgress(Exercise exercise) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          AnimatedProgressRing(
            progress: 0.6,
            size: 200,
            color: exercise.color,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(exercise.duration.inSeconds * 0.6).toInt()} sec',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'rămase',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Continuă așa!',
            style: TextStyle(
              fontSize: 20,
              color: exercise.color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(Exercise exercise) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: ElevatedButton(
        onPressed: () {
          setState(() => _isExercising = !_isExercising);
          if (!_isExercising) {
            Navigator.pop(context);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: exercise.color,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          _isExercising ? 'Termină Exercițiul' : 'Începe Exercițiul',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showRoutineModal(WorkoutRoutine routine) {
    // TODO: Implement routine modal
  }
} 