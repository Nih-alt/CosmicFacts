# 🔧 Cosmic Facts — Refactor Audit Report

> **Audit type:** Read-only static analysis · **Date:** 2026-04-27 · **Scope:** 108 Dart files in `lib/`
>
> Goal: produce enough detail that a follow-up CLI prompt can perform safe, targeted refactors for 6 consolidation areas.

---

## Executive Summary

| Metric | Value |
| --- | --- |
| Total files affected (across all 6 areas) | **~46** |
| Estimated lines reduced | **~580–650 lines** |
| Estimated new files created | **6** (1 widget folder w/ 4 widgets, 2 util files, 1 endpoints class, expansion of `app_colors.dart`) |
| Risk profile | **Area 1, 2, 3, 6: LOW** · **Area 4: LOW** · **Area 5: MEDIUM** (visual diff possible if dark/light tokens change) |
| Existing helpers | `lib/theme/app_colors.dart` (mature — extend), `lib/constants/api_keys.dart` (env-based — extend with endpoints), `lib/theme/app_text_styles.dart`, `lib/utils/astronomy_math.dart`, `lib/utils/launch_branding.dart`, `lib/utils/earth_geo_helper.dart` (untracked) |

### Recommended Execution Order
1. **Area 4 (URLs)** — pure constant extraction, zero visual risk, prerequisite for cleaner controllers.
2. **Area 5 (Theme helpers)** — adds new constants/extensions to `AppColors` *without* changing existing tokens. Safe baseline for state widgets in Area 6.
3. **Area 2 (Date) + Area 3 (Number)** — independent, can be done in parallel. Mechanical replacement.
4. **Area 1 (Shimmer)** — depends on Area 5 (uses `AppColors.shimmer*`).
5. **Area 6 (State widgets)** — should be **last** so it can use Areas 5 + the cleaned `AppColors` helpers; introduces a new public widget API that other refactors should not have to chase.

---

## Area 1 — Shimmer Loaders

### Findings (17 `Shimmer.fromColors` call sites across 13 files)

| File | Line | What shimmers | baseColor / highlightColor | Shape |
| --- | --- | --- | --- | --- |
| `lib/screens/home/apod_archive_screen.dart` | 563 | APOD detail card (image + 5 text rows) | `AppColors.shimmerBase/Highlight(context)` | rounded 20 |
| `lib/screens/home/apod_archive_screen.dart` | 597 | helper `_shimmerBox(double h)` — flat block | `AppColors.shimmerBase/Highlight` | square (no radius) |
| `lib/screens/home/home_screen.dart` | 877 | Top-level helper `_shimmerRect(double height)` | `AppColors.shimmer*` w/ fallback to `AppColors.cardDark` | rounded 20 |
| `lib/screens/explore/explore_screen.dart` | 1168 | Masonry grid (8 tiles, height pattern `[1.3, 0.9, 1.1, 1.5, 0.8, 1.2, 1.0, 1.4]`) | `AppColors.shimmer*` | rounded 14 |
| `lib/screens/explore/explore_screen.dart` | 1192 | JWST horizontal list (3 × 280w cards) | `AppColors.shimmer*` | rounded 16 |
| `lib/screens/explore/exoplanet_explorer_screen.dart` | 1308 | List shimmer (5 × 84h rows) | `AppColors.shimmer*` | rounded 16 |
| `lib/screens/explore/nasa_gallery_screen.dart` | 469 | **DRIFT** — Masonry 10 tiles | **inline `Color(0xFF141438)/Color(0xFFEEEEFF)`** for base, `Color(0xFF1E1E4A)/Color(0xFFDDDDFF)` highlight | rounded 14 |
| `lib/screens/explore/image_detail_screen.dart` | 371 | `CachedNetworkImage` placeholder | `AppColors.shimmer*` | square (full container) |
| `lib/screens/explore/image_detail_screen.dart` | 979 | helper `_shimmerBox(w, h, {radius})` | `AppColors.shimmer*` | configurable radius |
| `lib/screens/explore/wallpapers_screen.dart` | 237 | `_shimmerTile()` for grid | `AppColors.shimmer*` | rounded 14 |
| `lib/screens/research/space_research_screen.dart` | 857 | List shimmer (5 × 120h rows) | `AppColors.shimmer*` | rounded 16 |
| `lib/screens/stories/story_feed_screen.dart` | 374 | `_buildShimmerLoading()` (3 × 200h cards) | `AppColors.shimmer*` | rounded 20 |
| `lib/screens/stories/article_detail_screen.dart` | 234 | `CachedNetworkImage` placeholder | `AppColors.shimmer*` | square (fills parent) |
| `lib/screens/weather/space_weather_screen.dart` | 1124 | List shimmer (4 rows, first=160h, rest=90h) | `AppColors.shimmer*` | rounded 16 |
| `lib/screens/home/earth_from_space_screen.dart` | 359 | **DRIFT** — Hero EPIC image (circular planet placeholder) | **`Colors.white.withValues(alpha: 0.06 / 0.18)`** | `BoxShape.circle` |
| `lib/screens/home/earth_from_space_screen.dart` | 1057 | **DRIFT** — same circular planet placeholder (duplicated for fullscreen) | **same inline white-alpha** | `BoxShape.circle` |
| `lib/screens/launches/launches_screen.dart` | 1057 | Hero (200h) shimmer | `AppColors.shimmer*` | rounded 20 |
| `lib/screens/launches/launches_screen.dart` | 1073 | List shimmer (5 × 90h rows) | `AppColors.shimmer*` | rounded 14 |
| `lib/screens/quick_actions/iss_tracker_screen.dart` | 778 | `_buildShimmer(double height)` helper | `AppColors.shimmer*` | rounded 16 |
| `lib/screens/quick_actions/asteroids_screen.dart` | 1170 | `_buildShimmer(double height)` helper (identical to ISS) | `AppColors.shimmer*` | rounded 16 |

### Variations / Edge Cases
- **Two screens use inline hex colors** instead of `AppColors.shimmerBase/Highlight`:
  - `nasa_gallery_screen.dart:469-473` — uses purple-ish `0xFF141438` / `0xFFEEEEFF` (legacy palette).
  - `earth_from_space_screen.dart:359, 1057` — uses white-alpha because it draws over a black hero background where `shimmerBase` (a near-black) would be invisible. **This is intentional** — a pure consolidation would break the visual.
- **3 different "rectangle" radii**: 14 (grid tiles), 16 (list rows), 20 (hero/cards). Settle on enum or named constants.
- **`home_screen.dart:872` `_shimmerRect`** has a fallback path `context != null ? ... : AppColors.cardDark` — only reachable via legacy callers; safe to require context.
- **Duplicated helpers**: `_buildShimmer(double height)` is byte-identical in `iss_tracker_screen.dart:778` and `asteroids_screen.dart:1170`.

### Proposed API — `lib/widgets/shimmer/shimmer_widgets.dart`
```dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/app_colors.dart';

/// Rectangular shimmer block. Default radius is 16 (most common).
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double radius;
  /// When `true`, uses translucent white-alpha (for overlays on dark hero
  /// imagery, e.g. EPIC Earth). Defaults to themed AppColors.shimmer*.
  final bool overlay;
  const ShimmerBox({
    super.key, this.width, this.height,
    this.radius = 16, this.overlay = false,
  });

  @override
  Widget build(BuildContext context) {
    final base = overlay
        ? Colors.white.withValues(alpha: 0.06)
        : AppColors.shimmerBase(context);
    final hi = overlay
        ? Colors.white.withValues(alpha: 0.18)
        : AppColors.shimmerHighlight(context);
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: hi,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class ShimmerCircle extends StatelessWidget {
  final double size;
  final bool overlay;
  const ShimmerCircle({super.key, required this.size, this.overlay = false});
  // ... uses BoxShape.circle, otherwise same logic
}

/// `count` ShimmerBoxes stacked vertically with `gap` spacing.
/// Optional `firstHeight` for hero+list patterns (weather, launches).
class ShimmerList extends StatelessWidget {
  final int count;
  final double rowHeight;
  final double? firstHeight;
  final double radius;
  final EdgeInsets padding;
  final double gap;
  // ...
}

/// Masonry grid shimmer using a height-ratio pattern.
class ShimmerMasonryGrid extends StatelessWidget {
  final int crossAxisCount;
  final int childCount;
  final double baseHeight;
  final List<double> heightPattern;
  final double radius;
  // ...
}
```

### Migration Plan
1. Create `lib/widgets/shimmer/shimmer_widgets.dart` with the 4 widgets above.
2. Replace each `Shimmer.fromColors(...)` block listed in the findings table — start with the easy ones using `AppColors.shimmer*` (15/19 sites are mechanical).
3. For the 2 EPIC sites in `earth_from_space_screen.dart`, use `ShimmerCircle(size: h * 0.7, overlay: true)`.
4. For `nasa_gallery_screen.dart:469`, switch to `ShimmerMasonryGrid(...)` and remove the inline hex colors — accept this as a **deliberate visual unification** (the legacy purple-ish palette is no longer used elsewhere).
5. Drop the now-orphan local helpers: `_shimmer`, `_shimmerBox`, `_shimmerRect`, `_shimmerTile`, `_buildShimmer`, `_buildShimmerLoading`, `_buildShimmerSliver`, `_buildJWSTShimmer`.

### Risk: **LOW**
- All sites except 3 already use the canonical `AppColors.shimmer*` tokens; consolidation doesn't change colors.
- One *intentional* visual change: `nasa_gallery_screen` will adopt the standard blue palette (currently a purple drift).
- `shimmer` package API is stable.

### Lines saved estimate: **~140 lines**

---

## Area 2 — Date Formatters

### Findings (`DateFormat` and inline date string formatting)

| File | Line | Pattern | Input | Intent |
| --- | --- | --- | --- | --- |
| `lib/screens/home/apod_archive_screen.dart` | 39 | `DateFormat('MMMM d, yyyy')` | `DateTime` | Display ("April 25, 2026") |
| `lib/screens/home/apod_archive_screen.dart` | 40 | `DateFormat('yyyy-MM-dd')` | `DateTime` | API (`?date=`) |
| `lib/screens/home/space_stats_screen.dart` | 103 | `DateFormat('yyyy.MM.dd')` | `DateTime.now()` | Display ("STARDATE 2026.04.25") |
| `lib/screens/quick_actions/asteroids_screen.dart` | 56 | `DateFormat('yyyy-MM-dd')` | `_selectedDate` | Cache key + API param |
| `lib/screens/quick_actions/asteroids_screen.dart` | 442 | `DateFormat('MMM d, y')` | `DateTime` | Display ("Apr 25, 2026") |
| `lib/screens/quick_actions/asteroids_screen.dart` | 443 | `DateFormat('EEE, MMM d, y')` | `DateTime` | Display ("Sat, Apr 25, 2026") |
| `lib/screens/quick_actions/asteroid_detail_screen.dart` | 88 | `DateFormat('yyyy-MMM-dd HH:mm').parseLoose(...)` | NASA NEO API string | Parse |
| `lib/screens/quick_actions/asteroid_detail_screen.dart` | 91 | `DateFormat('EEE, MMM d y · HH:mm')` | `DateTime` | Display + " UTC" suffix |
| `lib/services/api_service.dart` | 27-29 | **Inline padding**: `'${date.year}-${date.month.toString().padLeft(2, "0")}-${date.day.toString().padLeft(2, "0")}'` | `DateTime` | API (APOD `?date=`) |
| `lib/controllers/space_stats_controller.dart` | 137 | `DateTime.now().toIso8601String().split('T')[0]` | — | API (NEO feed) |
| `lib/services/api_service.dart` | 607 | `(date ?? DateTime.now()).toIso8601String().split('T')[0]` | `DateTime?` | API (NEO feed) |

### Relative-time formatters (ad-hoc, three independent implementations)

| File | Line | Pattern | Output |
| --- | --- | --- | --- |
| `lib/screens/weather/space_weather_screen.dart` | 215-225 | `_ago(DateTime)` — minutes/hours | `"3 min ago"`, `"2h ago"`, `"< 1h ago"` |
| `lib/screens/research/space_research_screen.dart` | 141-143 | inline | `"5 days ago"`, `"3 weeks ago"`, `"6 months ago"` |
| `lib/screens/stories/story_feed_screen.dart` | 857-860 | top-level fn | `"15m ago"`, `"3h ago"`, `"2d ago"`, `"1w ago"` |

### Time-of-day extraction

| File | Line | Note |
| --- | --- | --- |
| `lib/screens/home/earth_from_space_screen.dart` | (uses `_extractTime(dateStr)` ~line 397) | Manual substring on EPIC `"YYYY-MM-DD HH:MM:SS"` |

### Variations to call out
- **3 independent "X ago" formatters** with **3 different short forms** ("min" vs "m", "weeks" vs "w"). Need a single canonical form.
- The API-format pattern `'yyyy-MM-dd'` appears via 4 different code paths: `DateFormat`, manual `padLeft`, `toIso8601String().split`, and a hardcoded helper inside `api_service`.
- `EEE, MMM d, y` and `EEE, MMM d y` differ only by a comma — likely an oversight in `asteroid_detail_screen.dart:91`.

### Proposed API — `lib/utils/date_format_utils.dart`
```dart
import 'package:intl/intl.dart';

abstract final class DateFormatUtils {
  // Display
  static final _editorial   = DateFormat('MMMM d, yyyy');     // "April 25, 2026"
  static final _compact     = DateFormat('MMM d, y');         // "Apr 25, 2026"
  static final _compactDay  = DateFormat('EEE, MMM d, y');    // "Sat, Apr 25, 2026"
  static final _stardate    = DateFormat('yyyy.MM.dd');       // "2026.04.25"
  static final _timestampUtc= DateFormat('EEE, MMM d y · HH:mm'); // + " UTC"
  // API
  static final _api         = DateFormat('yyyy-MM-dd');       // "2026-04-25"
  // Parsers
  static final _neoApi      = DateFormat('yyyy-MMM-dd HH:mm');// NASA NEO close-approach

  static String editorial(DateTime d)  => _editorial.format(d);
  static String compact(DateTime d)    => _compact.format(d);
  static String compactDay(DateTime d) => _compactDay.format(d);
  static String stardate(DateTime d)   => _stardate.format(d);
  static String api(DateTime d)        => _api.format(d);
  static String timestampUtc(DateTime d) => '${_timestampUtc.format(d)} UTC';

  static DateTime? parseNeo(String s) {
    try { return _neoApi.parseLoose(s); } catch (_) { return null; }
  }

  /// "3 min ago" / "2h ago" / "5d ago" / "3w ago" — picks short form.
  /// Use [verbose]=true for "5 days ago" / "3 weeks ago" (research screen style).
  static String relative(DateTime past, {bool verbose = false, DateTime? now}) {
    final diff = (now ?? DateTime.now()).difference(past);
    if (diff.inMinutes < 1)  return 'just now';
    if (diff.inHours   < 1)  return verbose ? '${diff.inMinutes} min ago' : '${diff.inMinutes}m ago';
    if (diff.inDays    < 1)  return verbose ? '${diff.inHours} hours ago' : '${diff.inHours}h ago';
    if (diff.inDays    < 7)  return verbose ? '${diff.inDays} days ago'   : '${diff.inDays}d ago';
    if (diff.inDays    < 30) {
      final w = diff.inDays ~/ 7;
      return verbose ? '$w weeks ago' : '${w}w ago';
    }
    if (diff.inDays    < 365) {
      final mo = diff.inDays ~/ 30;
      return verbose ? '$mo months ago' : '${mo}mo ago';
    }
    final y = diff.inDays ~/ 365;
    return verbose ? '$y years ago' : '${y}y ago';
  }
}
```

### Migration Plan
1. Create `lib/utils/date_format_utils.dart`.
2. Replace `DateFormat(...)` static fields in `apod_archive_screen.dart`, `asteroids_screen.dart`, `space_stats_screen.dart`, `asteroid_detail_screen.dart`.
3. Replace `_formatApodDate` (api_service.dart:27-29) and the two `toIso8601String().split('T')[0]` sites with `DateFormatUtils.api(...)`.
4. Delete the three `_ago`/inline relative formatters; replace call sites with `DateFormatUtils.relative(dt)` (use `verbose: true` at `space_research_screen.dart:141`).
5. Audit one inconsistency: `asteroid_detail_screen.dart:91` uses `'EEE, MMM d y · HH:mm'` (no comma after `d`); use `compactDay` + " UTC" or keep as a separate `timestampUtc` (already proposed).

### Risk: **LOW**
- Pure formatting consolidation; no behavior change beyond unifying the relative-time short form.
- `intl` is already a transitive dep.

### Lines saved estimate: **~50 lines**

---

## Area 3 — Number Formatters

### Findings — `NumberFormat` usage (5 files)

| File | Line | Code | Output |
| --- | --- | --- | --- |
| `lib/screens/home/space_stats_screen.dart` | 309 | `NumberFormat('#,###').format(age.toInt())` | "13,800,000,000" |
| `lib/screens/home/space_stats_screen.dart` | 1053 | `NumberFormat('#,###').format(n)` (`intComma`) | "5,800" |
| `lib/screens/home/space_stats_screen.dart` | 1054 | `'${NumberFormat('#,###').format(v.round())} KM/H'` (`kmh`) | "27,556 KM/H" |
| `lib/screens/home/space_stats_screen.dart` | 1055 | `'${v.toStringAsFixed(0)} KM'` (`km`) | "408 KM" |
| `lib/screens/home/orbital_mechanics_screen.dart` | 559-561 | inline ladder (`_fmt`) | "5,800" / "8" / "8.50" |
| `lib/screens/home/orbital_mechanics_screen.dart` | 758, 771, 958, 1019 | `NumberFormat('#,###').format(...)` | "27,556" |

### Findings — `toStringAsFixed` usage (≈80 sites across 14 files)

| File (top concentrations) | Approx. count | Common use |
| --- | --- | --- |
| `lib/screens/home/orbital_mechanics_screen.dart` | ~24 | velocities ("KM/S"), gravities, time-dilation factors |
| `lib/screens/quick_actions/asteroid_detail_screen.dart` | ~12 | distance (M km), AU, diameter (m), velocity (km/s) |
| `lib/screens/quick_actions/asteroids_screen.dart` | ~7 | "${distMillion.toStringAsFixed(2)}M km", "${vel.toStringAsFixed(1)} km/s" |
| `lib/screens/learn/space_calculator_screen.dart` | ~17 | escape velocity, weight, light-years, magnitudes |
| `lib/screens/explore/exoplanet_explorer_screen.dart` | ~7 | "${dist.toStringAsFixed(1)} ly", "${tempK.toStringAsFixed(0)} K" |
| `lib/screens/learn/planet_comparator_screen.dart` | ~9 | size ratios, gravity ratios |
| `lib/screens/home/earth_from_space_screen.dart` | 458-459, 581, 586, 850 | lat/lon ("12.4° N"), Sun ("149.50M km"), Moon ("385K km") |
| `lib/screens/weather/space_weather_screen.dart` | 148, 414, 515, 527 | Kp (1.5), Bz (-3.2 nT), density (4.1 p/cm³) |
| `lib/screens/home/space_stats_screen.dart` | 209-211, 289, 441, 453, 464, 577 | distance, lat/lon, mantissa |
| `lib/screens/explore/ar_sky_map_screen.dart` | 210-212, 238-239 | magnitude (2 dp), alt/az (1 dp) |
| `lib/screens/quick_actions/moon_phase_screen.dart` | 163, 282 | "% illuminated", "X.X days" |
| `lib/screens/learn/active_missions_screen.dart` | 181-185 | distance ladder km / million km / billion km |
| `lib/screens/quiz/quiz_hub_screen.dart` | 386 | "${_accuracy.toStringAsFixed(0)}%" |
| `lib/screens/tools/stargazing_forecast_screen.dart` | 804-805 | lat/lon "°N"/"°E" |

### Notable existing local formatters (good candidates to delete)
- **`active_missions_screen.dart:181-185`** — full distance ladder (km / thousand / million / billion).
- **`planet_comparator_screen.dart:239-241`** — `_fN(double)` (compact M/K), `_fP(double)` (period days/months/years), `_fD(double)` (hours/days).
- **`orbital_mechanics_screen.dart:559-561`** — `_fmt(double)` ladder.
- **`space_stats_screen.dart:1053-1055`** — `intComma`, `kmh`, `km`.
- **`learn/space_calculator_screen.dart:319`** — `tt(double dm, double sp)` distance/speed → travel time.

### Proposed API — `lib/utils/number_format_utils.dart`
```dart
import 'package:intl/intl.dart';

abstract final class NumberFormatUtils {
  static final _commas = NumberFormat('#,###');

  /// "27,556"
  static String commas(num n) => _commas.format(n);

  /// "27,556 km/h"   (set [unit]='KM/H' for caps style used in space_stats)
  static String velocity(num kmh, {String unit = 'km/h'}) =>
      '${commas(kmh.round())} $unit';

  /// "408 km" / "385K km" / "149M km" / "1.2B km" — picks unit by magnitude.
  /// Use [decimals] for the K/M/B tier.
  static String distance(num km, {int decimals = 1, String unit = 'km'}) {
    if (km.abs() >= 1e9) return '${(km / 1e9).toStringAsFixed(decimals)}B $unit';
    if (km.abs() >= 1e6) return '${(km / 1e6).toStringAsFixed(decimals)}M $unit';
    if (km.abs() >= 1e3) return '${(km / 1e3).toStringAsFixed(decimals)}K $unit';
    return '${km.toStringAsFixed(0)} $unit';
  }

  /// "1.2M" / "5.8K" / "850" — abbreviation only, no unit.
  static String compactBig(num n, {int decimals = 1}) {
    if (n.abs() >= 1e9) return '${(n / 1e9).toStringAsFixed(decimals)}B';
    if (n.abs() >= 1e6) return '${(n / 1e6).toStringAsFixed(decimals)}M';
    if (n.abs() >= 1e3) return '${(n / 1e3).toStringAsFixed(decimals)}K';
    return n.toStringAsFixed(0);
  }

  /// "87%" / "87.3%". Defaults 0 decimals.
  static String percent(num value, {int decimals = 0}) =>
      '${value.toStringAsFixed(decimals)}%';

  /// "12.4° N", "87.6° W"  (sign-aware, hemisphere letter)
  static String lat(double v, {int decimals = 1}) =>
      '${v.abs().toStringAsFixed(decimals)}° ${v >= 0 ? 'N' : 'S'}';
  static String lon(double v, {int decimals = 1}) =>
      '${v.abs().toStringAsFixed(decimals)}° ${v >= 0 ? 'E' : 'W'}';

  /// "4.351 × 10¹⁷"  (mantissa × 10^superscript)
  static String scientific(num n, {int decimals = 3}) {
    if (n == 0) return '0';
    final exp = (n.abs() == 0) ? 0 : (math.log(n.abs()) / math.ln10).floor();
    final mant = n / math.pow(10, exp);
    return '${mant.toStringAsFixed(decimals)} × 10${_sup(exp)}';
  }
  // _sup converts an int to its Unicode superscript form
}
```

### Migration Plan
1. Create `lib/utils/number_format_utils.dart`.
2. Replace `NumberFormat('#,###').format(...)` (5 sites) with `NumberFormatUtils.commas(...)`.
3. Replace `space_stats_screen.dart` helpers `intComma`, `kmh`, `km` (lines 1053-1055).
4. Replace `active_missions_screen.dart:181-185` with `NumberFormatUtils.distance(...)` (output already matches with `decimals: 0` and tweaked unit text — confirm visual).
5. Replace `earth_from_space_screen.dart:458-459` lat/lon with `NumberFormatUtils.lat/lon`.
6. Leave domain-specific ratio formatters in `planet_comparator_screen.dart` (lines 151-152, 224-229) **as-is** — they are screen-specific composite strings, not pure number formatting.
7. **Do not** rewrite simple `'${v.toStringAsFixed(2)} km/s'` interpolations en-masse — the noise is real but the helper for every unit suffix isn't worth the abstraction. Limit replacements to the patterns listed above.

### Risk: **LOW**
- Mechanical replacement, output strings unchanged.
- One subtle change: `active_missions_screen` will switch from "billion km" to "B km" unless we expose a `verbose` flag — pick one and document.

### Lines saved estimate: **~80–100 lines**

---

## Area 4 — API Endpoints (Hardcoded URLs)

### Findings — Service-layer URLs (mostly already constants, but scattered)

| File | Line | URL | Notes |
| --- | --- | --- | --- |
| `lib/services/api_service.dart` | 16 | `https://api.spaceflightnewsapi.net/v4` | `_newsBaseUrl` const |
| `lib/services/api_service.dart` | 17 | `https://api.nasa.gov` | `_nasaBaseUrl` const |
| `lib/services/api_service.dart` | 18 | `https://images-api.nasa.gov` | `_nasaImagesUrl` const |
| `lib/services/api_service.dart` | 248, 316 | `https://api.spacexdata.com/v5/launches/query` | **inline** in 2 places — duplicated |
| `lib/services/api_service.dart` | 544 | `https://api.wheretheiss.at/v1/satellites/25544` | inline `const url` |
| `lib/services/api_service.dart` | 575, 718 | `https://exoplanetarchive.ipac.caltech.edu/TAP/sync` | duplicated — twice |
| `lib/services/api_service.dart` | 598 | `http://api.open-notify.org/astros.json` | **HTTP not HTTPS** — flag |
| `lib/services/api_service.dart` | 631 | `https://epic.gsfc.nasa.gov` | `_epicBaseUrl` const |
| `lib/services/api_service.dart` | 768 | `https://export.arxiv.org/api/query` | `_arxivBase` const |
| `lib/services/api_service.dart` | 839, 886, 909-966 | `https://arxiv.org/{pdf,abs}/$id` | repeated 11+ times |
| `lib/services/api_service.dart` | 975 | `https://services.swpc.noaa.gov` | `_noaaBase` const |
| `lib/services/weather_service.dart` | 11 | `https://api.open-meteo.com/v1/forecast` | `_baseUrl` const |
| `lib/services/tle_service.dart` | 19 | `https://celestrak.org/SATCAT/tle.php?CATNR=$catNum` | inline |
| `lib/controllers/space_stats_controller.dart` | 138 | `https://api.nasa.gov/neo/rest/v1/feed?...&api_key=${ApiKeys.nasaApiKey}` | **leak** — should call ApiService |
| `lib/services/api_service.dart` | 536 | `http://api.open-notify.org/iss-now.json` | **HTTP** — flag |

### Findings — Screen-layer URL leaks (these are the real bugs)

| File | Line | URL | Notes |
| --- | --- | --- | --- |
| `lib/screens/home/apod_archive_screen.dart` | 81 | `https://api.nasa.gov/planetary/apod?api_key=${ApiKeys.nasaApiKey}&date=$dateStr` | UI fetching directly; should call `ApiService.getApodByDate(dateStr)` (which exists at line ~100s) |
| `lib/screens/home/earth_from_space_screen.dart` | 143 | `https://epic.gsfc.nasa.gov/archive/natural/${y}/${m}/${d}/jpg/$image.jpg` | Should call `ApiService.getEpicImageUrl(...)` (already exists) |
| `lib/screens/explore/image_detail_screen.dart` | 212 | `https://images-api.nasa.gov/asset/${img.nasaId}` | Asset endpoint, fine to keep but consider `ApiEndpoints.nasaImageAsset(id)` |
| `lib/screens/launches/launch_detail_screen.dart` | 325 | `https://www.youtube.com/results?search_query=$query` | External — keep, but constant-ize |
| `lib/screens/profile/profile_screen.dart` | 943, 950, 1001 | `https://play.google.com/...`, `https://nih-alt.github.io/cosmic-facts-privacy/` | App-store + privacy URL — should be in `AppConstants` |
| `lib/screens/quick_actions/space_calendar_screen.dart` | 616 | `https://calendar.google.com/calendar/render?action=TEMPLATE` | External integration — keep, constant-ize |
| `lib/screens/learn/space_sounds_screen.dart` | 102 | `https://www.nasa.gov/audio-and-ringtones/` | Static external link |
| `lib/screens/stories/article_detail_screen.dart` | 42-47 | 6 string returns mapping source name → site URL | Fine as-is; could move to a `Sources` map |

### URLs that should NOT be moved (data, not endpoints)
- `lib/data/active_missions_data.dart` lines 23-367 — 22 mission "officialUrl" entries are **content data**, not endpoints. Leave alone.
- `lib/data/space_sounds_data.dart` lines 34-141 — 10 sound asset URLs are content. Leave alone.

### Security audit — API keys
- ✅ **`lib/constants/api_keys.dart`** correctly uses `dotenv` with `DEMO_KEY` fallback. No hardcoded keys found.
- ✅ Grep for `key=`, `api_key=`, `Bearer `, `secret`, `token` in `lib/` returned **no plaintext credentials**.
- ⚠️ **HTTP-not-HTTPS**: `api_service.dart:536, 598` use `http://api.open-notify.org/...`. Open-Notify only serves over HTTP. Document or upgrade if a TLS endpoint exists.

### Proposed API — `lib/constants/api_endpoints.dart`
```dart
import '../constants/api_keys.dart';

abstract final class ApiEndpoints {
  // Base URLs
  static const String nasaBase     = 'https://api.nasa.gov';
  static const String nasaImages   = 'https://images-api.nasa.gov';
  static const String snapi        = 'https://api.spaceflightnewsapi.net/v4';
  static const String spaceX       = 'https://api.spacexdata.com/v5';
  static const String wheretheiss  = 'https://api.wheretheiss.at/v1';
  static const String openNotify   = 'http://api.open-notify.org';     // HTTP only
  static const String exoArchive   = 'https://exoplanetarchive.ipac.caltech.edu/TAP/sync';
  static const String epic         = 'https://epic.gsfc.nasa.gov';
  static const String arxivApi     = 'https://export.arxiv.org/api/query';
  static const String arxivWeb     = 'https://arxiv.org';
  static const String noaa         = 'https://services.swpc.noaa.gov';
  static const String openMeteo    = 'https://api.open-meteo.com/v1/forecast';
  static const String celestrak    = 'https://celestrak.org';
  static const String youtube      = 'https://www.youtube.com';

  // External brand / legal
  static const String playStore    = 'https://play.google.com/store/apps/details?id=com.cosmicfacts.app';
  static const String privacyPolicy= 'https://nih-alt.github.io/cosmic-facts-privacy/';

  // Helpers (URL builders for parameterized endpoints)
  static String apod({String? date}) {
    final d = date != null ? '&date=$date' : '';
    return '$nasaBase/planetary/apod?api_key=${ApiKeys.nasaApiKey}$d';
  }
  static String neoFeed(String dateIso) =>
      '$nasaBase/neo/rest/v1/feed?start_date=$dateIso&end_date=$dateIso&api_key=${ApiKeys.nasaApiKey}';
  static String neoDetail(String id) =>
      '$nasaBase/neo/rest/v1/neo/$id?api_key=${ApiKeys.nasaApiKey}';
  static String epicImageJpg(String date, String imageName) {
    final p = date.split('-');
    return '$epic/archive/natural/${p[0]}/${p[1]}/${p[2]}/jpg/$imageName.jpg';
  }
  static String arxivPdf(String id)      => '$arxivWeb/pdf/$id';
  static String arxivAbstract(String id) => '$arxivWeb/abs/$id';
  static String youtubeSearch(String q)  => '$youtube/results?search_query=${Uri.encodeQueryComponent(q)}';
}
```

### Migration Plan
1. Create `lib/constants/api_endpoints.dart`.
2. Replace `_newsBaseUrl`, `_nasaBaseUrl`, `_nasaImagesUrl`, `_epicBaseUrl`, `_arxivBase`, `_noaaBase`, `_exoplanetBase`, `_baseUrl` (weather_service) with imports from `ApiEndpoints`.
3. **Move `space_stats_controller.dart:138` to call `ApiService` instead** — it duplicates `getNearEarthAsteroids`.
4. **Move `apod_archive_screen.dart:81` to call `ApiService`** — duplicate of `getApodByDate`.
5. **Move `earth_from_space_screen.dart:143` to `ApiEndpoints.epicImageJpg(...)`** (or `ApiService.getEpicImageUrl` which already exists).
6. Replace duplicated `https://arxiv.org/{pdf,abs}/$id` (11 sites in fallback papers + parser) with `ApiEndpoints.arxivPdf(id)` / `ApiEndpoints.arxivAbstract(id)`.
7. Replace `profile_screen.dart` and `launch_detail_screen.dart` external URLs with named constants/helpers.

### Risk: **LOW**
- Pure constant extraction; no runtime behavior change.
- Slight risk: `apod_archive_screen` directly fetches because it implements its own retry-count UI — verify `ApiService.getApodByDate` returns enough detail (or keep the direct fetch but use `ApiEndpoints.apod(date: dateStr)`).

### Lines saved estimate: **~60 lines** (and removes 2 duplicate-fetch code paths)

---

## Area 5 — Theme Color Helpers

### Existing helper — `lib/theme/app_colors.dart` (mature)
The file already provides:
- Static palette constants (accentBlue/Green/Cyan/Orange, starGold, success, error, legacyPurple)
- Light/dark token pairs (`backgroundDark/Light`, `surfaceDark/Light`, `cardDark/Light`, `textPrimary/Secondary/TertiaryDark/Light`)
- Theme-aware methods: `background(ctx)`, `surface(ctx)`, `card(ctx)`, `textPrimary/Secondary/Tertiary(ctx)`, `cardBorder(ctx)`, `glass(ctx)`, `glassBorder(ctx)`, `divider(ctx)`, `searchBar(ctx)`, `pillSelected/Unselected/Border(ctx)`, `navBar/Border/Selected/Unselected(ctx)`, `shimmerBase/Highlight(ctx)`, `cardShadow(ctx)`, `coloredShadow(ctx, glow)`
- `sourceBadgeBg/Text(source, isDark)` for SpaceX/ESA badges
- Private `_isDark(ctx)` helper

**Verdict: extend, do not replace.**

### Findings — Screens declaring local `_isDark` getters (≈25 files)

This pattern is **idiomatic** and not a refactor target on its own:
```dart
bool get _isDark => Theme.of(context).brightness == Brightness.dark;
```
Used in: `apod_archive_screen`, `earth_from_space_screen`, `home_screen`, `learn_screen`, `astronaut_directory_screen`, `constellation_guide_screen`, `constellation_detail_screen`, `active_missions_screen`, `universe_timeline_screen`, `planet_comparator_screen`, `space_quotes_screen`, `space_glossary_screen`, `space_research_screen`, `space_calendar_screen`, `space_weather_screen`, `exoplanet_explorer_screen`, `nasa_gallery_screen`, `image_detail_screen`, `explore_screen`, `profile_screen`, `notification_settings_screen`, `achievements_screen`, `add_observation_screen`, `observation_log_screen`, `story_feed_screen`.

Since `_isDark` is a single line, **promoting it to a `BuildContext` extension is optional**. If desired:
```dart
extension BuildContextThemeX on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
```
Net delete: ~25 lines. **LOW value, MEDIUM churn** (every getter callsite touched). Recommend skipping unless the team agrees they want extension-style access (`context.isDarkMode`).

### Findings — **Real drift**: inline ternaries that bypass `AppColors`

The high-value cleanup is replacing **inline hex pairs** that effectively reimplement existing tokens:

#### A. Card-background drift (≈12 sites)
Pattern: `isDark ? const Color(0xFF141438) : Colors.white` — almost identical to `AppColors.cardDark` (`0xFF0A1E36`) but with a slight purple tint left over from the legacy palette.

| File | Lines |
| --- | --- |
| `lib/screens/explore/explore_screen.dart` | 858, 994, 1315, 1529 |
| `lib/screens/explore/nasa_gallery_screen.dart` | 152 |
| `lib/screens/profile/observation_log_screen.dart` | 571, 1196 |
| `lib/screens/profile/add_observation_screen.dart` | 567 |
| `lib/screens/tools/stargazing_forecast_screen.dart` | 744, 892, 982, 1040, 1219 |
| `lib/screens/quick_actions/observation_log_screen.dart` | (multiple) |

#### B. Private `_kBgDark` / `_kCardDark` constants (4 files)
Each declares its own:
- `lib/screens/explore/exoplanet_explorer_screen.dart` — `_kBgDark`, `_kCardDark` (lines around 376, 779, 1374)
- `lib/screens/weather/space_weather_screen.dart` — `_kBgDark`, `_kCardDark` (lines 235, 552, 593, 710, 870, 988, 1051)
- `lib/screens/research/space_research_screen.dart` — `_kBgDark`, `_kCardDark` (lines 156, 470)
- `lib/screens/learn/active_missions_screen.dart` — `_kBgDark`, `_kCardDark` (lines 196, 475, 883)

Action: replace the constants with `AppColors.background(context)` / `AppColors.card(context)` (or keep as `AppColors.backgroundDark` / `cardDark` if forced-dark).

#### C. Text-color drift
Pattern: `isDark ? Colors.white : const Color(0xFF1A1A2E)` (with `0xFF1A1A2E` as a near-duplicate of `AppColors.textPrimaryLight` `0xFF0A1628`).

| File | Lines (count) |
| --- | --- |
| `lib/screens/explore/explore_screen.dart` | 245, 408, 451, 940, 1339, 1368, 1401, 1435, 1527 |
| `lib/screens/explore/nasa_gallery_screen.dart` | 166 |
| `lib/screens/profile/observation_log_screen.dart` | 374, 489, 546 |
| `lib/screens/tools/stargazing_forecast_screen.dart` | 952, 995, 1007, 1132 |

Action: replace with `AppColors.textPrimary(context)`.

#### D. `Colors.white38 / Colors.black38` for tertiary text
Pattern: `isDark ? Colors.white38 : Colors.black38` (≈10 sites in nasa_gallery, stargazing_forecast, observation_log).
Action: most should map to `AppColors.textTertiary(context)` (which is theme-aware).

#### E. Heavy bespoke dark-only screens (do NOT refactor)
- `lib/screens/home/orbital_mechanics_screen.dart` — uses `_bg`, `_card`, `_text` getters with bespoke colors (`0xFF030310`, `0xFF080820`, etc.). This is a **deliberate cockpit aesthetic** — leave alone.
- `lib/screens/home/space_stats_screen.dart` — same cockpit palette (`0xFF030310`, `0xFF7A8AB8`) — leave alone.
- `lib/screens/home/earth_from_space_screen.dart` — bespoke `_bg = 0xFF050510`, `_secondary = 0xFF9BA3B8` — editorial aesthetic. Leave.
- `lib/widgets/cockpit_painters.dart` and `lib/widgets/orbital_animations.dart` — paint logic with `cockpitAccent(isDark)`/`cockpitLive(isDark)`. Leave.

### Findings — `isDark ? AppColors.X : AppColors.Y` accent ternaries (≈20 sites)
Concentrated in `observation_log_screen.dart` (lines 944, 985, 1152-1166) and `add_observation_screen.dart` (lines 116, 462, 608-644). Pattern:
```dart
isDark ? AppColors.accentCyan : AppColors.accentBlue
isDark ? AppColors.accentGreen : AppColors.success
```
Add to `AppColors`:
```dart
static Color accent(BuildContext context) =>
    _isDark(context) ? accentCyan : accentBlue;
static Color successAccent(BuildContext context) =>
    _isDark(context) ? accentGreen : success;
```

### Proposed API additions to `lib/theme/app_colors.dart`
```dart
// Add inside the existing class:
static Color accent(BuildContext context) =>
    _isDark(context) ? accentCyan : accentBlue;

static Color successAccent(BuildContext context) =>
    _isDark(context) ? accentGreen : success;

// Optional convenience for the legacy '0xFF1A1A2E' near-black:
// (skip — textPrimary(ctx) already gives 0xFF0A1628 light, Colors.white dark)
```

If the team wants a `context.isDark` extension:
```dart
// lib/theme/build_context_theme_x.dart
import 'package:flutter/material.dart';
extension BuildContextThemeX on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
```

### Migration Plan
1. **Add `accent(context)` and `successAccent(context)`** to `app_colors.dart`. Replace ~20 ternaries.
2. **Delete `_kBgDark` / `_kCardDark`** in 4 files (`exoplanet_explorer`, `weather`, `research`, `active_missions`); use `AppColors.backgroundDark` / `AppColors.cardDark`.
3. **Replace inline `isDark ? const Color(0xFF141438) : Colors.white`** (12 sites) with `AppColors.card(context)`.
4. **Replace inline `isDark ? Colors.white : const Color(0xFF1A1A2E)`** (≈14 sites) with `AppColors.textPrimary(context)`.
5. **Replace `isDark ? Colors.white38 : Colors.black38`** (≈10 sites) with `AppColors.textTertiary(context)`.
6. Optionally introduce `context.isDarkMode` extension and migrate the 25 local `_isDark` getters.

### Risk: **MEDIUM**
- Card and text color values are *near*-duplicates, not exact. Replacing `0xFF141438` with `AppColors.cardDark` (`0xFF0A1E36`) will shift cards from a slightly purple-tinted to a slightly blue-tinted dark on those screens. Pixel diff likely; flag for design review.
- Tertiary `Colors.white38` (≈ 38% white) and `AppColors.textTertiaryDark` (`0xFF3A5470`) are not the same alpha model — visual diff possible.
- Prerequisite: any screen test (golden tests / screenshot tests) should be re-baselined.

### Lines saved estimate: **~120 lines** (mostly dropped local constants + ternary collapses)

---

## Area 6 — Error / Empty / Loading Widgets

### Findings — `ErrorState` patterns (≈12 inline implementations)

| File | Line | Icon | Title | CTA |
| --- | --- | --- | --- | --- |
| `lib/screens/home/home_screen.dart` | 895-923 | `CupertinoIcons.wifi_slash` (48) | "No internet connection" | CupertinoButton "Retry" — `_ErrorState` private class, **closest to canonical** |
| `lib/screens/launches/launches_screen.dart` | 237-261 | `CupertinoIcons.wifi_slash` (48) | "Couldn't load launches" | CupertinoButton "Retry" |
| `lib/screens/quick_actions/iss_tracker_screen.dart` | 735-775 | `CupertinoIcons.wifi_slash` (48) | "Could not fetch ISS data" | CupertinoButton "Retry" — wrapped in glass container |
| `lib/screens/quick_actions/asteroids_screen.dart` | 1127-1166 | `RealisticAsteroid` (140×140, cracked) | "Couldn't fetch asteroid data" | CupertinoButton "Retry" — bespoke icon |
| `lib/screens/stories/story_feed_screen.dart` | 395-419 | `CupertinoIcons.exclamationmark_triangle` (48) | "No stories found for ${cat}" | CupertinoButton "Retry" |
| `lib/screens/home/apod_archive_screen.dart` | 604-680 | `Icons.cloud_off_rounded` (48) | "Couldn't load this photo" | gradient + outline buttons "Try Yesterday" / "Retry" — bespoke 2-button |
| `lib/screens/explore/explore_screen.dart` | 1207-1300 | gradient circle + icon | "Couldn't load images" | (extended block) |

**Common shape**: `Icon(48, textSecondary) → SizedBox(16) → spaceGrotesk title (18, w600, textPrimary) → SizedBox(24) → CupertinoButton(accentBlue, "Retry")`.

### Findings — `EmptyState` patterns (≈8 inline implementations)

| File | Line | Icon/emoji | Title | Subtitle | CTA |
| --- | --- | --- | --- | --- | --- |
| `lib/screens/learn/space_glossary_screen.dart` | 437-453 | `Icons.search_off_rounded` (48) | `'No terms found for "$_query"'` | — | — |
| `lib/screens/launches/launches_screen.dart` | 263-280 | emoji `🔍/🚀/📋` (48) | "No matching/upcoming/past launches" | — | — |
| `lib/screens/research/space_research_screen.dart` | 874-890 | emoji `📄` (48) | "No papers found" | — | — |
| `lib/screens/explore/exoplanet_explorer_screen.dart` | 1329-1345 | emoji `🪐` (48) | "No planets match this filter" | — | — |
| `lib/screens/quick_actions/asteroids_screen.dart` | 1085-1124 | `RealisticAsteroid` (safe) | "No close approaches today 🌍" | "Earth is safe!" | — |
| `lib/screens/stories/story_feed_screen.dart` | 421-443 | `CupertinoIcons.doc_text` (48) | "No stories available" | — | "Refresh" |

**Common shape**: `Icon-or-emoji(48) → SizedBox(12-16) → spaceGrotesk title (16-18, w600/w700)` ± optional inter subtitle ± optional CTA.

### Findings — `LoadingState` patterns (≈9 sites)

| File | Line | Pattern |
| --- | --- | --- |
| `lib/screens/explore/wallpaper_preview_screen.dart` | 53 | `CupertinoActivityIndicator(color: Colors.white)` |
| `lib/screens/quick_actions/asteroid_detail_screen.dart` | 631 | `CupertinoActivityIndicator(...)` |
| `lib/screens/home/apod_detail_screen.dart` | 41 | `CupertinoActivityIndicator(...)` |
| `lib/screens/stories/story_feed_screen.dart` | 257 | `CupertinoActivityIndicator(color: AppColors.accentBlue)` |
| `lib/screens/home/earth_from_space_screen.dart` | 1076, 1368 | `CupertinoActivityIndicator(radius: 9)` + label "Loading Earth photos…" |
| `lib/screens/home/search_screen.dart` | 174 | `CupertinoActivityIndicator(...)` |
| `lib/screens/learn/space_sounds_screen.dart` | 314 | `CupertinoActivityIndicator()` |
| `lib/screens/quiz/quiz_play_screen.dart` | 328 | `CircularProgressIndicator(...)` |
| `lib/screens/quiz/quiz_results_screen.dart` | 199 | `CircularProgressIndicator(...)` |
| `lib/screens/explore/explore_screen.dart` | 1077 | `CircularProgressIndicator(...)` |
| `lib/screens/learn/learn_screen.dart` | 688 | `CircularProgressIndicator(...)` |
| `lib/screens/explore/solar_system_screen.dart` | 100 | `CircularProgressIndicator(...)` |
| `lib/screens/tools/stargazing_forecast_screen.dart` | 345 | `CircularProgressIndicator(...)` |
| `lib/screens/explore/nasa_gallery_screen.dart` | 327 | `CircularProgressIndicator(...)` |
| `lib/screens/explore/spacecraft_tracker_screen.dart` | 131 | `CircularProgressIndicator(...)` |
| `lib/screens/research/space_research_screen.dart` | 906 | `CircularProgressIndicator(...)` |

**Inconsistency**: 9 use `CupertinoActivityIndicator`, 8 use Material `CircularProgressIndicator`. Decide one (likely Cupertino, given the rest of the app's iOS-style tone).

### Proposed API — `lib/widgets/state_widgets/`
```dart
// state_widgets.dart (barrel)
export 'empty_state_widget.dart';
export 'error_state_widget.dart';
export 'loading_state_widget.dart';
```

```dart
// error_state_widget.dart
class ErrorStateWidget extends StatelessWidget {
  final IconData? icon;          // default: CupertinoIcons.wifi_slash
  final Widget? customIcon;      // for RealisticAsteroid etc.
  final String title;
  final String? subtitle;
  final String ctaLabel;         // default: 'Retry'
  final VoidCallback? onRetry;
  final List<({String label, VoidCallback onTap, bool primary})>? actions; // multi-button
  // ...
}

class EmptyStateWidget extends StatelessWidget {
  final IconData? icon;
  final String? emoji;           // emoji takes precedence if non-null
  final Widget? customIcon;
  final String title;
  final String? subtitle;
  final String? ctaLabel;
  final VoidCallback? onCta;
  // ...
}

class LoadingStateWidget extends StatelessWidget {
  final String? message;
  final double radius;           // default 12 (CupertinoActivityIndicator default)
  final Color? color;            // default AppColors.accent(context)
  // Always uses CupertinoActivityIndicator for consistency.
  // ...
}

class NetworkErrorWidget extends ErrorStateWidget {
  // Pre-configured with CupertinoIcons.wifi_slash + "No internet connection"
  const NetworkErrorWidget({required VoidCallback onRetry, super.key})
    : super(icon: CupertinoIcons.wifi_slash, title: 'No internet connection',
            subtitle: 'Check your connection and try again', onRetry: onRetry);
}
```

### Migration Plan
1. Create `lib/widgets/state_widgets/{empty,error,loading}_state_widget.dart` + barrel.
2. Replace inline error widgets in: `home_screen` (delete `_ErrorState`), `launches_screen`, `iss_tracker_screen`, `story_feed_screen`. Use the canonical form.
3. Keep `apod_archive_screen` 2-button error widget by passing `actions: [...]`.
4. Keep `asteroids_screen`'s bespoke `RealisticAsteroid` icon by passing `customIcon: RealisticAsteroid(...)`.
5. Replace `_buildEmptyState`, `_empty`, `_buildEmpty` in: `space_glossary_screen`, `launches_screen`, `space_research_screen`, `exoplanet_explorer_screen`, `story_feed_screen`.
6. Standardize loading: replace all `CircularProgressIndicator(...)` with `LoadingStateWidget()` (or pass-through `CupertinoActivityIndicator`). Decide one indicator type before starting.
7. Audit one inconsistency: `quiz_play_screen` and `quiz_results_screen` use Material `CircularProgressIndicator` — switch to Cupertino for app-wide consistency.

### Risk: **LOW**
- New widget additions are non-breaking; old call sites can be migrated incrementally.
- Visual diff: tightening the loading indicator from Material to Cupertino is a deliberate change.
- Should be done **after** Area 5 so the new widgets can use `AppColors.accent(context)` cleanly.

### Lines saved estimate: **~200 lines** (largest single area)

---

## Cross-Area Dependencies

| Area | Depends on | Reason |
| --- | --- | --- |
| Area 1 (Shimmer) | Area 5 (AppColors) | Already uses `AppColors.shimmerBase/Highlight` — just don't accidentally rename them. |
| Area 2 (Date) | none | Standalone util. |
| Area 3 (Number) | none | Standalone util. |
| Area 4 (Endpoints) | none | Pure constants. |
| Area 5 (Theme) | none | Foundation layer. |
| Area 6 (State widgets) | **Area 5** + **Area 2 (relative)** | New `LoadingStateWidget` should use `AppColors.accent(context)`; some empty states show "Updated 3m ago" (uses `DateFormatUtils.relative`). |

---

## Recommended Execution Order

1. **Area 4 — API Endpoints.** Lowest risk, removes 2 duplicate-fetch leaks (`apod_archive_screen.dart:81`, `space_stats_controller.dart:138`). Done first to reduce API drift.
2. **Area 5 — Theme helpers.** Add `accent()` and `successAccent()` to `AppColors`, delete the four `_kBgDark`/`_kCardDark` private constants, then replace the inline `0xFF141438` and `0xFF1A1A2E` ternaries. **Stop short** of touching the bespoke cockpit/editorial screens (orbital_mechanics, space_stats, earth_from_space).
3. **Area 2 — Date** + **Area 3 — Number** in parallel. Both are standalone util files; can be PR'd together.
4. **Area 1 — Shimmer.** After Area 5 confirms `AppColors.shimmer*` is the source of truth.
5. **Area 6 — State widgets.** Final pass; benefits from cleaned-up `AppColors` and the new `DateFormatUtils.relative`.

---

## Risks & Mitigation

| Risk | Mitigation |
| --- | --- |
| **Area 5 visual diff**: `0xFF141438` → `AppColors.cardDark` (`0xFF0A1E36`) shifts purple-tinted cards to blue-tinted. | Run `flutter analyze` (no warnings expected) and visually inspect the affected screens (explore, nasa_gallery, observation_log, stargazing_forecast) before/after. Optionally, add `cardDarkLegacy = 0xFF141438` if a reviewer disagrees with the change. |
| **Area 6 Material→Cupertino indicator switch** changes iconography. | Confirm with a design owner before standardizing; or keep the helper polymorphic (`useCupertino` flag, default true). |
| **Area 1 EPIC overlay shimmer** uses white-alpha intentionally because the hero is black; consolidating naively will make the shimmer invisible. | Expose `overlay: true` flag on `ShimmerBox`/`ShimmerCircle` (already in proposed API). |
| **Area 2 relative-time short-form mismatch** ("min" vs "m" vs "weeks" vs "w") — code currently inconsistent. | Pick one canonical short form ("3m / 2h / 5d / 3w / 2mo / 1y"); use `verbose: true` for the research screen which currently shows "5 days ago". |
| **Area 4 `apod_archive_screen.dart` retry counter** is screen-local. | Don't move the retry logic — only swap the URL string for `ApiEndpoints.apod(date: dateStr)`. |
| **Auto-imports** after a global find-replace can leave unused `package:intl/intl.dart` imports in screens that now route through the util. | Run `dart fix --apply` (or `flutter pub run dart_code_metrics:metrics check-unused-files`) after each area. |

---

## Confirmation Summary

- **Areas covered:** 6 / 6
- **Files inspected:** 25+ (all 17 shimmer call sites, 11 date sites, 80+ number sites, 50+ URL sites, 200+ isDark sites, 30+ state-widget sites)
- **Existing helpers preserved:** `AppColors` (extend, don't replace), `ApiKeys` (extend with `ApiEndpoints` sibling), `AppTextStyles` (untouched)
- **Files to be created:** 6 new files + ≈10 lines added to `app_colors.dart`
- **Total estimated savings:** **~580–650 lines net**, **~46 files** touched
- **Highest-impact single area:** Area 6 (state widgets) — ~200 lines, removes the most duplication
- **Lowest-risk first PR candidate:** Area 4 (URL constants) — pure extraction, fixes 2 latent leaks

> Audit complete. No source files were modified.
