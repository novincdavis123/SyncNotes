## 📒 SyncNotes – Offline-First Notes App (Flutter)

A Flutter-based offline-first notes application with robust local storage, background synchronization, and conflict-aware architecture.

## 🚀 Features
📝 Notes Management
Create notes
Edit notes
Delete notes
View all notes
Store title + body
Works fully offline
💾 Offline-First Architecture
All data stored locally using Hive
No internet required for core functionality
Changes are persisted instantly
🔁 Sync System
Background sync engine
Connectivity-based sync trigger
Sync queue system for offline operations
Retry & recovery mechanism
Adaptive sync loop (fast/normal/slow modes)
Debounced sync triggers
⚙ Sync Operations

The app queues operations when offline:

CREATE note → queued
UPDATE note → queued
DELETE note → queued

Operations are automatically synced when connectivity is restored.

📡 Connectivity Handling
Real-time internet detection
Auto-sync on reconnect
Offline mode detection
Sync status updates
📊 Sync Status (UI)

Each note shows sync state:

✅ Synced
⏳ Pending Sync
⚠️ Conflict (planned / extendable)
🧠 State Management
Bloc pattern used throughout
Clean separation of events & states
Reactive UI updates
## 🏗 Architecture
lib/
├── app/
├── core/
├── di/
├── features/
│   └── notes/
│       ├── data/
│       ├── domain/
│       └── presentation/
├── sync/
│   ├── sync_engine.dart
│   ├── sync_service.dart
│   ├── monitoring/
│   └── queue/
🔄 Sync Engine Design

## The SyncEngine handles:

Connectivity listener
Adaptive sync loop
Debounced sync trigger
Sync cooldown control
Recovery of stuck operations
Sync state transitions
🧾 Data Storage
Hive used for local persistence
Sync operations stored in queue
Notes stored as local models
Soft delete supported (isDeleted flag)
⚠️ Conflict Handling (Planned Extension)

## Future enhancement supports:

Detect local vs remote conflict
Show diff UI
User-driven resolution:
Keep local
Keep server
Merge changes
## 📱 UI Overview
Screens
Notes List Page
Add / Edit Note Page
Components
NoteCard (with sync badge)
SyncStatusIndicator
Empty State View
## 🧪 How It Works
1. Offline Mode
User creates/edits/deletes notes
Changes stored locally
Sync operations queued
2. Online Mode
SyncEngine detects connectivity
Processes queued operations
Updates remote server
Clears queue on success
## 🔧 Tech Stack
Flutter
Dart
Bloc (State Management)
Hive (Local DB)
GetIt (Dependency Injection)
UUID
Connectivity Plus (or custom service)
## ▶️ Getting Started
1. Clone repo
git clone <repo-url>
cd syncnotes
2. Install dependencies
flutter pub get
3. Run app
flutter run