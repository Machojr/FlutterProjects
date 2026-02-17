# Firebase Firestore Database Schema

This document outlines the complete database schema for the Flutter Chat App, including all collections, documents, and fields required for user authentication, messaging, and notifications.

## 📊 Implementation Strategy by Phase

Before diving into the schema details, here's how collections should be created and utilized across development phases:

### **Phase 1: Firebase Configuration & Authentication** 🔐
**Collections to Create**:
- `users` - Only store basic auth data initially

**Required Fields**:
- userId (from Firebase Auth)
- email
- createdAt

---

### **Phase 2: User Management & Discovery** 👥
**Collections to Enhance**:
- `users` - Add full profile information

**New Fields**:
- displayName
- photoUrl
- bio
- isOnline
- lastSeen
- fcmToken

**Indexes Needed**:
- `isOnline` (Ascending)
- `createdAt` (Descending)

---

### **Phase 3: User Interface & Navigation** 🎨
**Collections to Create**:
- `user_presence` - Track real-time status

**Purpose**:
- Efficient real-time presence updates
- Avoid constant writes to main `users` collection

---

### **Phase 4: Chat Infrastructure & Messaging** 💬
**Collections to Create**:
- `chats` - Conversation metadata
- `chats/{chatId}/messages` - Individual messages

**Critical Fields in Chats**:
- participants
- lastMessage
- lastMessageTime
- createdAt

**Critical Fields in Messages**:
- senderId
- receiverId
- text
- timestamp
- isRead

**Indexes Needed**:
- `chats`: participants (Ascending), updatedAt (Descending)
- `messages`: timestamp (Ascending), isRead (Ascending)

---

### **Phase 5: Notifications System** 🔔
**Collections to Create**:
- `notifications` - Push notification history

**Required Fields**:
- userId (recipient)
- fromUserId
- type
- title
- body
- timestamp

**Indexes Needed**:
- userId + timestamp (Ascending + Descending)
- isRead (Ascending)

---

### **Phase 6: Advanced Features & Polish** ✨
**Collections to Create**:
- `blocks` - User blocking management

**Required Fields**:
- blockerId
- blockedUserId
- createdAt

**Indexes Needed**:
- blockerId + createdAt (Ascending + Descending)

---

## 📊 Collections Overview by Phase

```
PHASE 1 (Auth)
├── users (basic)
│   ├── userId
│   ├── email
│   └── createdAt

PHASE 2 (User Mgmt)
├── users (full profile)
│   ├── userId
│   ├── email
│   ├── displayName
│   ├── photoUrl
│   ├── bio
│   ├── isOnline
│   ├── lastSeen
│   └── fcmToken

PHASE 3 (UI)
├── users (unchanged)
└── user_presence (new)
    ├── userId
    ├── isOnline
    └── lastSeen

PHASE 4 (Messaging)
├── users (unchanged)
├── user_presence (unchanged)
├── chats (new)
│   ├── chatId
│   ├── participants
│   ├── lastMessage
│   └── lastMessageTime
│   │
│   └── messages (subcollection)
│       ├── messageId
│       ├── senderId
│       ├── text
│       ├── timestamp
│       └── isRead

PHASE 5 (Notifications)
├── (all previous)
└── notifications (new)
    ├── notificationId
    ├── userId
    ├── fromUserId
    ├── title
    ├── timestamp
    └── isRead

PHASE 6 (Advanced)
├── (all previous)
└── blocks (new)
    ├── blockId
    ├── blockerId
    └── blockedUserId
```

---

## 📊 Collections Overview

```
firestore/
├── users/
├── chats/
├── messages/
├── notifications/
├── blocks/
└── user_presence/
```

---

## 1. **Users Collection**

Stores user profile information and authentication-related data.

### Collection Path: `users/{userId}`

### Document Structure:

```json
{
  "userId": "uid123xyz",
  "email": "john.doe@example.com",
  "displayName": "John Doe",
  "photoUrl": "https://firebasestorage.googleapis.com/.../photo.jpg",
  "bio": "Software developer | Coffee lover",
  "phoneNumber": "+1234567890",
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-02-14T14:22:00Z",
  "isOnline": true,
  "lastSeen": "2024-02-14T14:22:00Z",
  "fcmToken": "eXpEdzBXOEt6UzpBUEYxMmpqMTA...",
  "blockedUsers": ["uid456abc", "uid789def"],
  "deviceTokens": [
    {
      "token": "eXpEdzBXOEt6UzpBUEYxMmpqMTA...",
      "device": "Android",
      "deviceName": "Samsung Galaxy S21",
      "addedAt": "2024-02-14T10:00:00Z"
    }
  ]
}
```

### Field Descriptions:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `userId` | String | ✓ | Unique Firebase UID (document ID) |
| `email` | String | ✓ | User email for authentication |
| `displayName` | String | ✓ | User's display name |
| `photoUrl` | String | ✗ | Profile picture URL |
| `bio` | String | ✗ | User biography/status |
| `phoneNumber` | String | ✗ | User's phone number |
| `createdAt` | Timestamp | ✓ | Account creation timestamp |
| `updatedAt` | Timestamp | ✓ | Last profile update timestamp |
| `isOnline` | Boolean | ✓ | Current online status |
| `lastSeen` | Timestamp | ✓ | Last activity timestamp |
| `fcmToken` | String | ✓ | Firebase Cloud Messaging token |
| `blockedUsers` | Array | ✓ | List of blocked user IDs |
| `deviceTokens` | Array | ✗ | Multiple device tokens for notifications |

### Indexes Needed:
- `isOnline` (Ascending)
- `createdAt` (Descending)
- `email` (Ascending) - for search

---

## 2. **Chats Collection**

Represents conversations between two users (1-to-1 chats).

### Collection Path: `chats/{chatId}`

### Document Structure:

```json
{
  "chatId": "chat_abc123xyz",
  "participants": ["uid123xyz", "uid456abc"],
  "participantDetails": {
    "uid123xyz": {
      "displayName": "John Doe",
      "photoUrl": "https://...",
      "isOnline": true,
      "unreadCount": 0
    },
    "uid456abc": {
      "displayName": "Jane Smith",
      "photoUrl": "https://...",
      "isOnline": false,
      "unreadCount": 3
    }
  },
  "lastMessage": "Hey, how are you?",
  "lastMessageSenderId": "uid123xyz",
  "lastMessageTime": "2024-02-14T14:15:00Z",
  "lastMessageType": "text",
  "createdAt": "2024-02-01T10:30:00Z",
  "updatedAt": "2024-02-14T14:15:00Z",
  "isActive": true,
  "pinnedAt": null
}
```

### Field Descriptions:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `chatId` | String | ✓ | Unique chat identifier (document ID) |
| `participants` | Array | ✓ | Array of two user IDs in the chat |
| `participantDetails` | Object | ✓ | Details of each participant for quick access |
| `lastMessage` | String | ✓ | Preview of last message |
| `lastMessageSenderId` | String | ✓ | ID of who sent the last message |
| `lastMessageTime` | Timestamp | ✓ | Timestamp of last message |
| `lastMessageType` | String | ✓ | Type: "text", "image", "file" |
| `createdAt` | Timestamp | ✓ | Chat creation timestamp |
| `updatedAt` | Timestamp | ✓ | Last update timestamp |
| `isActive` | Boolean | ✓ | Whether chat is active |
| `pinnedAt` | Timestamp | ✗ | When chat was pinned (null if not) |

### Indexes Needed:
- `participants` (Ascending)
- `updatedAt` (Descending)
- `lastMessageTime` (Descending)

### Subcollections:

#### `chats/{chatId}/messages`
See Messages Collection below.

---

## 3. **Messages Collection**

Stores individual messages within chats. This should be a subcollection under chats.

### Collection Path: `chats/{chatId}/messages/{messageId}`

### Document Structure:

```json
{
  "messageId": "msg_xyz789abc",
  "chatId": "chat_abc123xyz",
  "senderId": "uid123xyz",
  "senderName": "John Doe",
  "senderPhotoUrl": "https://...",
  "receiverId": "uid456abc",
  "text": "Hey, how are you doing?",
  "type": "text",
  "timestamp": "2024-02-14T14:15:00Z",
  "isRead": true,
  "readAt": "2024-02-14T14:16:30Z",
  "editedAt": null,
  "deletedAt": null,
  "reactions": {
    "❤️": ["uid456abc"],
    "😂": ["uid123xyz", "uid456abc"]
  },
  "replyTo": null,
  "metadata": {
    "platform": "Android",
    "clientId": "client_123"
  }
}
```

### Field Descriptions:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `messageId` | String | ✓ | Unique message identifier (document ID) |
| `chatId` | String | ✓ | Parent chat ID |
| `senderId` | String | ✓ | ID of message sender |
| `senderName` | String | ✓ | Display name of sender (denormalized) |
| `senderPhotoUrl` | String | ✗ | Sender's photo URL (denormalized) |
| `receiverId` | String | ✓ | ID of message receiver |
| `text` | String | ✗ | Message content (nullable for media) |
| `type` | String | ✓ | Type: "text", "image", "file", "deleted" |
| `timestamp` | Timestamp | ✓ | When message was sent |
| `isRead` | Boolean | ✓ | Whether receiver has read it |
| `readAt` | Timestamp | ✗ | When message was read |
| `editedAt` | Timestamp | ✗ | When message was last edited |
| `deletedAt` | Timestamp | ✗ | When message was deleted (soft delete) |
| `reactions` | Object | ✗ | Emoji reactions and who added them |
| `replyTo` | Object | ✗ | Reference to replied message |
| `metadata` | Object | ✗ | Platform and client information |

### Indexes Needed:
- `timestamp` (Ascending)
- `senderId` (Ascending)
- `isRead` (Ascending)

### Example Reaction Structure:
```json
{
  "emojis": {
    "❤️": {
      "count": 1,
      "users": ["uid456abc"]
    },
    "😂": {
      "count": 2,
      "users": ["uid123xyz", "uid456abc"]
    }
  }
}
```

---

## 4. **Notifications Collection**

Stores notification records for message history and push notification management.

### Collection Path: `notifications/{notificationId}`

### Document Structure:

```json
{
  "notificationId": "notif_abc123xyz",
  "type": "message",
  "userId": "uid456abc",
  "fromUserId": "uid123xyz",
  "fromUserName": "John Doe",
  "chatId": "chat_abc123xyz",
  "messageId": "msg_xyz789abc",
  "title": "New message from John Doe",
  "body": "Hey, how are you?",
  "timestamp": "2024-02-14T14:15:00Z",
  "isRead": false,
  "readAt": null,
  "action": "message",
  "deepLink": "chatapp://chat/chat_abc123xyz",
  "sent": true,
  "sentAt": "2024-02-14T14:15:05Z",
  "deliveryStatus": "delivered"
}
```

### Field Descriptions:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `notificationId` | String | ✓ | Unique notification ID (document ID) |
| `type` | String | ✓ | Type: "message", "request", "system" |
| `userId` | String | ✓ | Recipient user ID |
| `fromUserId` | String | ✓ | Sender user ID |
| `fromUserName` | String | ✓ | Sender's display name |
| `chatId` | String | ✓ | Associated chat ID |
| `messageId` | String | ✓ | Associated message ID |
| `title` | String | ✓ | Notification title |
| `body` | String | ✓ | Notification body/message |
| `timestamp` | Timestamp | ✓ | When notification was created |
| `isRead` | Boolean | ✓ | Whether user has seen it |
| `readAt` | Timestamp | ✗ | When notification was read |
| `action` | String | ✓ | Action to perform: "message", "profile", etc. |
| `deepLink` | String | ✗ | Deep link to navigate to |
| `sent` | Boolean | ✓ | Whether push was sent |
| `sentAt` | Timestamp | ✗ | When push was sent to FCM |
| `deliveryStatus` | String | ✓ | Status: "sent", "delivered", "failed" |

### Indexes Needed:
- `userId` + `timestamp` (Ascending + Descending)
- `isRead` (Ascending)
- `createdAt` (Descending)

---

## 5. **User Presence Collection** (Optional but Recommended)

Tracks real-time user online status with TTL cleanup.

### Collection Path: `user_presence/{userId}`

### Document Structure:

```json
{
  "userId": "uid123xyz",
  "isOnline": true,
  "lastSeen": "2024-02-14T14:22:00Z",
  "currentChat": "chat_abc123xyz",
  "device": {
    "platform": "Android",
    "osVersion": "14"
  },
  "updatedAt": "2024-02-14T14:22:00Z"
}
```

### Field Descriptions:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `userId` | String | ✓ | User ID (document ID) |
| `isOnline` | Boolean | ✓ | Current online status |
| `lastSeen` | Timestamp | ✓ | Last activity timestamp |
| `currentChat` | String | ✗ | Chat ID user is currently viewing |
| `device` | Object | ✗ | Device information |
| `updatedAt` | Timestamp | ✓ | Last update timestamp |

### TTL Policy:
Set a TTL of 5-10 minutes to automatically clean up stale presence data.

---

## 6. **Blocks Collection** (Optional)

Manages user blocking functionality.

### Collection Path: `blocks/{blockId}`

### Document Structure:

```json
{
  "blockId": "block_abc123xyz",
  "blockerId": "uid123xyz",
  "blockedUserId": "uid456abc",
  "reason": "Spam",
  "createdAt": "2024-02-14T10:00:00Z",
  "expiresAt": null
}
```

### Field Descriptions:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `blockId` | String | ✓ | Unique block ID (document ID) |
| `blockerId` | String | ✓ | ID of user blocking |
| `blockedUserId` | String | ✓ | ID of user being blocked |
| `reason` | String | ✗ | Reason for blocking |
| `createdAt` | Timestamp | ✓ | Block creation timestamp |
| `expiresAt` | Timestamp | ✗ | When block expires (null if permanent) |

### Indexes Needed:
- `blockerId` + `createdAt` (Ascending + Descending)

---

## 📋 Security Rules

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function to check authentication
    function isSignedIn() {
      return request.auth != null;
    }
    
    function isCurrentUser(userId) {
      return request.auth.uid == userId;
    }
    
    // Users collection - readable by authenticated users, writable only by self
    match /users/{userId} {
      allow read: if isSignedIn();
      allow create: if isCurrentUser(userId);
      allow update, delete: if isCurrentUser(userId);
    }
    
    // Chats collection - accessible only to participants
    match /chats/{chatId} {
      allow read: if isSignedIn() && request.auth.uid in resource.data.participants;
      allow create: if isSignedIn();
      allow update: if isSignedIn() && request.auth.uid in resource.data.participants;
      allow delete: if isSignedIn() && request.auth.uid in resource.data.participants;
      
      // Messages subcollection
      match /messages/{messageId} {
        allow read: if isSignedIn() && request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
        allow create: if isSignedIn() && request.auth.uid == request.resource.data.senderId;
        allow update: if isSignedIn() && request.auth.uid == resource.data.senderId;
        allow delete: if isSignedIn() && request.auth.uid == resource.data.senderId;
      }
    }
    
    // Notifications - readable only by recipient
    match /notifications/{notificationId} {
      allow read: if isSignedIn() && request.auth.uid == resource.data.userId;
      allow create: if isSignedIn();
      allow update: if isSignedIn() && request.auth.uid == resource.data.userId;
      allow delete: if isSignedIn() && request.auth.uid == resource.data.userId;
    }
    
    // User presence
    match /user_presence/{userId} {
      allow read: if isSignedIn();
      allow write: if isCurrentUser(userId);
    }
    
    // Blocks collection
    match /blocks/{blockId} {
      allow read: if isSignedIn() && (request.auth.uid == resource.data.blockerId || request.auth.uid == resource.data.blockedUserId);
      allow create: if isSignedIn() && request.auth.uid == request.resource.data.blockerId;
      allow delete: if isSignedIn() && request.auth.uid == resource.data.blockerId;
    }
  }
}
```

---

## 🔄 Data Relationships

### User to Chats
- One user can have many chats
- One chat has exactly 2 users (participants)
- Relationship: 1-to-N

### Chat to Messages
- One chat has many messages
- One message belongs to one chat
- Relationship: 1-to-N (Subcollection)

### User to Notifications
- One user receives many notifications
- One notification is for one user
- Relationship: 1-to-N

### User to Blocks
- One user can block many users
- One block record involves two users
- Relationship: 1-to-N

---

## 📱 Data Denormalization Strategy

To optimize read performance and reduce latency:

### Denormalized Fields in Chats Document:
```json
{
  "participantDetails": {
    "userId": {
      "displayName": "...",
      "photoUrl": "...",
      "isOnline": true
    }
  },
  "lastMessage": "...",
  "lastMessageSenderId": "...",
  "lastMessageTime": "..."
}
```

### Reason: 
- Avoids multiple reads to fetch chat list with participant info
- Enables quick display of chat preview without extra queries

### Update Strategy:
- When user updates profile, update `participantDetails` in all their chats
- When message is sent, update `lastMessage` and `lastMessageTime` in chat document

---

## 🔍 Query Patterns

### 1. **Get User Chats List**
```
Collection: chats
Query: where participants array-contains current userId
Order by: lastMessageTime descending
Limit: 20
```

### 2. **Get Messages in Chat**
```
Collection: chats/{chatId}/messages
Query: where timestamp >= startDate AND timestamp <= endDate
Order by: timestamp ascending
Limit: 20
```

### 3. **Get Unread Messages Count**
```
Collection: chats/{chatId}/messages
Query: where isRead == false AND receiverId == currentUserId
```

### 4. **Get All Users (for discovery)**
```
Collection: users
Query: order by createdAt descending
Limit: 50
```

### 5. **Search Users by Name**
```
Collection: users
Query: where displayName matches search pattern (requires full-text search or client-side filtering)
```

### 6. **Get User's Notifications**
```
Collection: notifications
Query: where userId == currentUserId AND isRead == false
Order by: timestamp descending
Limit: 20
```

---

## 📊 Collection Structure Summary

| Collection | Purpose | Document Count (Estimate) | Notes |
|------------|---------|---------------------------|-------|
| `users` | User profiles | 1 per user | Shared across all data |
| `chats` | Conversations | 1 per conversation | Denormalized data for performance |
| `messages` (subcollection) | Individual messages | 10-100+ per chat | Can grow very large |
| `notifications` | Message notifications | High volume | Consider archiving old records |
| `user_presence` | Real-time status | 1 per active user | TTL cleanup recommended |
| `blocks` | Blocked users | Low volume | Referenced in chat logic |

---

## ✅ Implementation Checklist by Phase

### **Phase 1: Firebase Configuration & Authentication** 🔐

**Firestore Setup**:
- [ ] Create Firebase project in console
- [ ] Enable Firestore (production mode)
- [ ] Set collections to create on first document write
- [ ] Create `users` collection (will be auto-created on signup)

**Security Rules** - Phase 1 Minimal:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow create: if request.auth.uid == userId;
      allow update: if request.auth.uid == userId;
    }
  }
}
```

**Initial User Document Structure**:
```json
{
  "userId": "uid123xyz",
  "email": "user@example.com",
  "createdAt": "2024-02-14T10:30:00Z"
}
```

**Validation Checklist**:
- [ ] Users collection appears in Firestore on signup
- [ ] User document contains email and userId
- [ ] createdAt timestamp is automatically generated

---

### **Phase 2: User Management & Discovery** 👥

**Firestore Enhancements**:
- [ ] Add Firestore indexes for `users` collection
- [ ] Update security rules to allow public user profiles

**Index Creation**:
- [ ] Create index: `users.isOnline` (Ascending)
- [ ] Create index: `users.createdAt` (Descending)

**Update User Document**:
```json
{
  "userId": "uid123xyz",
  "email": "user@example.com",
  "displayName": "John Doe",
  "photoUrl": "https://...",
  "bio": "Software developer",
  "phoneNumber": "+1234567890",
  "isOnline": true,
  "lastSeen": "2024-02-14T14:22:00Z",
  "fcmToken": "eXpEdzBXOEt6UzpBUEYxMmpqMTA...",
  "blockedUsers": [],
  "createdAt": "2024-02-14T10:30:00Z",
  "updatedAt": "2024-02-14T14:22:00Z"
}
```

**Security Rules** - Phase 2:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow create: if request.auth.uid == userId;
      allow update, delete: if request.auth.uid == userId;
    }
  }
}
```

**Validation Checklist**:
- [ ] All users visible in users list (public read access)
- [ ] Users can update their own profile only
- [ ] Indexes created for efficient queries
- [ ] FCM token stored and retrievable

---

### **Phase 3: User Interface & Navigation** 🎨

**Firestore Enhancements**:
- [ ] Create `user_presence` collection
- [ ] Set up TTL policy for presence data (5-10 min)

**New Collection - user_presence**:
```json
{
  "userId": "uid123xyz",
  "isOnline": true,
  "lastSeen": "2024-02-14T14:22:00Z",
  "currentChat": "chat_abc123xyz",
  "device": {
    "platform": "Android",
    "osVersion": "14"
  },
  "updatedAt": "2024-02-14T14:22:00Z"
}
```

**Security Rules** - Phase 3:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow create: if request.auth.uid == userId;
      allow update, delete: if request.auth.uid == userId;
    }
    
    match /user_presence/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
  }
}
```

**Validation Checklist**:
- [ ] user_presence collection created
- [ ] Online status updates in real-time
- [ ] Old presence data cleaned up automatically (TTL)
- [ ] No issues from frequent writes

---

### **Phase 4: Chat Infrastructure & Messaging** 💬

**Firestore Enhancements**:
- [ ] Create `chats` collection
- [ ] Create `messages` subcollection under chats
- [ ] Create Firestore indexes for efficient queries

**New Collection - chats**:
```json
{
  "chatId": "chat_abc123xyz",
  "participants": ["uid123xyz", "uid456abc"],
  "participantDetails": {
    "uid123xyz": {
      "displayName": "John Doe",
      "photoUrl": "https://...",
      "isOnline": true,
      "unreadCount": 0
    },
    "uid456abc": {
      "displayName": "Jane Smith",
      "photoUrl": "https://...",
      "isOnline": false,
      "unreadCount": 3
    }
  },
  "lastMessage": "Hey, how are you?",
  "lastMessageSenderId": "uid123xyz",
  "lastMessageTime": "2024-02-14T14:15:00Z",
  "lastMessageType": "text",
  "createdAt": "2024-02-01T10:30:00Z",
  "updatedAt": "2024-02-14T14:15:00Z",
  "isActive": true,
  "pinnedAt": null
}
```

**New Subcollection - chats/{chatId}/messages**:
```json
{
  "messageId": "msg_xyz789abc",
  "chatId": "chat_abc123xyz",
  "senderId": "uid123xyz",
  "senderName": "John Doe",
  "senderPhotoUrl": "https://...",
  "receiverId": "uid456abc",
  "text": "Hey, how are you doing?",
  "type": "text",
  "timestamp": "2024-02-14T14:15:00Z",
  "isRead": true,
  "readAt": "2024-02-14T14:16:30Z",
  "editedAt": null,
  "deletedAt": null,
  "reactions": {},
  "replyTo": null,
  "metadata": {}
}
```

**Indexes to Create**:
- `chats`: participants (Ascending), updatedAt (Descending)
- `chats`: lastMessageTime (Descending)
- `messages`: timestamp (Ascending)
- `messages`: senderId (Ascending)
- `messages`: isRead (Ascending)

**Security Rules** - Phase 4:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow create: if request.auth.uid == userId;
      allow update, delete: if request.auth.uid == userId;
    }
    
    match /user_presence/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    match /chats/{chatId} {
      allow read: if request.auth != null && request.auth.uid in resource.data.participants;
      allow create: if request.auth != null;
      allow update: if request.auth != null && request.auth.uid in resource.data.participants;
      allow delete: if request.auth != null && request.auth.uid in resource.data.participants;
      
      match /messages/{messageId} {
        allow read: if request.auth != null && request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
        allow create: if request.auth != null && request.auth.uid == request.resource.data.senderId;
        allow update: if request.auth != null && request.auth.uid == resource.data.senderId;
        allow delete: if request.auth != null && request.auth.uid == resource.data.senderId;
      }
    }
  }
}
```

**Validation Checklist**:
- [ ] Chats collection created and indexed
- [ ] Messages subcollection properly nested
- [ ] Chat created when first message sent
- [ ] Last message preview updates correctly
- [ ] Messages appear in real-time
- [ ] Read receipts working
- [ ] Participants can only access their chats

---

### **Phase 5: Notifications System** 🔔

**Firestore Enhancements**:
- [ ] Create `notifications` collection
- [ ] Create Firestore indexes

**New Collection - notifications**:
```json
{
  "notificationId": "notif_abc123xyz",
  "type": "message",
  "userId": "uid456abc",
  "fromUserId": "uid123xyz",
  "fromUserName": "John Doe",
  "chatId": "chat_abc123xyz",
  "messageId": "msg_xyz789abc",
  "title": "New message from John Doe",
  "body": "Hey, how are you?",
  "timestamp": "2024-02-14T14:15:00Z",
  "isRead": false,
  "readAt": null,
  "action": "message",
  "deepLink": "chatapp://chat/chat_abc123xyz",
  "sent": true,
  "sentAt": "2024-02-14T14:15:05Z",
  "deliveryStatus": "delivered"
}
```

**Indexes to Create**:
- `notifications`: userId + timestamp (Ascending + Descending)
- `notifications`: isRead (Ascending)
- `notifications`: userId + isRead (Ascending + Ascending)

**Security Rules** - Phase 5:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // ... previous rules ...
    
    match /notifications/{notificationId} {
      allow read: if request.auth != null && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null;
      allow update: if request.auth != null && request.auth.uid == resource.data.userId;
      allow delete: if request.auth != null && request.auth.uid == resource.data.userId;
    }
  }
}
```

**Validation Checklist**:
- [ ] Notifications created on message send
- [ ] Only recipient can read their notifications
- [ ] FCM token stored correctly
- [ ] Push notifications received on device
- [ ] Deep links navigate to correct chat
- [ ] Notification read status updates

---

### **Phase 6: Advanced Features & Polish** ✨

**Firestore Enhancements**:
- [ ] Create `blocks` collection
- [ ] Create indexes for block queries

**New Collection - blocks**:
```json
{
  "blockId": "block_abc123xyz",
  "blockerId": "uid123xyz",
  "blockedUserId": "uid456abc",
  "reason": "Spam",
  "createdAt": "2024-02-14T10:00:00Z",
  "expiresAt": null
}
```

**Indexes to Create**:
- `blocks`: blockerId + createdAt (Ascending + Descending)

**Full Security Rules** - Phase 6 Complete:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isSignedIn() {
      return request.auth != null;
    }
    
    function isCurrentUser(userId) {
      return request.auth.uid == userId;
    }
    
    match /users/{userId} {
      allow read: if isSignedIn();
      allow create: if isCurrentUser(userId);
      allow update, delete: if isCurrentUser(userId);
    }
    
    match /chats/{chatId} {
      allow read: if isSignedIn() && request.auth.uid in resource.data.participants;
      allow create: if isSignedIn();
      allow update: if isSignedIn() && request.auth.uid in resource.data.participants;
      
      match /messages/{messageId} {
        allow read: if isSignedIn() && request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
        allow create: if isSignedIn() && request.auth.uid == request.resource.data.senderId;
        allow update: if isSignedIn() && request.auth.uid == resource.data.senderId;
        allow delete: if isSignedIn() && request.auth.uid == resource.data.senderId;
      }
    }
    
    match /notifications/{notificationId} {
      allow read: if isSignedIn() && request.auth.uid == resource.data.userId;
      allow create: if isSignedIn();
      allow update: if isSignedIn() && request.auth.uid == resource.data.userId;
      allow delete: if isSignedIn() && request.auth.uid == resource.data.userId;
    }
    
    match /user_presence/{userId} {
      allow read: if isSignedIn();
      allow write: if isCurrentUser(userId);
    }
    
    match /blocks/{blockId} {
      allow read: if isSignedIn() && (request.auth.uid == resource.data.blockerId || request.auth.uid == resource.data.blockedUserId);
      allow create: if isSignedIn() && request.auth.uid == request.resource.data.blockerId;
      allow delete: if isSignedIn() && request.auth.uid == resource.data.blockerId;
    }
  }
}
```

**Validation Checklist**:
- [ ] User blocking functionality works
- [ ] Blocked users don't appear in lists
- [ ] Blocked users can't message each other
- [ ] Message search queries optimized
- [ ] All security rules working correctly
- [ ] No unauthorized access possible

---

## 🚀 Implementation Tips

1. **Use Batch Writes**: When creating a chat, write to both `chats` and create/update related documents in batch operations to maintain consistency.

2. **Real-time Listeners**: 
   - Listen to chats list in home screen (cached data)
   - Listen to messages in chat screen (real-time updates)
   - Listen to user presence for online status
   - Cleanup listeners on screen navigation to save resources

3. **Pagination**: Use query cursors for message pagination (avoid loading all messages at once).
   ```dart
   // Load first 20 messages
   Query query = firestore
     .collection('chats')
     .doc(chatId)
     .collection('messages')
     .orderBy('timestamp', descending: true)
     .limit(20);
   ```

4. **Caching**: Cache user profiles locally in the app to reduce reads.
   - Store in SharedPreferences for quick access
   - Update cache when profile changes

5. **Cleanup**: Implement cloud functions to:
   - Clean up old notifications (older than 90 days)
   - Update user presence status periodically
   - Archive old messages (optional)

6. **Indexes**: Firestore will suggest indexes as you run queries. Create them immediately to avoid query failures in production.

7. **Cost Optimization**:
   - Denormalize frequently accessed data (participantDetails in chats)
   - Avoid unnecessary reads with proper indexing
   - Use subcollections for large data sets

8. **Data Validation**:
   - Validate data in Cloud Functions before writing
   - Use Firestore validation in security rules
   - Sanitize user input to prevent injection

---

## 📱 Firestore Database Growth Estimates

Assuming 1000 users with an average of 5 chats per user:

| Collection | Est. Documents | Est. Size | Monthly Growth |
|-----------|----------------|-----------|-----------------|
| users | 1,000 | ~2 MB | +100-200 docs |
| chats | 5,000 | ~10 MB | +500-1,000 docs |
| messages | 100,000+ | ~100+ MB | +50,000+ docs |
| notifications | 50,000+ | ~30+ MB | +30,000+ docs |
| user_presence | 200-500 | <1 MB | Recycled (TTL) |
| blocks | 500-1,000 | <1 MB | +50-100 docs |

**Recommendation**: Monitor Firestore usage and implement archiving for old messages/notifications after 90 days.

---

**Version**: 1.0  
**Last Updated**: February 14, 2026  
**Status**: Ready for Phase-by-Phase Implementation
