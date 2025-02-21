# 📱 Activity Monitoring AI Assistant

## 🚀 Overview
The **Activity Monitoring AI Assistant** is a Flutter-based mobile application that tracks app usage statistics, stores the data in a local SQLite database, and provides AI-powered insights. The app runs a background service to log app usage and allows users to ask questions about their activity using an AI assistant.

## ✨ Features
- 📊 **Real-time App Usage Tracking**: Logs foreground app usage duration.
- 💾 **Local SQLite Database**: Stores app usage data efficiently for retrieval.
- 📡 **Flutter Background Service**: Continuously monitors activity even when the app is closed.
- 🤖 **AI Assistant**: Processes and analyzes usage data to answer user queries.
- 🔄 **Seamless Data Updates**: Automatically updates the usage duration for apps.
- 📅 **Historical Data Analysis**: Fetches usage stats based on day, month, or year.

## 🛠️ Tech Stack
- **Flutter** (Dart)
- **SQLite (sqflite)** for local storage
- **Method Channels** for native communication
- **Flutter Background Service** for continuous tracking
- **HTTP Requests** for AI-powered insights

## 📥 Installation
### Prerequisites
Ensure you have the following installed:
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Android Studio / VS Code
- An Android Emulator or a physical device

### Steps to Run
1. **Clone the repository**
   ```sh
   git clone https://github.com/your-repo/activity-monitoring.git
   cd activity-monitoring
   ```
2. **Install dependencies**
   ```sh
   flutter pub get
   ```
3. **Run the app**
   ```sh
   flutter run
   ```

## ⚙️ Configuration
### **Permissions**
For the app to track usage statistics, ensure you have enabled **Usage Access Permission** in Android settings.

```dart
Future<void> requestPermissions() async {
  final status = await Permission.usageStats.request();
  if (status.isGranted) {
    print('✅ Permission granted');
  } else {
    print('❌ Permission denied');
  }
}
```

### **Updating Database Schema**
If you change the database schema, delete the old database before restarting:
```sh
adb shell rm /data/data/com.example.verygoodcore.activity_monitoring.dev/databases/app_usage.db
```
Or simply **uninstall and reinstall** the app:
```sh
adb uninstall com.example.verygoodcore.activity_monitoring.dev
flutter run
```

## 🏗️ Project Structure
```
📂 activity_monitoring
│── lib/
│   ├── main.dart                 # Entry point of the app
│   ├── service/
│   │   ├── background_service.dart  # Handles background tracking
│   │   ├── database_service.dart    # SQLite database interactions
│   │   ├── usage_service.dart       # Fetches app usage stats
│   ├── view/
│   │   ├── activity_monitoring.dart # Main UI for querying AI
│   │   ├── query_screen.dart        # UI for querying AI assistant
│── android/
│── ios/
│── pubspec.yaml                   # Dependencies
│── README.md                       # Project documentation
```

## 🔥 API Integration
The AI assistant communicates with an API for analysis. The request format is:
```json
{
  "model": "llama3.2:latest",
  "messages": [
    {"role": "system", "content": "You are an AI assistant that analyzes app usage history."},
    {"role": "user", "content": "Activity Log: {app_usage_data}. Question: {user_query}"}
  ]
}
```
Ensure your API endpoint is configured properly:
```dart
final response = await http.post(
  Uri.parse('http://192.168.0.119:11434/v1/chat/completions'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode(requestBody),
);
```

## 🤝 Contributing
1. Fork the repository.
2. Create a new branch (`feature-branch-name`).
3. Make your changes and test thoroughly.
4. Submit a pull request.

## 📝 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📩 Contact
For questions or support, reach out to **your.email@example.com** or open an issue in the repository.

---
🎯 Built with ❤️ using Flutter.