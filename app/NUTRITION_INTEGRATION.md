# Nutrition API Integration

## Overview

Successfully integrated the Nutrition Tracker API into the Flutter Food Finder app. **Both Recipe and Nutrition features connect to the same unified backend server**.

The app now provides:
1. **Recipe Management** - YouTube recipe extraction and storage
2. **Nutrition Tracking** - Food lookup, meal logging, and recipe suggestions

---

## What Was Added

### 1. Data Models (`lib/data/models/nutrition.dart`)
- `NutritionData` - Calories, protein, carbs, fat
- `NutritionBoard` - User's cumulative nutrition totals
- `MealLog` - Logged meal with timestamp and nutrition info

### 2. API Configuration (`lib/core/config/nutrition_api_config.dart`)
- **Base URL**: `https://e0ae2d8b1eca.ngrok-free.app` (Same as Recipe API)
- Endpoints (all use `/api/` prefix):
  - `/api/health` - Health check
  - `/api/nutrition` - Get food nutrition
  - `/api/nutrition/board` - Get user totals
  - `/api/nutrition/lock` - Log a meal
  - `/api/recipes/suggest` - Get recipe suggestions
  - `/api/ocr/grocery-bill` - Scan grocery bills

### 3. API Service (`lib/data/services/nutrition_api_service.dart`)
Complete service layer with error handling for all nutrition endpoints.

### 4. Repository (`lib/data/repositories/nutrition_repository.dart`)
Data access layer abstracting API calls.

### 5. Providers (`lib/providers/providers.dart`)
New Riverpod providers:
- `nutritionApiServiceProvider` - API service instance
- `nutritionRepositoryProvider` - Repository instance
- `userIdProvider` - Current user ID (default: "user123")
- `nutritionBoardProvider` - User's nutrition totals

### 6. New Screens

#### `NutritionScreen` (`lib/presentation/screens/nutrition/nutrition_screen.dart`)
- Dashboard showing daily nutrition totals
- Quick actions:
  - 🔍 Lookup Food
  - ✍️ Log Meal
  - 🍳 Recipe Ideas
  - 📸 Scan Bill

#### `FoodLookupScreen` (`lib/presentation/screens/nutrition/food_lookup_screen.dart`)
- Search nutrition info for any food
- Input food name and amount
- Display calories, protein, carbs, fat

### 7. Updated Navigation

**New Bottom Navigation Bar:**
```
┌──────────┬────────────┬──────────┐
│ Recipes  │ Nutrition  │   Add    │
└──────────┴────────────┴──────────┘
```

- **Tab 1 (Recipes)**: Browse and search YouTube recipes
- **Tab 2 (Nutrition)**: Nutrition tracking dashboard
- **Tab 3 (Add)**: Add new recipes from YouTube

---

## API Endpoints Integrated

### ✅ Implemented
1. **GET /health** - Health check
2. **POST /nutrition** - Get nutrition for food ✅
3. **POST /nutrition/board** - Get user totals ✅
4. **POST /nutrition/lock** - Log a meal ✅
5. **POST /recipes/suggest** - Get recipe suggestions ✅
6. **POST /ocr/grocery-bill** - Scan grocery bill ✅

### 🚧 Screens Pending
- Meal Logger Screen (placeholder added)
- Recipe Suggestions Screen (placeholder added)
- Grocery Bill Scanner Screen (placeholder added)

All API methods are implemented and ready to use - just need UI screens.

---

## Configuration

### ✅ Already Configured!
Both Recipe and Nutrition APIs point to the same server:
```
https://e0ae2d8b1eca.ngrok-free.app
```

No configuration changes needed - the app is ready to use!

### For Local Development
If you want to run the backend locally, update both config files:

**File 1**: `lib/core/config/api_config.dart`
**File 2**: `lib/core/config/nutrition_api_config.dart`

Change `defaultValue` to:
- **Android Emulator**: `http://10.0.2.2:8000`
- **iOS Simulator**: `http://localhost:8000`
- **Physical Device**: `http://YOUR_COMPUTER_IP:8000`

### For Different Production URL
Use environment variable:
```bash
flutter run --dart-define=API_BASE_URL=https://your-domain.com
```

---

## Usage Example

### Get Nutrition for a Food
```dart
final repository = ref.read(nutritionRepositoryProvider);
final nutrition = await repository.getNutrition(
  userId: 'user123',
  food: 'banana',
  amount: 1,
);
// Returns: calories, protein, carbs, fat
```

### Get User's Daily Totals
```dart
final board = await repository.getNutritionBoard('user123');
print('Total calories: ${board.calories}');
```

### Log a Meal
```dart
final mealLog = await repository.logMeal(
  userId: 'user123',
  dish: 'Grilled Chicken',
  nutrition: NutritionData(
    calories: 400,
    protein: 40,
    carbs: 0,
    fat: 22,
  ),
);
```

---

## Project Structure

```
lib/
├── core/
│   └── config/
│       ├── api_config.dart              # Recipe endpoints
│       └── nutrition_api_config.dart    # Nutrition endpoints ✨
├── data/
│   ├── models/
│   │   ├── recipe.dart
│   │   ├── ingredient.dart
│   │   └── nutrition.dart               # New ✨
│   ├── services/
│   │   ├── api_service.dart
│   │   └── nutrition_api_service.dart   # New ✨
│   └── repositories/
│       ├── recipe_repository.dart
│       └── nutrition_repository.dart    # New ✨
├── presentation/
│   ├── screens/
│   │   ├── home/
│   │   ├── add_recipe/
│   │   ├── recipe_detail/
│   │   ├── shopping_list/
│   │   └── nutrition/                   # New ✨
│   │       ├── nutrition_screen.dart
│   │       └── food_lookup_screen.dart
│   └── navigation/
│       ├── app_router.dart              # Updated ✨
│       └── main_navigation.dart         # Updated ✨
└── providers/providers.dart             # Updated ✨
```

---

## Testing

### 1. Ensure Backend is Running
The backend should already be running at:
```
https://e0ae2d8b1eca.ngrok-free.app
```

Or if running locally:
```bash
cd backend
python -m uvicorn main:app --port 8000 --reload
```

### 2. Run Flutter App
```bash
cd food_finder_app
flutter run
```

### 3. Test Features
1. **Recipes Tab**: Search/browse YouTube recipes
2. **Nutrition Tab**: View daily totals, lookup food nutrition
3. **Add Tab**: Extract recipes from YouTube URLs

---

## Next Steps (Optional)

### Complete Missing Screens
1. **Meal Logger Screen** - Manual meal entry with nutrition input
2. **Recipe Suggestions** - AI-powered suggestions from ingredients list
3. **Grocery Scanner** - OCR bill scanning with camera integration

### Add User Authentication
- Replace hardcoded `user123` with real auth
- Implement user login/signup
- Store userId in secure storage

### Enhanced Features
- Nutrition goals and progress tracking
- Daily/weekly nutrition charts
- Meal history and analytics
- Favorite foods quick-add

---

## Troubleshooting

### "Connection Refused" Error
- **Cause**: Backend server not accessible
- **Fix**: Verify ngrok tunnel is active at `https://e0ae2d8b1eca.ngrok-free.app`
- **Local Dev**: Ensure backend is running on port 8000

### Wrong API URL for Device Type
- **Production**: Use `https://e0ae2d8b1eca.ngrok-free.app` (already configured)
- **Local Emulator**: Use `http://10.0.2.2:8000`
- **Local Physical Device**: Use `http://YOUR_COMPUTER_IP:8000`
- **Local iOS Simulator**: Use `http://localhost:8000`

### "No nutrition data" on Dashboard
- **Cause**: No meals logged yet for user
- **Fix**: Log a meal using food lookup or meal logger

---

## Summary

✅ **Fully Integrated:**
- Nutrition API client layer
- Data models for nutrition tracking
- Nutrition dashboard screen
- Food lookup functionality
- Bottom navigation with 3 tabs
- Error handling and loading states

✅ **Ready to Use:**
- All API endpoints are wired up
- Just add UI screens for remaining features

✅ **Production Ready:**
- Environment variable support
- Proper error handling
- Loading dialogs
- Beautiful neobrutalism UI

The app now seamlessly combines recipe management with nutrition tracking! 🎉
