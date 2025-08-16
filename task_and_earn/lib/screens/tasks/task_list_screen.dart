import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../widgets/task_card.dart';
import '../../widgets/task_category_card.dart';
import '../../models/task_model.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  String? _selectedCategory;
  String? _selectedType;
  String? _selectedDifficulty;
  final List<TaskModel> _tasks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });

    // Mock data - replace with API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _tasks.clear();
      _tasks.addAll([
        TaskModel(
          id: '1',
          title: 'Math Quiz - Basic Addition',
          description: 'Complete 10 basic addition problems',
          category: 'Mathematics',
          type: 'Quiz',
          difficulty: 'Easy',
          reward: 50,
          estimatedTime: 5,
          requirements: ['Basic math knowledge'],
        ),
        TaskModel(
          id: '2',
          title: 'Science Quiz - Solar System',
          description: 'Learn about planets and answer questions',
          category: 'Science',
          type: 'Quiz',
          difficulty: 'Medium',
          reward: 75,
          estimatedTime: 8,
          requirements: ['General knowledge'],
        ),
        TaskModel(
          id: '3',
          title: 'Language Quiz - English Grammar',
          description: 'Test your English grammar skills',
          category: 'Language',
          type: 'Quiz',
          difficulty: 'Medium',
          reward: 75,
          estimatedTime: 7,
          requirements: ['Basic English'],
        ),
        TaskModel(
          id: '4',
          title: 'History Quiz - World War II',
          description: 'Answer questions about World War II',
          category: 'History',
          type: 'Quiz',
          difficulty: 'Hard',
          reward: 100,
          estimatedTime: 12,
          requirements: ['History knowledge'],
        ),
      ]);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Categories Section
          Container(
            height: 120,
            padding: const EdgeInsets.all(AppSizes.padding),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                TaskCategoryCard(
                  title: 'All',
                  icon: Icons.all_inclusive,
                  isSelected: _selectedCategory == null,
                  onTap: () {
                    setState(() {
                      _selectedCategory = null;
                    });
                    _loadTasks();
                  },
                ),
                TaskCategoryCard(
                  title: 'Mathematics',
                  icon: Icons.calculate,
                  isSelected: _selectedCategory == 'Mathematics',
                  onTap: () {
                    setState(() {
                      _selectedCategory = 'Mathematics';
                    });
                    _loadTasks();
                  },
                ),
                TaskCategoryCard(
                  title: 'Science',
                  icon: Icons.science,
                  isSelected: _selectedCategory == 'Science',
                  onTap: () {
                    setState(() {
                      _selectedCategory = 'Science';
                    });
                    _loadTasks();
                  },
                ),
                TaskCategoryCard(
                  title: 'Language',
                  icon: Icons.language,
                  isSelected: _selectedCategory == 'Language',
                  onTap: () {
                    setState(() {
                      _selectedCategory = 'Language';
                    });
                    _loadTasks();
                  },
                ),
                TaskCategoryCard(
                  title: 'History',
                  icon: Icons.history_edu,
                  isSelected: _selectedCategory == 'History',
                  onTap: () {
                    setState(() {
                      _selectedCategory = 'History';
                    });
                    _loadTasks();
                  },
                ),
              ],
            ),
          ),

          // Filters Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedDifficulty,
                    decoration: InputDecoration(
                      labelText: 'Difficulty',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radius),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All')),
                      DropdownMenuItem(value: 'Easy', child: Text('Easy')),
                      DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                      DropdownMenuItem(value: 'Hard', child: Text('Hard')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedDifficulty = value;
                      });
                      _loadTasks();
                    },
                  ),
                ),
                const SizedBox(width: AppSizes.spacingMedium),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radius),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All')),
                      DropdownMenuItem(value: 'Quiz', child: Text('Quiz')),
                      DropdownMenuItem(value: 'Survey', child: Text('Survey')),
                      DropdownMenuItem(value: 'Video', child: Text('Video')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value;
                      });
                      _loadTasks();
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.spacingMedium),

          // Tasks List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _tasks.isEmpty
                    ? const Center(
                        child: Text('No tasks available'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSizes.padding),
                        itemCount: _tasks.length,
                        itemBuilder: (context, index) {
                          final task = _tasks[index];
                          return TaskCard(
                            task: task,
                            onTap: () {
                              // Navigate to task detail
                              Navigator.pushNamed(
                                context,
                                '/task-detail',
                                arguments: task,
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
