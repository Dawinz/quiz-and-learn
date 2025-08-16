import 'package:flutter/material.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String type;
  final String difficulty;
  final int reward;
  final int estimatedTime; // in minutes
  final List<String> requirements;
  final bool isCompleted;
  final DateTime? completedAt;
  final int? userRating;
  final String? userFeedback;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.difficulty,
    required this.reward,
    required this.estimatedTime,
    required this.requirements,
    this.isCompleted = false,
    this.completedAt,
    this.userRating,
    this.userFeedback,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id']?.toString() ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      type: map['type'] ?? '',
      difficulty: map['difficulty'] ?? '',
      reward: map['reward']?.toInt() ?? 0,
      estimatedTime: map['estimatedTime']?.toInt() ?? 0,
      requirements: List<String>.from(map['requirements'] ?? []),
      isCompleted: map['isCompleted'] ?? false,
      completedAt: map['completedAt'] != null
          ? DateTime.tryParse(map['completedAt'])
          : null,
      userRating: map['userRating']?.toInt(),
      userFeedback: map['userFeedback'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'type': type,
      'difficulty': difficulty,
      'reward': reward,
      'estimatedTime': estimatedTime,
      'requirements': requirements,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'userRating': userRating,
      'userFeedback': userFeedback,
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? type,
    String? difficulty,
    int? reward,
    int? estimatedTime,
    List<String>? requirements,
    bool? isCompleted,
    DateTime? completedAt,
    int? userRating,
    String? userFeedback,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      reward: reward ?? this.reward,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      requirements: requirements ?? this.requirements,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      userRating: userRating ?? this.userRating,
      userFeedback: userFeedback ?? this.userFeedback,
    );
  }

  Color get difficultyColor {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return const Color(0xFF4CAF50); // Green
      case 'medium':
        return const Color(0xFFFF9800); // Orange
      case 'hard':
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  IconData get categoryIcon {
    switch (category.toLowerCase()) {
      case 'mathematics':
        return Icons.calculate;
      case 'science':
        return Icons.science;
      case 'language':
        return Icons.language;
      case 'history':
        return Icons.history_edu;
      case 'geography':
        return Icons.public;
      case 'literature':
        return Icons.book;
      default:
        return Icons.school;
    }
  }
}
