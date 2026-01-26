# Food Finder App 🍕

A neobrutalism-styled food recipe finder Flutter app that extracts recipes from YouTube cooking videos using AI.

## Features

- 🎨 Bold neobrutalism UI design with vibrant colors
- 📺 Extract recipes from YouTube cooking videos
- 🔍 Search and browse recipes
- 📝 Detailed recipe instructions with ingredients and steps
- 🛒 Generate shopping lists by category
- 📱 Clean, intuitive navigation

## Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Backend API running on port 8000 (see API Configuration below)

## Getting Started

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Configure Backend API

The app connects to a backend API on `http://localhost:8000` by default.

To change the API URL:

Edit `lib/core/config/api_config.dart`:

```dart
static const String baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8000', // Change this
);
```

**For Android Emulator:** Use `http://10.0.2.2:8000`
**For Physical Device:** Use `http://YOUR_COMPUTER_IP:8000`
**For iOS Simulator:** Use `http://localhost:8000` or your computer's IP

Alternatively, run with environment variable:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

### 3. Run the App

```bash
flutter run
```

For specific devices:

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run on Chrome
flutter run -d chrome

# Run on Android
flutter run -d android

# Run on iOS
flutter run -d ios
```

## Project Structure

```
lib/
├── core/
│   ├── config/         # API configuration
│   ├── constants/      # Colors, text styles, spacing
│   └── utils/          # Validators, formatters
├── data/
│   ├── models/         # Recipe, Ingredient, ShoppingList models
│   ├── repositories/   # Data repository layer
│   └── services/       # API service
├── presentation/
│   ├── navigation/     # App router & navigation
│   ├── screens/        # All app screens
│   │   ├── home/
│   │   ├── add_recipe/
│   │   ├── recipe_detail/
│   │   └── shopping_list/
│   └── widgets/        # Reusable UI components
├── providers/          # Riverpod state management
└── main.dart          # App entry point
```

## Key Technologies

- **Flutter & Dart** - Cross-platform app framework
- **Riverpod** - State management
- **Go Router** - Navigation
- **Dio** - HTTP client for API calls
- **Neubrutalism UI** - UI component library
- **Google Fonts** - Typography (Space Grotesk)

## API Endpoints Expected

The app expects the following backend endpoints:

- `GET /api/recipes` - List all recipes
- `POST /api/recipes/extract` - Extract recipe from YouTube URL
- `GET /api/recipes/{id}` - Get recipe by ID
- `DELETE /api/recipes/{id}` - Delete recipe
- `POST /api/recipes/{id}/shopping-list` - Generate shopping list

## Screens

1. **Home Screen** - Browse and search recipes
2. **Add Recipe Screen** - Extract recipes from YouTube URLs
3. **Recipe Detail Screen** - View full recipe with ingredients and steps
4. **Shopping List Screen** - Organized shopping list by category

## Development

### Format Code

```bash
flutter format lib/
```

### Analyze Code

```bash
flutter analyze
```

### Run Tests

```bash
flutter test
```

## Build for Production

### Android

```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

### Web

```bash
flutter build web --release
```

## Troubleshooting

### API Connection Issues

1. **Check backend is running**: Ensure your backend API is running on port 8000
2. **Android Emulator**: Use `http://10.0.2.2:8000` instead of `localhost`
3. **Physical Device**: Make sure device and computer are on same network
4. **iOS Permissions**: Check App Transport Security settings in Info.plist

### Common Issues

- **Dependencies not installing**: Run `flutter clean` then `flutter pub get`
- **Build failures**: Update Flutter SDK with `flutter upgrade`
- **Hot reload not working**: Try hot restart (Shift+R in terminal)

## License

This project was created following the specifications in `flutter.md`.
