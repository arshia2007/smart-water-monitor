# 💧 Smart Water Monitor – Mobile Application

A cross-platform Flutter application for real-time household water consumption monitoring. The app connects with Firebase to display live water usage, historical logs, analytics, and billing information, helping users track and manage their water consumption efficiently.

---

## Features

 📊 **Dashboard** with water usage overview
📡 **Real-time monitoring** using Firebase Realtime Database
📈 **Usage analytics** with interactive charts
🧾 **Water usage reports** and history
💳 **Billing section** for consumption tracking
👤 **User profile** and account interface
📱 Built with **Flutter** for Android (cross-platform ready)

---

## Tech Stack

| Technology                 | Purpose                      |
| -------------------------- | ---------------------------- |
| Flutter                    | Mobile application framework |
| Dart                       | Programming language         |
| Firebase Realtime Database | Live sensor data storage     |
| FL Chart                   | Data visualization           |
| Material Design            | User interface               |

---

## Project Structure

```text
mobile-app/
├── lib/
│   ├── mobile/
│   ├── screens/
│   ├── widgets/
│   └── main.dart
├── assets/
├── android/
├── ios/
├── web/
├── test/
├── pubspec.yaml
└── README.md
```

---

## Getting Started

### Prerequisites

* Flutter SDK
* Dart SDK
* Android Studio or VS Code
* Firebase project configured

### Installation

```bash
git clone https://github.com/arshia2007/smart-water-monitor.git
cd smart-water-monitor/mobile-app

flutter pub get
flutter run
```

---

## Firebase Configuration

1. Create a Firebase project.
2. Enable **Realtime Database**.
3. Add the Android application to Firebase.
4. Place the Firebase configuration files in the project.
5. Update the database rules and connection if required.

---

## Application Modules

* **Dashboard** – Displays overall water usage summary.
* **Real-time** – Shows live data received from IoT sensors.
* **Water Report** – Historical consumption logs and trends.
* **Bills** – Water usage billing and cost overview.
* **Profile** – User account and application settings.

---

## Future Improvements

* Push notifications for high water usage
* Leak detection alerts
* Monthly consumption predictions
* Export reports as PDF
* Multi-user household support

---

## Contributors

* **Arshia** — Firmware & IoT integration
* **Aishwarya Batra** — Flutter mobile application, Firebase integration, UI, analytics, and testing

---

## License

This project is developed for educational and academic purposes.
