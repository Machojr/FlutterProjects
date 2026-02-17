/// App Constants
/// Contains all constant values used throughout the application

class AppConstants {
  // App Information
  static const String appName = 'Chat App';
  static const String appVersion = '1.0.0';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';
  static const String notificationsCollection = 'notifications';
  static const String userPresenceCollection = 'user_presence';
  static const String blocksCollection = 'blocks';

  // Field Names
  static const String userId = 'userId';
  static const String email = 'email';
  static const String displayName = 'displayName';
  static const String photoUrl = 'photoUrl';
  static const String bio = 'bio';
  static const String phoneNumber = 'phoneNumber';
  static const String isOnline = 'isOnline';
  static const String lastSeen = 'lastSeen';
  static const String fcmToken = 'fcmToken';
  static const String blockedUsers = 'blockedUsers';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';

  // Chat Fields
  static const String chatId = 'chatId';
  static const String participants = 'participants';
  static const String lastMessage = 'lastMessage';
  static const String lastMessageTime = 'lastMessageTime';
  static const String lastMessageSenderId = 'lastMessageSenderId';
  static const String participantDetails = 'participantDetails';
  static const String isActive = 'isActive';

  // Message Fields
  static const String messageId = 'messageId';
  static const String senderId = 'senderId';
  static const String receiverId = 'receiverId';
  static const String text = 'text';
  static const String type = 'type';
  static const String timestamp = 'timestamp';
  static const String isRead = 'isRead';
  static const String readAt = 'readAt';

  // Notification Fields
  static const String notificationId = 'notificationId';
  static const String title = 'title';
  static const String body = 'body';
  static const String fromUserId = 'fromUserId';
  static const String fromUserName = 'fromUserName';

  // Routes
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String homeRoute = '/home';
  static const String chatsRoute = '/chats';
  static const String chatDetailRoute = '/chat/:chatId';
  static const String usersRoute = '/users';
  static const String userProfileRoute = '/user/:userId';
  static const String profileRoute = '/profile';
  static const String editProfileRoute = '/edit-profile';
  static const String notificationsRoute = '/notifications';
  static const String settingsRoute = '/settings';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
  static const int minDisplayNameLength = 2;
  static const int maxDisplayNameLength = 50;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double defaultElevation = 4.0;

  // Timeouts
  static const Duration firebaseTimeout = Duration(seconds: 30);
  static const Duration debounceTimeout = Duration(milliseconds: 500);
  static const Duration userPresenceTTL = Duration(minutes: 5);

  // Messaging
  static const int maxMessageLength = 1000;
  static const int messageBatchSize = 20;

  // Notification
  static const int notificationBatchSize = 20;
  static const Duration notificationRetention = Duration(days: 90);
}

/// Message Types
class MessageType {
  static const String text = 'text';
  static const String image = 'image';
  static const String file = 'file';
  static const String deleted = 'deleted';
}

/// Notification Types
class NotificationType {
  static const String message = 'message';
  static const String request = 'request';
  static const String system = 'system';
}

/// User Presence Status
class PresenceStatus {
  static const String online = 'online';
  static const String offline = 'offline';
  static const String away = 'away';
  static const String busy = 'busy';
}
