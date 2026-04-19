class ItemModel {
  final String title;
  final String description;
  final String location;
  final String type;
  final String category;
  final String imageUrl;
  final DateTime date;
  bool isResolved;

  ItemModel({
    required this.title,
    required this.description,
    required this.location,
    required this.type,
    required this.category,
    required this.imageUrl,
    required this.date,
    this.isResolved = false,
  });
}