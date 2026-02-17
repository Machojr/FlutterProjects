import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _db.collection(AppConstants.usersCollection).withConverter(
            fromFirestore: (snap, _) => snap.data() ?? <String, dynamic>{},
            toFirestore: (value, _) => value as Map<String, dynamic>,
          );

  // Create or overwrite user document
  Future<void> createUser(UserModel user) async {
    final doc = _db.collection(AppConstants.usersCollection).doc(user.userId);
    await doc.set(user.toMap());
  }

  // Get user by UID
  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection(AppConstants.usersCollection).doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromDocument(doc as DocumentSnapshot<Map<String, dynamic>>);
  }

  // Stream user document
  Stream<UserModel?> streamUser(String uid) {
    return _db.collection(AppConstants.usersCollection).doc(uid).snapshots().map(
          (snap) => snap.exists
              ? UserModel.fromDocument(snap as DocumentSnapshot<Map<String, dynamic>>)
              : null,
        );
  }

  // Update specific fields for a user
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    final doc = _db.collection(AppConstants.usersCollection).doc(uid);
    data[AppConstants.updatedAt] = FieldValue.serverTimestamp();
    await doc.update(data);
  }

  // Search users by displayName (simple prefix search)
  Future<List<UserModel>> searchUsersByName(String query,
      {int limit = 20}) async {
    if (query.isEmpty) return [];
    final end = query + '\uf8ff';
    final snap = await _db
        .collection(AppConstants.usersCollection)
        .where(AppConstants.displayName, isGreaterThanOrEqualTo: query)
        .where(AppConstants.displayName, isLessThanOrEqualTo: end)
        .limit(limit)
        .get();
    return snap.docs
        .map((d) => UserModel.fromDocument(d as DocumentSnapshot<Map<String, dynamic>>))
        .toList();
  }

  // Stream recent users list (for discovery)
  Stream<List<UserModel>> streamUsers({int limit = 50}) {
    return _db
        .collection(AppConstants.usersCollection)
        .orderBy(AppConstants.createdAt, descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => UserModel.fromDocument(d as DocumentSnapshot<Map<String, dynamic>>))
            .toList());
  }

  // Set user online/offline status
  Future<void> setUserOnlineStatus(String uid, bool isOnline) async {
    final doc = _db.collection(AppConstants.usersCollection).doc(uid);
    await doc.update({
      AppConstants.isOnline: isOnline,
      AppConstants.lastSeen: FieldValue.serverTimestamp(),
    });
  }

  // Add or update FCM token in user document
  Future<void> updateFcmToken(String uid, String token, Map<String, dynamic>? device) async {
    final doc = _db.collection(AppConstants.usersCollection).doc(uid);
    final tokenEntry = {
      'token': token,
      'device': device ?? {},
      'addedAt': FieldValue.serverTimestamp(),
    };
    await doc.update({
      AppConstants.fcmToken: token,
      'deviceTokens': FieldValue.arrayUnion([tokenEntry]),
      AppConstants.updatedAt: FieldValue.serverTimestamp(),
    });
  }
}
