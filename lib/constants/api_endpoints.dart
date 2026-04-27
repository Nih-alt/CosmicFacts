import 'api_keys.dart';

/// Centralized registry of all third-party API base URLs and URL builders.
///
/// Open-Notify is the only HTTP-not-HTTPS endpoint — the service does not
/// expose a TLS variant. All others are HTTPS.
abstract final class ApiEndpoints {
  // ── Base URLs ──
  static const String nasaBase        = 'https://api.nasa.gov';
  static const String nasaImages      = 'https://images-api.nasa.gov';
  static const String snapi           = 'https://api.spaceflightnewsapi.net/v4';
  static const String spaceX          = 'https://api.spacexdata.com/v5';
  static const String wheretheiss     = 'https://api.wheretheiss.at/v1';
  static const String openNotify      = 'http://api.open-notify.org';
  static const String exoArchive      = 'https://exoplanetarchive.ipac.caltech.edu/TAP/sync';
  static const String epic            = 'https://epic.gsfc.nasa.gov';
  static const String arxivApi        = 'https://export.arxiv.org/api/query';
  static const String arxivWeb        = 'https://arxiv.org';
  static const String noaa            = 'https://services.swpc.noaa.gov';
  static const String openMeteo       = 'https://api.open-meteo.com/v1/forecast';
  static const String celestrak       = 'https://celestrak.org';
  static const String youtube         = 'https://www.youtube.com';
  static const String nasaAudio       = 'https://www.nasa.gov/audio-and-ringtones/';
  static const String googleCalRender = 'https://calendar.google.com/calendar/render';

  // ── External brand / legal ──
  static const String playStore =
      'https://play.google.com/store/apps/details?id=com.cosmicfacts.app';
  static const String privacyPolicy =
      'https://nih-alt.github.io/cosmic-facts-privacy/';

  // ── SpaceX ──
  static String spacexLaunchesQuery() => '$spaceX/launches/query';

  // ── ISS ──
  static String issLive() => '$wheretheiss/satellites/25544';
  static String issNow() => '$openNotify/iss-now.json';
  static String astronautsInSpace() => '$openNotify/astros.json';

  // ── NASA ──
  static String apod({String? date}) {
    final d = date != null ? '&date=$date' : '';
    return '$nasaBase/planetary/apod?api_key=${ApiKeys.nasaApiKey}$d';
  }

  static String neoFeed(String dateIso) =>
      '$nasaBase/neo/rest/v1/feed?start_date=$dateIso&end_date=$dateIso&api_key=${ApiKeys.nasaApiKey}';

  static String neoDetail(String id) =>
      '$nasaBase/neo/rest/v1/neo/$id?api_key=${ApiKeys.nasaApiKey}';

  // ── EPIC (NASA Earth Polychromatic Imaging Camera) ──
  static String epicAvailableDates() => '$epic/api/natural/all';
  static String epicImagesByDate(String date) => '$epic/api/natural/date/$date';
  static String epicImagesLatest() => '$epic/api/natural';

  /// Direct CDN JPG for an EPIC image (date in `yyyy-MM-dd` format).
  static String epicImageJpg(String date, String imageName) {
    final p = date.split('-');
    return '$epic/archive/natural/${p[0]}/${p[1]}/${p[2]}/jpg/$imageName.jpg';
  }

  // ── NASA Images & Video Library ──
  static String nasaImageAsset(String nasaId) => '$nasaImages/asset/$nasaId';

  // ── arXiv ──
  static String arxivPdf(String id) => '$arxivWeb/pdf/$id';
  static String arxivAbstract(String id) => '$arxivWeb/abs/$id';

  // ── YouTube ──
  static String youtubeSearch(String q) =>
      '$youtube/results?search_query=${Uri.encodeQueryComponent(q)}';

  // ── CelesTrak ──
  static String tleByCatNum(int catNum) =>
      '$celestrak/SATCAT/tle.php?CATNR=$catNum';
}
