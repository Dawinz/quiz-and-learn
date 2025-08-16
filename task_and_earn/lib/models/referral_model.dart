import 'package:flutter/material.dart';

class ReferralModel {
  final String id;
  final String referredUser;
  final String email;
  final String status;
  final DateTime joinedAt;
  final int earnings;
  final String? phone;
  final String? profilePicture;

  ReferralModel({
    required this.id,
    required this.referredUser,
    required this.email,
    required this.status,
    required this.joinedAt,
    required this.earnings,
    this.phone,
    this.profilePicture,
  });

  factory ReferralModel.fromMap(Map<String, dynamic> map) {
    return ReferralModel(
      id: map['id']?.toString() ?? '',
      referredUser: map['referredUser'] ?? '',
      email: map['email'] ?? '',
      status: map['status'] ?? '',
      joinedAt: DateTime.tryParse(map['joinedAt'] ?? '') ?? DateTime.now(),
      earnings: map['earnings']?.toInt() ?? 0,
      phone: map['phone'],
      profilePicture: map['profilePicture'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'referredUser': referredUser,
      'email': email,
      'status': status,
      'joinedAt': joinedAt.toIso8601String(),
      'earnings': earnings,
      'phone': phone,
      'profilePicture': profilePicture,
    };
  }

  ReferralModel copyWith({
    String? id,
    String? referredUser,
    String? email,
    String? status,
    DateTime? joinedAt,
    int? earnings,
    String? phone,
    String? profilePicture,
  }) {
    return ReferralModel(
      id: id ?? this.id,
      referredUser: referredUser ?? this.referredUser,
      email: email ?? this.email,
      status: status ?? this.status,
      joinedAt: joinedAt ?? this.joinedAt,
      earnings: earnings ?? this.earnings,
      phone: phone ?? this.phone,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }

  bool get isActive => status == 'active';
  bool get isPending => status == 'pending';
  bool get isInactive => status == 'inactive';

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF4CAF50); // Green
      case 'pending':
        return const Color(0xFFFF9800); // Orange
      case 'inactive':
        return const Color(0xFF9E9E9E); // Grey
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  String get statusText {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'pending':
        return 'Pending';
      case 'inactive':
        return 'Inactive';
      default:
        return 'Unknown';
    }
  }

  String get formattedJoinedDate {
    final now = DateTime.now();
    final difference = now.difference(joinedAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays != 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours != 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes != 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
