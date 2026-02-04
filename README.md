# NewsX

A modern, feature-rich news application built with Flutter that displays top headlines and allows users to search for news articles. The app implements Clean Architecture principles with offline-first capabilities and a premium Material Design 3 interface.

---

## 📋 Table of Contents
- [Features](#features)
- [Setup Instructions](#setup-instructions)
- [Architecture Overview](#architecture-overview)
- [Key Decisions and Trade-offs](#key-decisions-and-trade-offs)
- [Known Limitations](#known-limitations)
- [Contributing](#contributing)
- [License](#license)

---

## ✨ Features

- **Top Headlines**: Browse the latest news from various sources
- **Search Functionality**: Search for specific news topics and articles
- **Offline Support**: View previously cached articles when offline
- **Material Design 3**: Modern, premium UI with dynamic color schemes
- **Material Expressive Design**: Custom typography, micro-animations, and glassmorphism effects
- **Multi-platform**: Runs on iOS, Android, Web, macOS, Linux, and Window
- **Cached Images**: Fast image loading with caching support
- **Dark Mode**: Automatic theme switching based on system preferences

---

## 🚀 Setup Instructions

### Prerequisites

- **Flutter SDK**: 3.4.1 or higher
- **Dart SDK**: Included with Flutter
- **News API Key**: Get one from [newsapi.org](https://newsapi.org/)

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd newsx
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code for Freezed models**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Configure API Key**
   
   The app uses `--dart-define` for secure API key injection. Never hardcode your API key.

5. **Run the application**
   ```bash
   # For development
   flutter run --dart-define=NEWS_API_KEY=your_actual_api_key_here

   # For specific platforms
   flutter run -d chrome --dart-define=NEWS_API_KEY=your_key
   flutter run -d macos --dart-define=NEWS_API_KEY=your_key
   flutter run -d android --dart-define=NEWS_API_KEY=your_key
   ```

6. **Build for production**
   ```bash
   # Android
   flutter build apk --dart-define=NEWS_API_KEY=your_key

   # iOS
   flutter build ios --dart-define=NEWS_API_KEY=your_key

   # Web
   flutter build web --dart-define=NEWS_API_KEY=your_key
   ```

### Running Without API Key

If you run the app without providing an API key, a dedicated error screen will appear with instructions. This prevents confusing 401 errors later.

---

## 🏗️ Architecture Overview

The application follows **Clean Architecture** principles, organized into three main layers:

### Project Structure

```
lib/
├── core/                           # Core functionality
│   ├── config/                     # App configuration
│   │   ├── app_config.dart         # API keys and base URLs
│   │   └── api_key_missing_screen.dart
│   ├── error/                      # Error handling
│   │   └── failures.dart           # Failure types
│   ├── injection/                  # Dependency injection
│   │   └── service_locator.dart    # GetIt setup
│   └── usecase/                    # Base use case
│       └── usecase.dart
│
├── features/                       # Feature modules
│   └── news/                       # News feature
│       ├── data/                   # Data layer
│       │   ├── datasources/
│       │   │   ├── news_remote_data_source.dart    # API calls
│       │   │   └── news_local_data_source.dart     # Local caching
│       │   ├── models/             # Data models (Freezed)
│       │   │   ├── article_model.dart
│       │   │   └── article_source_model.dart
│       │   └── repositories/
│       │       └── news_repository_impl.dart       # Repository implementation
│       │
│       ├── domain/                 # Business logic layer
│       │   ├── entities/
│       │   │   └── article.dart    # Article entity
│       │   ├── repositories/
│       │   │   └── news_repository.dart           # Repository interface
│       │   └── usecases/
│       │       ├── get_top_headlines.dart
│       │       └── search_news.dart
│       │
│       └── presentation/           # UI layer
│           ├── bloc/               # State management
│           │   ├── news_bloc.dart
│           │   ├── news_event.dart
│           │   └── news_state.dart
│           └── pages/
│               ├── home_page.dart
│               ├── search_page.dart
│               └── article_detail_page.dart
│
└── main.dart                       # App entry point
```

### Layer Responsibilities

#### 1. **Presentation Layer** (`presentation/`)
- **Purpose**: User interface and user interaction
- **Components**:
  - **Pages**: Material Design 3 UI with SliverAppBar, custom cards, animations
  - **BLoC**: State management using `flutter_bloc`
  - **Events**: User actions (fetch headlines, search, etc.)
  - **States**: UI states (loading, loaded, error)

#### 2. **Domain Layer** (`domain/`)
- **Purpose**: Pure business logic, independent of frameworks
- **Components**:
  - **Entities**: Core business objects (Article)
  - **Repositories**: Abstract interfaces defining data operations
  - **Use Cases**: Single-responsibility business actions
    - `GetTopHeadlines`: Fetch top news headlines
    - `SearchNews`: Search for specific news

#### 3. **Data Layer** (`data/`)
- **Purpose**: Data management and external communication
- **Components**:
  - **Data Sources**:
    - **Remote**: API calls using Dio
    - **Local**: Hive-based caching for offline support
  - **Models**: Freezed models with JSON serialization
  - **Repository Implementation**: Coordinates remote/local sources, handles offline logic

#### 4. **Core Layer** (`core/`)
- **Purpose**: Shared utilities and configuration
- **Components**:
  - **Config**: API configuration using `--dart-define`
  - **Errors**: Typed failures (ServerFailure, CacheFailure, ConnectionFailure)
  - **Dependency Injection**: GetIt service locator
  - **Use Case Base**: Abstract use case pattern

---

## 🎯 Key Decisions and Trade-offs

### 1. **Clean Architecture**
**Decision**: Implemented Clean Architecture with strict layer separation.

**Benefits**:
- High testability with mockable interfaces
- Business logic independent of UI and frameworks
- Easy to swap data sources or UI frameworks
- Clear responsibility boundaries

**Trade-offs**:
- More boilerplate code (models, repositories, use cases)
- Potentially over-engineered for a simple app

**Rationale**: Chosen for long-term maintainability and scalability. Worth the initial complexity for a production app.

---

### 2. **BLoC Pattern for State Management**
**Decision**: Used `flutter_bloc` with context-based providers instead of global GetIt injection.

**Benefits**:
- Clear unidirectional data flow
- Excellent separation of business logic and UI
- Built-in testing support
- Lifecycle management tied to widget tree

**Trade-offs**:
- Verbose compared to simpler solutions (Provider, Riverpod)

- More files per feature (event, state, bloc)

**Rationale**: BLoC is battle-tested for complex apps and scales well. Context-based providers offer better lifecycle control than global injection.

---

### 3. **Dependency Injection: GetIt + BlocProvider Hybrid**
**Decision**: GetIt for service locator, but BLoC instances managed via `BlocProvider`.

**Benefits**:
- GetIt handles infrastructure (Dio, Hive, repositories)
- BlocProvider manages widget-scoped state
- Clear separation: services are singletons, BLoCs are scoped
- Easy testing with `initForTesting()`

**Trade-offs**:
- Two DI mechanisms might confusing or hard to track
- Requires discipline to know when to use which

**Rationale**: Hybrid approach leverages strengths of both: GetIt for app-wide services, BlocProvider for UI state.

---

### 4. **Offline-First with Cache Strategy**
**Decision**: Always try cache first, then network. Show cached data while fetching fresh data.

**Benefits**:
- Instant content display on app launch
- Works offline with previously viewed content
- Reduced data usage
- Better user experience on slow connections

**Trade-offs**:
- Stale data might be shown briefly
- Cache invalidation complexity
- Search cache only stores last query

**Implementation**:
- **Headlines**: Single cached key, refreshed on app start
- **Search**: Last search query cached (single key)
- **Connection Check**: `InternetConnectionChecker` determines strategy

---

### 5. **API Key Security with `--dart-define`**
**Decision**: Rejected `.env` files; used `--dart-define` for compile-time injection.

**Benefits**:
- API key never committed to version control
- No runtime environment variable parsing
- Works consistently across platforms
- Compile-time errors if missing (with validation)

**Trade-offs**:
- Must provide key with every `flutter run` command
- Slightly more complex CI/CD setup
- No easy key rotation without rebuild

**Rationale**: Security best practice. The app validates presence at startup and shows a helpful error screen if missing.

---

### 6. **Freezed for Data Models**
**Decision**: Used Freezed for immutable models with JSON serialization.

**Benefits**:
- Type-safe, immutable models
- Built-in equality and hashing
- Automatic `copyWith`, `toString`
- JSON serialization/deserialization

**Trade-offs**:
- Requires code generation (`build_runner`)
- Longer build times
- More boilerplate in model files

**Rationale**: Reduces bugs from mutable state and manual JSON parsing. Worth the build time cost.

---

### 7. **Material Design 3 Expressive**
**Decision**: Rejected basic Material components for premium, expressive design.

**Benefits**:
- Modern, visually impressive UI
- Dynamic color schemes adapt to system
- Micro-animations improve UX
- SliverAppBar for engaging scrolling

**Trade-offs**:
- More styling code
- Potential performance impact (animations)

**Rationale**: First impressions matter. Users expect polished apps; basic Material feels dated.

---

### 8. **Error Handling with Dartz Either**
**Decision**: Used `dartz` for functional error handling with `Either<Failure, Success>`.

**Benefits**:
- Explicit error paths (no exceptions)
- Forces developers to handle errors
- Composable with fold, map, etc.
- Type-safe failure types

**Trade-offs**:
- Less intuitive for developers unfamiliar with FP
- Verbose error handling in BLoC
- Stack traces less visible

**Rationale**: Makes error handling explicit and testable. Prevents forgotten try-catch blocks.

---

### 9. **Multi-Platform Support**
**Decision**: Built for all platforms (iOS, Android, Web, Desktop).

**Benefits**:
- Single codebase for all platforms
- Wider user reach
- Easier maintenance

**Trade-offs**:
- Platform-specific bugs
- Web performance constraints
- Desktop UI might not feel native

**Rationale**: Flutter's promise is multi-platform. Minimal extra work for significant reach.

---

## ⚠️ Known Limitations


### 1. **Search Cache Limitations**
**Issue**: Search cache stores only the **last query** in a single key. Offline users can't access results from previous searches.

**Impact**: Poor offline search experience; only one query available.

**Recommendation**:
- Cache results by query key (e.g., `search_flutter`, `search_dart`)
- Implement bounded cache (max 10 queries)
- Add cache eviction strategy (LRU)

---


### 2. **Single Source for Headlines**
**Issue**: The app fetches top headlines from all sources/categories mixed together.

**Impact**: Users can't filter by source (BBC, CNN) or category (sports, tech).

**Recommendation**:
- Add category filter chips (Business, Tech, Sports, etc.)
- Add source selection (optional)
- Update `GetTopHeadlines` use case to accept category/source parameters

---


---

### 3. **API Key Validation on Startup**
**Issue**: While the app checks for an empty API key, it doesn't validate the key's correctness until the first API call fails.

**Impact**: Users with invalid keys see generic errors after app launch, not immediately.

**Recommendation**:
- Optionally ping the API during startup with the key
- Show validation status on the missing key screen
- Cache validation result to avoid repeated checks

---

### 4. **No Image Fallback for Broken URLs**
**Issue**: If an article's image URL is broken or null, the UI might show an error icon or blank space.

**Impact**: Inconsistent visual experience.

**Recommendation**:
- Add placeholder images for articles without images
- Use `CachedNetworkImage`'s `errorWidget` parameter
- Consider generating dynamic placeholder images (initials, colors)

---

### 5. **No Pull-to-Refresh**
**Issue**: Users can't manually refresh headlines or search results.

**Impact**: Stale data remains until app restart.

**Recommendation**:
- Wrap `CustomScrollView` in `RefreshIndicator`
- Trigger `GetTopHeadlinesEvent()` or `SearchNewsEvent()` on pull

---

### 6. **Test Coverage**
**Issue**: While the architecture supports testing, there are no unit or widget tests in the repository.

**Impact**: Harder to catch regressions; unclear if features work as expected.

**Recommendation**:
- Add unit tests for:
  - Use cases
  - Repositories (with mocked data sources)
  - BLoC (with mocked repositories)
- Add widget tests for critical UI flows
- Set up CI/CD to run tests automatically

---

### 7. **No Analytics or Crash Reporting**
**Issue**: No visibility into user behavior or production crashes.

**Impact**: Can't measure feature usage or debug production issues.

**Recommendation**:
- Integrate Firebase Analytics for usage tracking
- Add Crashlytics or Sentry for crash reporting
- Track key events (article views, searches, errors)

---

## 🛠️ Dependencies

### Production Dependencies
| Package | Purpose |
|---------|---------|
| `flutter_bloc` | State management with BLoC pattern |
| `get_it` | Dependency injection / Service locator |
| `dio` | HTTP client for API requests |
| `dartz` | Functional programming (Either, Option) |
| `hive_flutter` | Local NoSQL database for caching |
| `freezed` | Immutable models and unions |
| `json_annotation` | JSON serialization |
| `equatable` | Value equality for models |
| `cached_network_image` | Image caching |
| `google_fonts` | Custom typography |
| `shimmer` | Loading state animations |
| `lottie` | Advanced animations |
| `url_launcher` | Open URLs in browser |
| `internet_connection_checker` | Network connectivity |
| `dynamic_color` | Material You dynamic theming |

### Dev Dependencies
| Package | Purpose |
|---------|---------|
| `flutter_test` | Testing framework |
| `build_runner` | Code generation |
| `freezed` | Code generation for models |
| `json_serializable` | JSON code generation |
| `flutter_lints` | Linting rules |

---

## 📱 Screenshots

*Add screenshots of your app here*

---

**Built with ❤️ using Flutter**
