import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API keys are loaded from the gitignored `.env` file at the project root
/// (see pubspec.yaml `assets` block). Falls back to `DEMO_KEY` so first-run
/// and CI builds still function, albeit at 30 req/hr.
///
/// Get a free NASA key (1000 req/hr) at https://api.nasa.gov.
abstract final class ApiKeys {
  static String get nasaApiKey =>
      dotenv.env['NASA_API_KEY'] ?? 'DEMO_KEY';
}
