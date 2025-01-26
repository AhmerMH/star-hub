# StarHub - IPTV Streaming Platform

A Flutter-based IPTV streaming application that provides live TV, movies, and series streaming capabilities.

## Features

- Live TV streaming with EPG (Electronic Program Guide)
- Movies library with categories
- TV Series with episodes
- Search functionality across all content
- Responsive design for multiple screen sizes

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code
- [Backend Server Setup](https://github.com/AhmerMH/starhub-BE)

### Backend Server Setup

The application requires a backend server running on `http://localhost:3000` for user management and server URL configuration.

1. Clone the backend repository
2. Install dependencies
3. Configure environment variables
4. Start the server on port 3000

The backend API endpoint structure:


### Installation

1. Clone this repository
```bash
git clone https://github.com/yourusername/starhub.git
```

2. Install dependencies
```
flutter pub get
```

3. Run the app
```
flutter run
```

## Configuration
Default IPTV server URL: http://webhop.xyz:8080
Backend server URL: http://localhost:3000


## Building for Production
Generate release builds for different platforms:
```
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release

```