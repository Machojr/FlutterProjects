# Flutter Chat App

A real-time messaging application built with Flutter and Firebase, enabling users to authenticate, discover other users, and communicate seamlessly with instant notifications.

## 🎯 Features

- **User Authentication**: Secure sign-up and login with Firebase Authentication (Email/Password)
- **User Discovery**: Browse and view profiles of other registered users
- **Real-time Messaging**: Send and receive text messages in real-time
- **Push Notifications**: Receive instant notifications for new messages
- **User Profiles**: View user information and online status
- **Chat History**: Persistent message storage and retrieval
- **Responsive UI**: Works seamlessly on Android and iOS devices

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.0 or higher)
- [Dart SDK](https://dart.dev/get-dart) (included with Flutter)
- [Firebase Project](https://console.firebase.google.com/)
- Android Studio / Xcode (for testing on emulator/simulator)
- Git

### System Requirements
- **Android**: Minimum SDK 21, Target SDK 34+
- **iOS**: Minimum iOS 12.0

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone <your-repo-url>
cd chatapp
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Firebase Configuration

#### Android Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use an existing one
3. Add an Android app and download the `google-services.json` file
4. Place the file in: `android/app/`
5. Follow the Firebase console instructions to configure your `build.gradle.kts` files

#### iOS Setup

1. In Firebase Console, add an iOS app to your project
2. Download the `GoogleService-Info.plist` file
3. Open `ios/Runner.xcworkspace` in Xcode
4. Add the `GoogleService-Info.plist` file to the Runner project
5. Follow Firebase console instructions for pod dependencies

### 4. Enable Firebase Services

In your Firebase Console, enable:
- **Authentication** (Email/Password)
- **Firestore Database** (for messages and user data)
- **Cloud Messaging** (for notifications)

### 5. Configure Firestore Rules

Add the following security rules in Firebase Console:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    match /messages/{messageId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    match /chats/{chatId} {
      allow read: if request.auth.uid in resource.data.participants;
      allow write: if request.auth.uid in resource.data.participants;
    }
  }
}
```

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   └── forgot_password_screen.dart
│   ├── home/
│   │   ├── home_screen.dart
│   │   └── chats_list_screen.dart
│   ├── users/
│   │   ├── users_list_screen.dart
│   │   └── user_profile_screen.dart
│   └── chat/
│       └── chat_screen.dart
├── models/
│   ├── user_model.dart
│   ├── message_model.dart
│   └── chat_model.dart
├── services/
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   ├── messaging_service.dart
│   └── notification_service.dart
├── providers/          # State management (Provider/Riverpod/Bloc)
│   ├── auth_provider.dart
│   └── chat_provider.dart
└── utils/
    ├── constants.dart
    └── validators.dart
```

## 🔐 Authentication Flow

1. **Sign Up**: Users create account with email and password
2. **Login**: Authenticate and retrieve user data from Firestore
3. **Session Management**: Automatic logout on sign out
4. **Password Recovery**: Reset password via email

### Key Classes

- `AuthService`: Handles Firebase Authentication
- `AuthProvider`: State management for auth state

## 💬 Messaging System

### Data Structure (Firestore)

**Users Collection:**
```json
{
  "uid": "user_id",
  "email": "user@example.com",
  "displayName": "John Doe",
  "photoUrl": "https://...",
  "createdAt": "timestamp",
  "isOnline": true,
  "lastSeen": "timestamp"
}
```

**Messages Collection:**
```json
{
  "messageId": "msg_id",
  "chatId": "chat_id",
  "senderId": "user_id",
  "receiverId": "user_id",
  "text": "Hello!",
  "timestamp": "timestamp",
  "isRead": false
}
```

**Chats Collection:**
```json
{
  "chatId": "chat_id",
  "participants": ["user1_id", "user2_id"],
  "lastMessage": "Last message text",
  "lastMessageTime": "timestamp",
  "createdAt": "timestamp"
}
```

## 🔔 Push Notifications

### Setup

1. Enable Cloud Messaging in Firebase Console
2. Configure FCM (Firebase Cloud Messaging) in your project
3. Request permissions from users (Android 13+, iOS)

### Implementation

- Listen to incoming messages using FCM
- Display notifications in foreground and background
- Handle notification taps to navigate to chat

## 🛠 Installation & Running

### Run on Android Emulator
```bash
flutter run -d emulator-5554
```

### Run on iOS Simulator
```bash
flutter run -d iPhone
```

### Run on Physical Device
```bash
flutter run
```

### Release Build
```bash
# Android
flutter build apk

# iOS
flutter build ios
```

## 📦 Dependencies

Key packages used in this project:

```yaml
firebase_core: ^x.x.x        # Firebase initialization
firebase_auth: ^x.x.x        # Authentication
cloud_firestore: ^x.x.x      # Database
firebase_messaging: ^x.x.x   # Push notifications
provider: ^x.x.x             # State management
intl: ^x.x.x                 # Internationalization
image_picker: ^x.x.x         # Image selection
```

See [pubspec.yaml](pubspec.yaml) for complete dependency list.

## 🔄 State Management

This project uses **Provider** for state management. Key providers:

- `AuthProvider`: Manages authentication state
- `ChatProvider`: Manages chat and messaging state
- `UserProvider`: Manages user data and discovery

## 🎨 UI/UX Features

- Clean and intuitive user interface
- Dark mode support (optional)
- Smooth animations and transitions
- Bottom navigation for easy access
- Real-time typing indicators (optional)
- Message read receipts (optional)

## 🐛 Troubleshooting

### Issue: Firebase not connecting
- Verify `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) is correctly placed
- Check Firebase project settings and API keys
- Ensure Firebase services are enabled in console

### Issue: Notifications not working
- Check FCM token generation
- Verify permissions are granted
- Check notification permissions in app settings

### Issue: Messages not syncing
- Verify Firestore security rules
- Check network connectivity
- Ensure Firestore database is created and active

## 📚 Learning Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Flutter Plugins](https://firebase.flutter.dev/)
- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Cloud Firestore](https://firebase.google.com/docs/firestore)
- [Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)

## 📝 Future Enhancements

- [ ] Group chat functionality
- [ ] Voice and video calling
- [ ] Message search
- [ ] User blocking
- [ ] Message reactions
- [ ] File/image sharing
- [ ] End-to-end encryption
- [ ] Dark mode theme
- [ ] Multiple language support
- [ ] User presence indicators

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## ✉️ Support

For support, email support@chatapp.com or open an issue in the repository.

## 👨‍💻 Author

Your Name/Organization

---

**Happy Coding! 🚀**
