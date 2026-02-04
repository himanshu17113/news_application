# AI Usage Report

## AI Tools Used
I utilized the following AI capabilities and tools during the development of the codebase:
- **Primary Tools**: **Cursor**, **Google Antigravity**, and **ChatGPT** were leveraged for their superior context understanding and prompting capabilities.


## Where AI Was Used (Files/Modules)
I utilized AI assistance across key modules of the application, incorporating my own modifications to ensure alignment with architectural and design goals:

- **Core Module**: AI helped refactor error handling and resolve lint warnings. I embraced the technical cleanups but maintained control over the error domain definitions.
- **Dependency Injection**: AI assisted in resolving instantiation issues. I significantly modified this module by rejecting the AI's global `get_it` proposal and enforcing a context-based strategies using `flutter_bloc` to better manage lifecycles.
- **Build Configuration**: AI assisted with Gradle environment troubleshooting. I modified the implementation to strictly use Dart runtime variables (`--dart-define`) for API keys instead of `.env` files, improving security.
- **News Feature (Presentation)**: AI generated the initial functional UI layouts. I heavily modified these to reject standard defaults in favor of a "Material Expressive" design system (using `SliverAppBar`, custom typography, and micro-animations) to achieve a premium user experience.
- **News Feature (Data)**: AI provided the boilerplate for remote data sources. I refined this by introducing stricter response validation and more semantic error handling for offline states.

## What I Accepted vs. Modified
### Accepted
- Most boilerplate code and fixes for errors, like the `InternetConnectionChecker` instantiation in dependency injection—it was spot-on and saved time.
- Core logic for data handling and errors in the core module, as it aligned well with my needs.

### Modified
- **UI elements**: I took AI's basic layouts for pages like `ArticleCard` and `ArticleDetailPage`, but customized them with rounded corners, shadows, and animations to fit a more premium, expressive design.
- **Dependency injection**: Started with AI's `get_it` suggestion, but switched to `flutter_bloc`'s `BlocProvider` and `RepositoryProvider` for better context management.
- **API key handling**: Changed from a `.env` file to Dart's `--dart-define` for improved security.

## Suggestions I Rejected and Why
- **Default Material UI**: AI suggested simple app bars, but I went with `SliverAppBar` for a more dynamic feel—defaults felt too basic.
- **Global `get_it` for Blocs**: Rejected because it didn't match my preferred BLoC patterns; context-based providers offer better lifecycle control.
- **Simpler state management**: I stuck with Clean Architecture and BLoC for scalability, even if it meant more boilerplate—long-term maintainability matters more.

## Example Where I Improved AI Output
- **Context**: Dependency injection setup.
- **AI's Output**: Used `get_it` for global service location in Blocs.
- **My Improvement**: Switched to `flutter_bloc`'s context providers (`BlocProvider`, `RepositoryProvider`).
- **Reasoning**: Global injection can lead to messy lifecycles; my change ensures cleaner separation and easier testing, aligning with standard Flutter practices. I tested it manually to confirm it worked better in the app's flow.

## Offline and Error Semantics
**Issue**: When offline and cache is empty, the repository returns `CacheFailure` (e.g. "No cached news available"). The UI treats that as "cache empty" and shows "No cached headlines. Connect to load news." While reasonable, semantically the root cause is no connection; the UI could distinguish "no network" from "no cached data" for copy or actions.

**Search Cache**: Search cache is a single "last search" key. Offline users only see the last query’s results; previous queries aren’t available.

**Recommendation**: When offline and cache is empty, consider returning `ConnectionFailure` (and keep `CacheFailure` for "online but cache miss" if you ever add that). In the BLoC/UI, branch on `ConnectionFailure` vs `CacheFailure` to show "No internet" vs "No cached data" where useful. Optionally extend the local data source to cache search results by query (with a bounded number of keys) so offline search can show results for more than the last query.

## Remote Data Source Observations & Suggestions
**Current Issues (`news_remote_data_source.dart`)**:
- Exceptions are wrapped as `ServerFailure(e.toString())`, which can expose stack traces or internal messages.
- There are no Dio interceptors (timeouts, retries, logging).
- `response.data['articles']` is used without checking for null or non-List, so malformed responses could cause runtime errors.

**Suggestions**:
- **Dio Configuration**: Give Dio a `BaseOptions` with connectTimeout/receiveTimeout and add interceptors for logging and, if you want, retries.
- **Error Mapping**: Map known failure cases (e.g. 401, 429, no connection) to specific failure types or messages; for unexpected errors use a generic message and log the exception.
- **Validation**: Validate `response.data` and `response.data['articles']` (e.g. as List?) and handle null/empty/malformed data so you never throw from raw cast or index access.
- **Model Serialization**: Use `json_serializable` or `freezed` for models to automate JSON parsing and reduce the risk of manual serialization errors.

## API Key and Startup Error Handling
**Issue**: `AppConfig.newsApiKey` uses `String.fromEnvironment('NEWS_API_KEY')` with no default, which is correctly secure. However, if the key is missing (e.g. run without `--dart-define=NEWS_API_KEY=...`), the app still starts and eventually fails with generic API errors (e.g. 401), lacking a clear indication of the missing configuration.

**Recommendation**: After `WidgetsFlutterBinding.ensureInitialized()`, check if `AppConfig.newsApiKey` is empty or invalid. If missing, display a dedicated screen or dialog (e.g. "News API key not set. Run with --dart-define=NEWS_API_KEY=your_key") and prevent the main news flow from starting, making the error obvious and actionable.
