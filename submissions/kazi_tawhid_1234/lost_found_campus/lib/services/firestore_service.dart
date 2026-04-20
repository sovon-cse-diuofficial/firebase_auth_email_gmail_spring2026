import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addItem(ItemModel item) async {
    await _firestore.collection('items').add(item.toMap());
  }

  Stream<List<ItemModel>> getItems() {
    return _firestore
        .collection('items')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => ItemModel.fromMap(doc.id, doc.data()))
          .toList(),
    );
  }

  Future<void> markItemResolved(String id) async {
    await _firestore.collection('items').doc(id).update({
      'isResolved': true,
    });
  }
}