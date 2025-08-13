import 'dart:ui';

import 'package:flutter/material.dart';

enum TransactionStatus { toGive, toReceive, settled }

class Party {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final double openingBalance;
  final String date;
  final bool isCreditInfoSelected;
  final bool toReceive;
  final DateTime? createdAt;
  final Color avatarColor;

  Party({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.openingBalance,
    required this.date,
    required this.isCreditInfoSelected,
    required this.toReceive,
    this.createdAt,
    required this.avatarColor,
  });

  String get avatarText =>
      name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';

  TransactionStatus get status {
    if (openingBalance == 0) return TransactionStatus.settled;
    return toReceive ? TransactionStatus.toReceive : TransactionStatus.toGive;
  }

  factory Party.fromFirestore(Map<String, dynamic> data, String id) {
    return Party(
      id: id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      address: data['address'] ?? '',
      openingBalance: (data['openingBalance'] ?? 0).toDouble(),
      date: data['date'] ?? '',
      isCreditInfoSelected: data['isCreditInfoSelected'] ?? true,
      toReceive: data['toReceive'] ?? true,
      createdAt: data['createdAt']?.toDate(),
      avatarColor: _generateColor(data['name'] ?? ''),
    );
  }

  static Color _generateColor(String name) {
    if (name.isEmpty) return Colors.grey;
    return Colors.primaries[name.length % Colors.primaries.length];
  }

  Party copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    double? openingBalance,
    String? date,
    bool? isCreditInfoSelected,
    bool? toReceive,
    DateTime? createdAt,
    Color? avatarColor,
  }) {
    return Party(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      openingBalance: openingBalance ?? this.openingBalance,
      date: date ?? this.date,
      isCreditInfoSelected: isCreditInfoSelected ?? this.isCreditInfoSelected,
      toReceive: toReceive ?? this.toReceive,
      createdAt: createdAt ?? this.createdAt,
      avatarColor: avatarColor ?? this.avatarColor,
    );
  }
}
