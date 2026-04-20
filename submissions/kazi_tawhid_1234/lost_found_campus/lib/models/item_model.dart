import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  String? id;
  final String title;
  final String description;
  final String location;
  final String type;
  final String category;
  final String imageUrl;
  final String userEmail;
  final DateTime date;
  bool isResolved;

  ItemModel({
    this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.type,
    required this.category,
    required this.imageUrl,
    required this.userEmail,
    required this.date,
    this.isResolved = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'type': type,
      'category': category,
      'imageUrl': imageUrl,
      'userEmail': userEmail,
      'date': Timestamp.fromDate(date),
      'isResolved': isResolved,
    };
  }

  factory ItemModel.fromMap(String id, Map<String, dynamic> map) {
    return ItemModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      type: map['type'] ?? '',
      category: map['category'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      userEmail: map['userEmail'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      isResolved: map['isResolved'] ?? false,
    );
  }
}