// // import 'package:cloud_firestore/cloud_firestore.dart';

// // class AddPartyModel {
// //   final String id;
// //   final String title;
// //   final double amount;
// //   final String remarks;
// //   final String category;
// //   final bool expense; // true = expense, false = income
// //   final DateTime date;

// //   AddPartyModel({
// //     required this.id,
// //     required this.title,
// //     required this.amount,
// //     required this.remarks,
// //     required this.category,
// //     required this.expense,
// //     required this.date,
// //   });

// //   /// Convert Firestore data to model
// //   factory AddPartyModel.fromMap(Map<String, dynamic> map, String documentId) {
// //     return AddPartyModel(
// //       id: documentId,
// //       title: map['title'] ?? '',
// //       amount: (map['amount'] ?? 0).toDouble(),
// //       remarks: map['remarks'] ?? '',
// //       category: map['category'] ?? '',
// //       expense: map['expense'] ?? true,
// //       date: (map['date'] as Timestamp).toDate(),
// //     );
// //   }

// //   /// Convert model to Firestore map
// //   Map<String, dynamic> toMap() {
// //     return {
// //       'title': title,
// //       'amount': amount,
// //       'remarks': remarks,
// //       'category': category,
// //       'expense': expense,
// //       'date': Timestamp.fromDate(date),
// //     };
// //   }
// // }
// import 'dart:ui';

// import 'package:flutter/material.dart';

// enum TransactionStatus { toGive, toReceive, settled }

// class AddPartyModel {
//   final String id;
//   final String name;
//   final String phone;
//   final String email;
//   final String address;
//   final double openingBalance;
//   final String date;
//   final bool isCreditInfoSelected;
//   final bool toReceive;
//   final DateTime? createdAt;
//   final Color avatarColor;

//   AddPartyModel({
//     required this.id,
//     required this.name,
//     required this.phone,
//     required this.email,
//     required this.address,
//     required this.openingBalance,
//     required this.date,
//     required this.isCreditInfoSelected,
//     required this.toReceive,
//     this.createdAt,
//     required this.avatarColor,
//   });

//   String get avatarText =>
//       name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';

//   TransactionStatus get status {
//     if (openingBalance == 0) return TransactionStatus.settled;
//     return toReceive ? TransactionStatus.toReceive : TransactionStatus.toGive;
//   }

//   factory AddPartyModel.fromFirestore(Map<String, dynamic> data, String id) {
//     return AddPartyModel(
//       id: id,
//       name: data['name'] ?? '',
//       phone: data['phone'] ?? '',
//       email: data['email'] ?? '',
//       address: data['address'] ?? '',
//       openingBalance: (data['openingBalance'] ?? 0).toDouble(),
//       date: data['date'] ?? '',
//       isCreditInfoSelected: data['isCreditInfoSelected'] ?? true,
//       toReceive: data['toReceive'] ?? true,
//       createdAt: data['createdAt']?.toDate(),
//       avatarColor: _generateColor(data['name'] ?? ''),
//     );
//   }

//   static Color _generateColor(String name) {
//     if (name.isEmpty) return Colors.grey;
//     return Colors.primaries[name.length % Colors.primaries.length];
//   }

//   AddPartyModel copyWith({
//     String? id,
//     String? name,
//     String? phone,
//     String? email,
//     String? address,
//     double? openingBalance,
//     String? date,
//     bool? isCreditInfoSelected,
//     bool? toReceive,
//     DateTime? createdAt,
//     Color? avatarColor,
//   }) {
//     return AddPartyModel(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       phone: phone ?? this.phone,
//       email: email ?? this.email,
//       address: address ?? this.address,
//       openingBalance: openingBalance ?? this.openingBalance,
//       date: date ?? this.date,
//       isCreditInfoSelected: isCreditInfoSelected ?? this.isCreditInfoSelected,
//       toReceive: toReceive ?? this.toReceive,
//       createdAt: createdAt ?? this.createdAt,
//       avatarColor: avatarColor ?? this.avatarColor,
//     );
//   }
// }
