# 📱 Fund Browser

> A premium Flutter application for browsing, searching, and analysing Indian Mutual Fund schemes — powered by [mfapi.in](https://www.mfapi.in), built with MVVM architecture, and ready for production.

---

## 📋 Table of Contents

1. [Project Overview](#-project-overview)
2. [Features](#-features)
3. [App Screens](#-app-screens)
4. [Architecture](#-architecture)
5. [Tech Stack & Dependencies](#-tech-stack--dependencies)
6. [Project Structure](#-project-structure)
7. [Prerequisites](#-prerequisites)
8. [Setup & Installation](#-setup--installation)
9. [Running the Application](#-running-the-application)
10. [API Reference](#-api-reference)
11. [Offline Mode](#-offline-mode)
12. [Session Timeout](#-session-timeout)
13. [App Icon & Branding](#-app-icon--branding)
14. [Theming](#-theming)
15. [Known Limitations](#-known-limitations)
16. [Troubleshooting](#-troubleshooting)

---

## 🌟 Project Overview

**Fund Browser** is a Flutter-based mobile application that lets users explore the entire catalogue of Indian mutual fund schemes registered with AMFI (Association of Mutual Funds in India). The app connects to the free, public [mfapi.in](https://www.mfapi.in) REST API which mirrors AMFI data.

Key highlights:
- 📊 Browse **37,000+ mutual fund schemes** across Equity, Debt, Hybrid, and Other categories
- 🔍 Real-time search by **scheme name or scheme code**
- 📈 Detailed per-scheme view with **30-day NAV history**
- 🔒 Session-based authentication with **5-minute idle timeout**
- 📶 Full **offline fallback** — never shows a blank screen when the network is unavailable
- 🌙 **Dark/Light mode** that follows the device system preference
- 🌤️ **IST-aware dynamic greetings** (Good morning / afternoon / evening / night)

---

## ✨ Features

| Feature | Details |
|---------|---------|
| **Login** | Email + password validation, error clearing on re-type, no registration required |
| **Session Persistence** | Auth token + user email stored via `shared_preferences`; auto-login on restart |
| **Session Timeout** | Automatically logs out after 5 minutes of user inactivity with a branded notification |
| **Scheme List** | Scrollable list of all AMFI-registered schemes with mock NAV and 1-day change |
| **Category Filter** | Horizontal pill chips: All, Equity, Debt, Hybrid, Others |
| **Live Search** | Instant search by scheme name and scheme code |
| **Scheme Detail** | Fund house, scheme type, 30-day NAV history table, invest bottom sheet |
| **Invest Sheet** | Amount validation (min Rs.100), confirm/cancel, success dialog |
| **Dynamic Avatar** | Profile avatar in header shows initials derived from the logged-in email |
| **IST Greeting** | Header greeting changes dynamically based on India Standard Time |
| **Offline Mode** | Falls back to 27-scheme curated cache on network failure; amber banner shown |
| **Dark / Light Theme** | Full system-adaptive theming via `ThemeMode.system` |
| **Custom App Icon** | Fintech-themed icon (chart + magnifying glass) at all mipmap densities |

---

## 📱 App Screens

### Screen 1 — Login
- Gradient header with app logo and tagline
- Email and password fields with real-time validation
- Error labels auto-disappear as the user corrects input
- "256-bit encrypted" footer for trust signalling
- No registration option (demo app with any valid-format credentials)

### Screen 2 — Scheme List
- IST-based greeting and dynamic user avatar (initials from email)
- Search bar embedded in the gradient header
- Category filter chips (All / Equity / Debt / Hybrid / Others)
- Scheme cards showing: name, scheme code, mock NAV, 1-day change %, category badge
- Offline amber banner if the network call failed
- Tap any card to navigate to Screen 3

### Screen 3 — Scheme Detail
- Gradient header with scheme name, NAV, 1-day change, and scheme code
- 30-day NAV history table (date, NAV, change)
- "Invest Now" sticky bottom button
- Investment bottom sheet with amount input and confirmation
- Success dialog on confirmed investment
- Offline banner if the details endpoint was unreachable

---

## 🏗️ Architecture

The app uses **MVVM (Model-View-ViewModel)** with **Provider** for state management.

```
+----------------------------------------------------------+
|                        UI Layer                          |
|  LoginScreen  ->  SchemeListScreen  ->  SchemeDetailScreen|
+---------------------------+------------------------------+
                            | watch / read
+---------------------------v------------------------------+
|                    ViewModel Layer                       |
|  LoginViewModel  | SchemeListViewModel | SchemeDetailVM  |
+---------------------------+------------------------------+
                            | calls
+---------------------------v------------------------------+
|                    Service Layer                         |
|  ApiService  | SecureStorageService  |  SessionManager   |
+----------------------------------------------------------+
```

### Data Flow
1. **View** reads state from ViewModel via `context.watch<VM>()`
2. **View** triggers actions via `context.read<VM>().method()`
3. **ViewModel** calls `ApiService` / `SecureStorageService` and calls `notifyListeners()`
4. **Provider** propagates changes back to the View tree

---

## 🛠️ Tech Stack & Dependencies

### Runtime Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter` | SDK | UI framework |
| `provider` | ^6.1.5 | State management (MVVM) |
| `http` | ^1.6.0 | HTTP client for REST API calls |
| `shared_preferences` | ^2.3.4 | Persisting auth token and user email |

### Dev Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_lints` | ^6.0.0 | Lint rules for code quality |
| `flutter_launcher_icons` | ^0.14.3 | Auto-generates app icons at all densities |

### External API

| API | Base URL | Notes |
|-----|----------|-------|
| mfapi.in | `https://api.mfapi.in` | Free, public, unauthenticated AMFI mirror |

---

## 📂 Project Structure

```
first_app/
├── android/
│   └── app/src/main/
│       ├── AndroidManifest.xml         # App label: "Fund Browser"
│       └── res/
│           ├── mipmap-hdpi/            # App icon (auto-generated)
│           ├── mipmap-mdpi/
│           ├── mipmap-xhdpi/
│           ├── mipmap-xxhdpi/
│           └── mipmap-xxxhdpi/
├── assets/
│   └── icons/
│       └── app_icon.jpg               # Source icon for flutter_launcher_icons
├── lib/
│   ├── main.dart                      # App entry point, Provider setup
│   ├── models/
│   │   ├── scheme_model.dart          # Scheme list item model
│   │   └── scheme_detail_model.dart   # Scheme detail + NAV history model
│   ├── screens/
│   │   ├── login_screen.dart          # Screen 1: Login
│   │   ├── scheme_list_screen.dart    # Screen 2: Fund browser list
│   │   └── scheme_detail_screen.dart  # Screen 3: Fund detail + invest
│   ├── viewmodels/
│   │   ├── login_view_model.dart      # Auth logic, email persistence, initials
│   │   ├── scheme_list_view_model.dart # Fund list, search, filter, offline
│   │   └── scheme_detail_view_model.dart # Fund detail fetch, offline fallback
│   ├── services/
│   │   ├── api_service.dart           # REST calls + offline cache data
│   │   ├── secure_storage_service.dart # SharedPreferences wrapper (token + email)
│   │   └── session_manager.dart       # Idle timeout logic + SessionTimeoutWrapper
│   ├── theme/
│   │   └── app_theme.dart             # Light/Dark ThemeData, colour tokens
│   └── widgets/
│       ├── gradient_header.dart       # Reusable gradient header card
│       ├── custom_text_field.dart     # Styled TextFormField wrapper
│       ├── primary_button.dart        # Loading-aware elevated button
│       └── encryption_footer.dart    # "256-bit encrypted" footer widget
├── pubspec.yaml                       # Dependencies + launcher icons config
└── README.md                          # This file
```

---

## ✅ Prerequisites

Before you begin, ensure the following are installed and configured:

| Requirement | Version | Check Command |
|-------------|---------|---------------|
| Flutter SDK | >= 3.12.2 | `flutter --version` |
| Dart SDK | >= 3.12.2 | `dart --version` |
| Android Studio | >= Giraffe (2022.3) | Android Studio > Help > About |
| Android SDK | API 21+ (Android 5.0) | Android Studio SDK Manager |
| Java (JDK) | 17 (LTS) | `java -version` |
| Git | Any recent | `git --version` |

> **Windows users**: Make sure `C:\flutter\bin` is on your system `PATH`.
> Run `flutter doctor` to diagnose your setup automatically.

---

## 🚀 Setup & Installation

### Step 1 — Clone the repository

```bash
git clone https://github.com/your-username/fund-browser.git
cd fund-browser
```

> If you received this project as a zip, extract it and open the folder in Android Studio.

### Step 2 — Verify Flutter environment

```bash
flutter doctor -v
```

Resolve any issues flagged by `flutter doctor` before proceeding. At minimum you need:
- Flutter SDK
- Android toolchain
- Connected device or emulator

### Step 3 — Install dependencies

```bash
flutter pub get
```

This fetches all packages listed in `pubspec.yaml`, including `provider`, `http`, `shared_preferences`, and `flutter_launcher_icons`.

### Step 4 — Generate app icons (optional — already done)

The app icons are **pre-generated** in `android/app/src/main/res/`. If you change `assets/icons/app_icon.jpg`, regenerate them:

```bash
dart run flutter_launcher_icons
```

### Step 5 — Open in Android Studio (optional)

```
File > Open > select the project root folder
```

Android Studio will automatically detect the Flutter project.

---

## ▶️ Running the Application

### On an Android Emulator

1. Open Android Studio > **Device Manager** > create or start an AVD (e.g. Pixel 6, API 33)
2. Wait for the emulator to fully boot to the home screen
3. In the project terminal:
   ```bash
   flutter run
   ```
4. Or press the **Run** button in Android Studio with the emulator selected

### On a Physical Android Device

1. Enable **Developer Options** > **USB Debugging** on your device
2. Connect via USB
3. Verify detection: `flutter devices`
4. Run:
   ```bash
   flutter run
   ```

### Run with a specific device

```bash
flutter devices              # list available devices
flutter run -d <device-id>  # run on specific device
```

### Hot Reload vs Hot Restart

| Command | In Terminal | When to use |
|---------|-------------|-------------|
| Hot Reload | Press `r` | UI tweaks, widget changes |
| Hot Restart | Press `R` | State changes, ViewModel changes |
| Full restart | Stop + Run again | Native changes (Manifest, pubspec) |

---

## 🌐 API Reference

The app uses the free **mfapi.in** API — no authentication required.

### Endpoint 1 — List All Schemes

```
GET https://api.mfapi.in/mf
```

- **Response**: JSON array of 37,647 scheme objects
- **Payload size**: ~5.4 MB
- **Timeout**: 90 seconds (configured in `ApiService`)
- **Sample response**:
  ```json
  [
    {
      "schemeCode": 119598,
      "schemeName": "SBI Bluechip Fund - Direct Plan - Growth",
      "isinGrowth": "INF200K01UT1",
      "isinDivReinvestment": "INF200K01UU9"
    }
  ]
  ```

### Endpoint 2 — Scheme Detail + NAV History

```
GET https://api.mfapi.in/mf/{schemeCode}
```

- **Response**: Metadata + 30-day NAV history
- **Timeout**: 15 seconds
- **Sample response**:
  ```json
  {
    "meta": {
      "fund_house": "SBI Funds Management Limited",
      "scheme_type": "Open Ended Schemes",
      "scheme_category": "Equity Scheme - Large Cap Fund",
      "scheme_code": 119598,
      "scheme_name": "SBI Bluechip Fund - Direct Plan - Growth"
    },
    "data": [
      { "date": "03-07-2026", "nav": "89.2341" }
    ]
  }
  ```

> **Note**: The detail endpoint is currently returning 502 Bad Gateway from the server. The app automatically falls back to generated mock NAV history when this occurs.

---

## 📶 Offline Mode

Fund Browser never leaves the user staring at an error screen. When either API call fails (network timeout, no internet, server error):

### Scheme List — Offline Fallback
- Loads **27 pre-curated popular Indian mutual fund schemes** from an in-memory cache inside `ApiService`
- Covers all four categories: Equity (SBI Bluechip, HDFC Mid-Cap, Parag Parikh, etc.), Debt, Hybrid, and Others
- An **amber warning banner** appears below the category chips

### Scheme Detail — Offline Fallback
- Generates **deterministic mock 30-day NAV history** using the scheme code as a seed
- NAV values are stable across restarts (same scheme always gets the same mock values)
- An **amber warning banner** appears above the NAV table

### Testing Offline Mode
1. Turn off Wi-Fi and mobile data on the emulator (Extended Controls > Cellular)
2. Launch the app or navigate to Scheme List
3. The offline banner will appear within 90 seconds (or immediately if already timed out)

---

## 🔒 Session Timeout

The app implements an **idle session timeout** of 5 minutes to protect user data.

### How it works
- `SessionTimeoutWrapper` (in `lib/services/session_manager.dart`) wraps the Scheme List screen
- A `Listener` widget captures every touch event and resets a `dart:async Timer`
- The timer also resets when the app is brought back to the foreground
- After exactly 5 minutes with no touch events:
  1. A branded blue SnackBar appears: _"Session expired due to inactivity."_
  2. The login token and email are cleared from storage
  3. The navigation stack is fully replaced with `LoginScreen`

### Configuring the timeout duration

In `scheme_list_screen.dart`:

```dart
SessionTimeoutWrapper(
  timeoutDuration: const Duration(minutes: 5), // change this value
  ...
)
```

---

## 🎨 App Icon & Branding

### Icon Design
- **Background**: Deep navy blue (#0B0F19) rounded square
- **Foreground**: Rising bar chart integrated into a magnifying glass lens
- **Colour palette**: Gradient blue (#1565C0 to #42A5F5)
- **Style**: Flat, premium fintech aesthetic

### Regenerating Icons

```bash
dart run flutter_launcher_icons
```

### App Display Name
The installed app name is set in `android/app/src/main/AndroidManifest.xml`:
```xml
<application android:label="Fund Browser" ...>
```

---

## 🌗 Theming

| Colour Token | Light Mode | Dark Mode |
|-------------|-----------|-----------|
| Primary Blue | #1565C0 | #42A5F5 |
| Background | #FFFFFF | #0B0F19 |
| Header Gradient Start | #1565C0 | #0D1B3E |
| Header Gradient End | #1E88E5 | #1565C0 |
| Card Background | #F8F9FF | #111827 |
| Surface | #FFFFFF | #0F172A |

Theme mode automatically follows the device system setting. No manual toggle required.

---

## ⚠️ Known Limitations

| Limitation | Details |
|------------|---------|
| Authentication | Demo only — any valid-format email + 8-char password works |
| No real investment | The "Invest Now" flow is a UI simulation only |
| NAV data on list | NAV values are deterministically generated mocks, not live |
| Detail API | GET /mf/{code} returns 502; app uses generated NAV history |
| Large payload | Full 37K scheme list loaded in one 90-second request |
| iOS | Not configured — Android only in current state |

---

## 🔧 Troubleshooting

### `flutter doctor` shows missing Android SDK
```
Open Android Studio > SDK Manager > install Android SDK Platform 33+ and Build Tools
```

### Emulator not detected
```bash
flutter devices    # lists all detected devices
adb devices        # verify ADB sees the emulator
```

### `flutter pub get` fails with network error
Ensure your internet connection is active. Behind a corporate proxy:
```bash
set HTTPS_PROXY=http://your.proxy:port
flutter pub get
```

### App shows blank screen on launch
The emulator may still be booting. Wait for the home screen, then run again.

### Build fails: Gradle sync failed
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### App icon not updated after regeneration
Uninstall the app from the emulator and re-run. Android caches old icons until reinstalled.

### Session timeout triggers during development
The 5-minute timer runs even during development. Either hot-restart, or temporarily increase the duration in `scheme_list_screen.dart` while debugging.

---


---

## 🔑 Demo Login Credentials

No real authentication is implemented. Any credentials matching the format below will work:

| Field | Value |
|-------|-------|
| Email | Any valid email format e.g. 	est@example.com |
| Password | Any password of 8 or more characters e.g. password123 |

A dummy token is generated and stored locally on successful login. No server call is made for authentication.

---

## 📝 Assumptions Made

1. **Authentication**: Login accepts any valid-format email + 8-char password. No real backend exists — a hardcoded dummy token is stored locally via shared_preferences.
2. **NAV data on list screen**: The AMFI API (GET /mf) only returns scheme name and code — not live NAV. Mock NAV values are deterministically generated from the scheme code so they are stable across sessions.
3. **Detail API (502 error)**: GET /mf/{schemeCode} is currently returning 502 Bad Gateway from the mfapi.in server. The app handles this gracefully by generating mock 30-day NAV history locally.
4. **Offline fallback**: When the internet is unavailable, a curated list of 27 popular Indian mutual fund schemes is shown instead of a blank or error screen.
5. **iOS**: The app is configured and tested for Android only. iOS support would require additional runner configuration.
6. **Session security**: shared_preferences is used instead of lutter_secure_storage to ensure compatibility across Android API levels without native build issues.

## 📄 License

This project is for educational and demonstration purposes.
Mutual fund data is sourced from [mfapi.in](https://www.mfapi.in) which mirrors public AMFI data.

---

*Built with Flutter — India's mutual funds, in your pocket.*

