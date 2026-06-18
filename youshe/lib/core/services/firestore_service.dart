import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/logging_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LoggingService _log = LoggingService();

  Future<DocumentReference> add(String collection, Map<String, dynamic> data) async {
    try {
      final ref = await _firestore.collection(collection).add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _log.info('Document added to $collection', tag: 'FirestoreService');
      return ref;
    } catch (e) {
      _log.error('Failed to add document to $collection', tag: 'FirestoreService', error: e);
      rethrow;
    }
  }

  Future<void> set(String collection, String docId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(docId).set({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      _log.info('Document set in $collection/$docId', tag: 'FirestoreService');
    } catch (e) {
      _log.error('Failed to set document $collection/$docId', tag: 'FirestoreService', error: e);
      rethrow;
    }
  }

  Future<void> update(String collection, String docId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(docId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _log.info('Document updated in $collection/$docId', tag: 'FirestoreService');
    } catch (e) {
      _log.error('Failed to update document $collection/$docId', tag: 'FirestoreService', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> get(String collection, String docId) async {
    final doc = await _firestore.collection(collection).doc(docId).get();
    return doc.data();
  }

  Future<void> delete(String collection, String docId) async {
    await _firestore.collection(collection).doc(docId).delete();
    _log.info('Document deleted from $collection/$docId', tag: 'FirestoreService');
  }

  CollectionReference collection(String collection) {
    return _firestore.collection(collection);
  }

  DocumentReference doc(String collection, String docId) {
    return _firestore.collection(collection).doc(docId);
  }

  Query query(String collection, {String? orderBy, bool descending = false, int? limit}) {
    var q = _firestore.collection(collection) as Query;
    if (orderBy != null) {
      q = q.orderBy(orderBy, descending: descending);
    }
    if (limit != null) {
      q = q.limit(limit);
    }
    return q;
  }
}
