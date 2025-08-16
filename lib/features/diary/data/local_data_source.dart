import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'diary_model.dart';

class DiaryRepository {
  static final DiaryRepository _instance = DiaryRepository._internal();
  factory DiaryRepository() => _instance;
  DiaryRepository._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference get _diaryCollection =>
      _firestore.collection('users').doc(_uid).collection('diaries');

  Future<void> insertEntry(DiaryModel entry) async {
    final docRef = _diaryCollection.doc();
    await docRef.set({
      'id': docRef.id,
      'userId': _uid,
      'title': entry.title,
      'content': entry.content,
      'dateTime': entry.dateTime,
      'mood': entry.mood,
      'mediaPaths': entry.mediaPaths, // ✅ store as array
    });
  }

  Future<List<DiaryModel>> getAllEntries() async {
    final snapshot =
        await _diaryCollection.orderBy('dateTime', descending: true).get();
    return snapshot.docs
        .map((doc) => DiaryModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateEntry(DiaryModel entry) async {
    if (entry.id == null) return;
    await _diaryCollection.doc(entry.id).update({
      'title': entry.title,
      'content': entry.content,
      'dateTime': entry.dateTime,
      'mood': entry.mood,
      'mediaPaths': entry.mediaPaths, // ✅ store as array
    });
  }

  Future<void> deleteEntry(String id) async {
    await _diaryCollection.doc(id).delete();
  }

  Future<List<DiaryModel>> getFilteredEntries(
      {String? mood, String? date}) async {
    Query query = _diaryCollection;
    if (mood != null && mood.isNotEmpty) {
      query = query.where('mood', isEqualTo: mood);
    }
    if (date != null && date.isNotEmpty) {
      query = query
          .where('dateTime', isGreaterThanOrEqualTo: date)
          .where('dateTime', isLessThanOrEqualTo: '$date\uf8ff');
    }
    final snapshot = await query.orderBy('dateTime', descending: true).get();
    return snapshot.docs
        .map((doc) => DiaryModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
