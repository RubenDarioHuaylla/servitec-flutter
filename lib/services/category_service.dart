import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/category.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Category>> getActiveCategories() async {
    final snapshot = await _firestore
        .collection('categories')
        .where('active', isEqualTo: true)
        .orderBy('order')
        .get();

    return snapshot.docs.map((document) {
      return Category.fromFirestore(document.id, document.data());
    }).toList();
  }
}
