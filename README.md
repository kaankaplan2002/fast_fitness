# ⚡ FastFitness - Gemini AI Powered Workout & Fitness Tracker

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Riverpod](https://img.shields.io/badge/Riverpod-3.0-FF4081?style=for-the-badge&logo=dart&logoColor=white)](https://riverpod.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Gemini](https://img.shields.io/badge/Gemini%20AI-8E44AD?style=for-the-badge&logo=google-gemini&logoColor=white)](https://deepmind.google/technologies/gemini/)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

**FastFitness** is a premium, modern, and state-of-the-art Flutter mobile application designed to help users structure their fitness routine, track progress dynamically, and generate customized workout programs utilizing the power of **Google Gemini AI**.

---

## 🌟 Key Features

### 🧠 1. Gemini AI Workout Generation
- Enter your training focus (Chest, Back, Legs, Core), target duration, and target calories.
- Integrates with the **Gemini-Flash-Latest** model via REST API utilizing secure, masked local configuration.
- Outputs structured workout routines in JSON format containing sets, reps, rest periods, and custom coaching notes.
- *Offline Fallback:* Features a smart offline backup database that generates routines dynamically if no internet connection or API Key is present.

### 📊 2. Dynamic Fitness Tracking & Analytics
- **Weight History Tracking:** Add body weight metrics and visualize progress on interactive charts.
- **Monthly Heatmap:** Grid visualization tracking active training days, streaks, and consistency scores.
- **Activity Summary Card:** Dynamic level & level-up progression tracking based on calculated XP gains.

### 📚 3. Extensive Exercise Library (With Visuals)
- **28 Professional Exercises** preloaded out-of-the-box (7 exercises per focus category: Chest, Back, Legs, Core).
- Step-by-step training instructions with correct rest periods and difficulty tiers.
- Integrated **High-Quality Cover Photos** representing visual explanations for each exercise.
- **Auto-Seeding Database:** Automatically populates/restores standard exercises on startup if the database is missing records.

### 🎨 4. Premium Design & Micro-Interactions
- Adaptive dark/light theme options responding dynamically to system/user preferences.
- Snappy, lag-free Onboarding animations utilizing custom `Curves.easeOutCubic` transitions.
- Integrated haptic feedback profiles (light, medium, success, warning, error) for premium tactile interactions.

---

## 🛠️ Tech Stack & Libraries

- **Framework:** Flutter SDK (Material 3 Design System)
- **State Management:** Riverpod 3.x (Clean, modular logic)
- **Routing:** GoRouter (Smooth slide-and-fade page transitions)
- **Database & Auth:** Google Firebase Auth & Cloud Firestore
- **Networking:** HTTP Client with JSON Parsing
- **Local Persistence:** SharedPreferences (Secure locally-stored API key config)

---

## 📂 Folder Structure

The project follows a clean **feature-first** modular folder layout:

```text
lib/
├── app/                  # Theme configuration, style tokens, and GoRouter setup
├── core/                 # Shared widgets, dialog sheets, and general services (haptic, snackbar)
└── features/             # Feature-specific modules:
    ├── ai/               # AI coaching logic and recommendations
    ├── ai_program/       # Gemini AI workout generation client & screens
    ├── auth/             # Authentication screens (Login, Register, SplashScreen, Onboarding)
    ├── exercises/        # Exercises list, details, and search engine
    ├── home/             # Main dashboard view, progress rings, and recent activities
    ├── profile/          # Settings configuration, private profile setups, and API key management
    └── progress/         # Analytics graphs, weight charts, and monthly heatmaps
```

---

## 🚀 Getting Started

Follow these steps to get a local copy up and running:

### Prerequisites
- Flutter SDK (latest stable channel)
- Xcode (for iOS builds) / Android Studio (for Android builds)

### Installation

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/kaankaplan2002/fast_fitness.git
   cd fast_fitness
   ```

2. **Fetch Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**
   Ensure you have a Firebase project set up. Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) in the respective app directories, or run `flutterfire configure`.

4. **Run the Application:**
   ```bash
   flutter run
   ```

### ⚡ Configuring Gemini AI
1. Go to [Google AI Studio](https://aistudio.google.com/) and create a free API Key.
2. In the FastFitness app, navigate to **Profile -> Settings -> AI Coaching**.
3. Tap **Gemini API Key**, paste your key, and click **Save**.
4. Generate a workout under the **Workout** tab to experience real-time AI coaching!

---

## 📜 License

Distributed under the MIT License. See `LICENSE` for more information.
