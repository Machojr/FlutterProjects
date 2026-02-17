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

## � Development Phases

This project is divided into 7 phases for organized and systematic development. Each phase builds upon the previous one.

### **Phase 0: Project Setup & Dependencies** ⚙️
**Duration**: 1-2 days | **Status**: ⏳ Upcoming

**Objectives**:
- Set up Flutter project structure
- Add Firebase and necessary dependencies to `pubspec.yaml`
- Configure build files (Android/iOS)
- Set up version control

**Deliverables**:
- ✅ Properly configured `pubspec.yaml`
- ✅ Flutter project structure in place
- ✅ Initial directory structure created
- ✅ All dependencies installed and compiled

**Key Tasks**:
1. Create `lib/` directory structure (screens, models, services, providers, utils)
2. Add Firebase packages: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_messaging`
3. Add state management: `provider`
4. Add UI/UX packages: `intl`, `image_picker`
5. Run `flutter pub get`
6. Test basic app runs without errors

**Files to Create**:
- `lib/main.dart` (basic scaffold)
- `lib/models/` (directory)
- `lib/services/` (directory)
- `lib/screens/` (directory)
- `lib/providers/` (directory)
- `lib/utils/` (directory)

---

### **Phase 1: Firebase Configuration & Authentication** 🔐
**Duration**: 2-3 days | **Status**: ⏳ Upcoming

**Objectives**:
- Configure Firebase for Android and iOS
- Implement Firebase Authentication service
- Create login and signup screens
- Set up authentication state management

**Dependencies**: Phase 0 ✅

**Deliverables**:
- ✅ Firebase project configured
- ✅ `AuthService` class implemented
- ✅ `AuthProvider` for state management
- ✅ Login screen (`login_screen.dart`)
- ✅ Signup screen (`signup_screen.dart`)
- ✅ Password reset functionality
- ✅ Auth state persistence

**Key Tasks**:
1. Create Firebase project and configure `google-services.json`, `GoogleService-Info.plist`
2. Create `AuthService` with methods: `signUp()`, `logIn()`, `logOut()`, `resetPassword()`
3. Create `AuthProvider` using Provider package
4. Build `LoginScreen` with email/password fields
5. Build `SignupScreen` with form validation
6. Implement `ForgotPasswordScreen`
7. Create auth guards for route protection

**Files to Create**:
- `lib/services/auth_service.dart`
- `lib/providers/auth_provider.dart`
- `lib/screens/auth/login_screen.dart`
- `lib/screens/auth/signup_screen.dart`
- `lib/screens/auth/forgot_password_screen.dart`
- `lib/utils/validators.dart`

---

### **Phase 2: User Management & Discovery** 👥
**Duration**: 2-3 days | **Status**: ⏳ Upcoming

**Objectives**:
- Create User model and Firestore integration
- Implement user profile creation and updates
- Build user discovery/browsing functionality
- Create user profile viewing screen

**Dependencies**: Phase 1 ✅

**Deliverables**:
- ✅ `UserModel` class created
- ✅ `FirestoreService` implemented
- ✅ `UserProvider` for state management
- ✅ Users collection in Firestore
- ✅ Users list screen (`users_list_screen.dart`)
- ✅ User profile screen (`user_profile_screen.dart`)
- ✅ User profile update functionality

**Key Tasks**:
1. Create `UserModel` class with all fields
2. Create `FirestoreService` with user CRUD operations
3. Create `UserProvider` for user data state management
4. Implement user profile creation on first login
5. Build `UsersListScreen` to display all users with pagination
6. Build `UserProfileScreen` for viewing user details
7. Implement user search/filter functionality
8. Create user profile edit screen

**Files to Create**:
- `lib/models/user_model.dart`
- `lib/services/firestore_service.dart`
- `lib/providers/user_provider.dart`
- `lib/screens/users/users_list_screen.dart`
- `lib/screens/users/user_profile_screen.dart`
- `lib/screens/profile/edit_profile_screen.dart`

---

### **Phase 3: User Interface & Navigation** 🎨
**Duration**: 2-3 days | **Status**: ⏳ Upcoming

**Objectives**:
- Create app navigation structure
- Build main home screen with bottom navigation
- Create app theme and styling
- Implement responsive UI layout

**Dependencies**: Phase 2 ✅

**Deliverables**:
- ✅ Navigation structure implemented (bottom nav, routes)
- ✅ Home screen (`home_screen.dart`)
- ✅ App theme and colors defined
- ✅ Consistent UI across all screens
- ✅ Responsive design for different screen sizes

**Key Tasks**:
1. Create navigation/routing system
2. Design and implement bottom navigation bar
3. Create `HomeScreen` as main hub
4. Define app theme (colors, fonts, styles)
5. Create reusable widgets/components
6. Implement responsive layout
7. Add splash screen and loading states
8. Create error handling UI components

**Files to Create**:
- `lib/main.dart` (update with routing)
- `lib/screens/home/home_screen.dart`
- `lib/screens/home/chats_list_screen.dart`
- `lib/widgets/` (directory for reusable components)
- `lib/utils/app_theme.dart`
- `lib/utils/constants.dart`

---

### **Phase 4: Chat Infrastructure & Messaging** 💬
**Duration**: 3-4 days | **Status**: ⏳ Upcoming

**Objectives**:
- Create Chat and Message models
- Implement real-time messaging service
- Build chat list and message screens
- Implement read receipts and online status

**Dependencies**: Phase 3 ✅

**Deliverables**:
- ✅ `ChatModel` and `MessageModel` created
- ✅ Chats and messages collections in Firestore
- ✅ `ChatProvider` for state management
- ✅ Chats list screen with last message preview
- ✅ Chat screen with message display
- ✅ Real-time message listening
- ✅ Message sending functionality
- ✅ Read receipt and typing indicators

**Key Tasks**:
1. Create `ChatModel` and `MessageModel` classes
2. Extend `FirestoreService` with chat/message operations
3. Create `ChatProvider` for chat state management
4. Build `ChatsListScreen` showing all conversations
5. Build `ChatScreen` for messaging interface
6. Implement real-time message listeners
7. Create message input widget
8. Implement read receipts
9. Add online status indicators
10. Implement message editing and deletion (soft delete)

**Files to Create**:
- `lib/models/chat_model.dart`
- `lib/models/message_model.dart`
- `lib/providers/chat_provider.dart`
- `lib/screens/chat/chat_screen.dart`
- `lib/screens/chat/message_bubble.dart`
- `lib/widgets/message_input_widget.dart`
- `lib/widgets/typing_indicator.dart`

---

### **Phase 5: Notifications System** 🔔
**Duration**: 2-3 days | **Status**: ⏳ Upcoming

**Objectives**:
- Set up Firebase Cloud Messaging (FCM)
- Implement push notification service
- Handle notification permissions
- Create notification history/center

**Dependencies**: Phase 4 ✅

**Deliverables**:
- ✅ FCM configured for Android and iOS
- ✅ `NotificationService` implemented
- ✅ Permission handling (Android 13+, iOS)
- ✅ Push notifications receiving and displaying
- ✅ Notification taps navigate to correct chat
- ✅ Notifications collection in Firestore
- ✅ Notification history/center screen

**Key Tasks**:
1. Set up Firebase Cloud Messaging in Firebase Console
2. Configure FCM for Android (manifest, permissions)
3. Configure FCM for iOS (certificates, provisioning)
4. Create `NotificationService` class
5. Handle notification permissions
6. Implement background message handling
7. Build notification display in foreground
8. Create notification click handlers with deep linking
9. Build notification history screen
10. Create notification center/inbox

**Files to Create**:
- `lib/services/notification_service.dart`
- `lib/services/fcm_config.dart`
- `lib/models/notification_model.dart`
- `lib/screens/notifications/notifications_screen.dart`
- `lib/workers/notification_worker.dart`

---

### **Phase 6: Advanced Features & Polish** ✨
**Duration**: 3-4 days | **Status**: ⏳ Upcoming

**Objectives**:
- Add user blocking functionality
- Implement message search
- Add user presence/typing indicators
- Implement performance optimizations
- Add error handling and validation

**Dependencies**: Phase 5 ✅

**Deliverables**:
- ✅ User blocking/unblocking
- ✅ Message search functionality
- ✅ Typing indicators
- ✅ User presence status
- ✅ Pull-to-refresh functionality
- ✅ Offline message queue
- ✅ Caching strategies
- ✅ Error handling throughout

**Key Tasks**:
1. Implement user blocking system
2. Create blocks collection and management
3. Add message search with Firestore queries
4. Implement typing indicators
5. Add user presence status tracking
6. Implement pull-to-refresh on chats list
7. Create offline message queue
8. Add local caching
9. Implement comprehensive error handling
10. Add loading states and skeletons

**Files to Create**:
- `lib/models/block_model.dart`
- `lib/services/block_service.dart`
- `lib/screens/settings/blocked_users_screen.dart`
- `lib/utils/cache_manager.dart`
- `lib/utils/error_handler.dart`

---

### **Phase 7: Testing & Deployment** 🚀
**Duration**: 2-3 days | **Status**: ⏳ Upcoming

**Objectives**:
- Write unit and widget tests
- Test on real devices
- Build release APK/IPA
- Deploy to app stores
- Create documentation

**Dependencies**: Phase 6 ✅

**Deliverables**:
- ✅ Unit tests for services
- ✅ Widget tests for screens
- ✅ Release build (APK/IPA)
- ✅ Google Play Store listing
- ✅ App Store listing
- ✅ User documentation
- ✅ API documentation

**Key Tasks**:
1. Write unit tests for services
2. Write widget tests for screens
3. Perform manual testing on devices
4. Create release build for Android (APK/AAB)
5. Create release build for iOS (IPA)
6. Set up Google Play Console
7. Set up Apple App Store Connect
8. Create app store listings and screenshots
9. Create user guide/help documentation
10. Set up analytics and crash reporting

**Files to Create**:
- `test/services/auth_service_test.dart`
- `test/services/firestore_service_test.dart`
- `test/screens/login_screen_test.dart`
- `docs/USER_GUIDE.md`
- `docs/API_REFERENCE.md`

---

## 📈 Project Progress Tracker

Use this checklist to track your progress through each phase:

```
[ ] Phase 0: Project Setup & Dependencies
  [ ] Flutter structure created
  [ ] Dependencies added and installed
  [ ] Android/iOS builds working

[ ] Phase 1: Firebase Configuration & Authentication
  [ ] Firebase project configured
  [ ] Auth screens implemented
  [ ] Auth service working
  
[ ] Phase 2: User Management & Discovery
  [ ] User model created
  [ ] User CRUD operations working
  [ ] Users list screen working
  
[ ] Phase 3: User Interface & Navigation
  [ ] Navigation system implemented
  [ ] Theme/styling applied
  [ ] All screens properly laid out
  
[ ] Phase 4: Chat Infrastructure & Messaging
  [ ] Chat and message models created
  [ ] Real-time messaging working
  [ ] Message screen fully functional
  
[ ] Phase 5: Notifications System
  [ ] FCM configured
  [ ] Notifications receiving/displaying
  [ ] Notification handling working
  
[ ] Phase 6: Advanced Features & Polish
  [ ] User blocking implemented
  [ ] Message search working
  [ ] Performance optimized
  
[ ] Phase 7: Testing & Deployment
  [ ] Tests written and passing
  [ ] Build ready for deployment
  [ ] Published on app stores
```

## �📋 Prerequisites

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
