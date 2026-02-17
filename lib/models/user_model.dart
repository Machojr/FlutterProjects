import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';

class UserModel {
  final String userId;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? bio;
  final String? phoneNumber;
  final bool isOnline;
  final Timestamp? lastSeen;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final String? fcmToken;
  final List<String> blockedUsers;
  final List<Map<String, dynamic>> deviceTokens;

  UserModel({
    required this.userId,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.bio,
    this.phoneNumber,
    this.isOnline = false,
    this.lastSeen,
    this.createdAt,
    this.updatedAt,
    this.fcmToken,
    List<String>? blockedUsers,
    List<Map<String, dynamic>>? deviceTokens,
  })  : blockedUsers = blockedUsers ?? [],
        deviceTokens = deviceTokens ?? [];

  factory UserModel.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return UserModel(
      userId: doc.id,
      email: data[AppConstants.email] as String? ?? '',
      displayName: data[AppConstants.displayName] as String?,
      photoUrl: data[AppConstants.photoUrl] as String?,
      bio: data[AppConstants.bio] as String?,
      phoneNumber: data[AppConstants.phoneNumber] as String?,
      isOnline: data[AppConstants.isOnline] as bool? ?? false,
      lastSeen: data[AppConstants.lastSeen] as Timestamp?,
      createdAt: data[AppConstants.createdAt] as Timestamp?,
      updatedAt: data[AppConstants.updatedAt] as Timestamp?,
      fcmToken: data[AppConstants.fcmToken] as String?,
      blockedUsers: List<String>.from(data[AppConstants.blockedUsers] ?? []),
      deviceTokens: List<Map<String, dynamic>>.from(data['deviceTokens'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      AppConstants.email: email,
      AppConstants.displayName: displayName,
      AppConstants.photoUrl: photoUrl,
      AppConstants.bio: bio,
      AppConstants.phoneNumber: phoneNumber,
      AppConstants.isOnline: isOnline,
      AppConstants.lastSeen: lastSeen,
      AppConstants.createdAt: createdAt ?? FieldValue.serverTimestamp(),
      AppConstants.updatedAt: updatedAt ?? FieldValue.serverTimestamp(),
      AppConstants.fcmToken: fcmToken,
      AppConstants.blockedUsers: blockedUsers,
      'deviceTokens': deviceTokens,
    };
  }

  UserModel copyWith({
    String? displayName,
    String? photoUrl,
    String? bio,
    String? phoneNumber,
    bool? isOnline,
    Timestamp? lastSeen,
    String? fcmToken,
    List<String>? blockedUsers,
    List<Map<String, dynamic>>? deviceTokens,
  }) {
    return UserModel(
      userId: userId,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt,
      updatedAt: FieldValue.serverTimestamp() as Timestamp?,
      fcmToken: fcmToken ?? this.fcmToken,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      deviceTokens: deviceTokens ?? this.deviceTokens,
    );
  }
}
