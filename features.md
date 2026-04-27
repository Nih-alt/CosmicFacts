# Cosmic Facts — Feature Documentation
### Your daily companion for space knowledge and discovery
### Version 1.0.0

---

## App Overview

| Detail | Value |
|--------|-------|
| App Name | Cosmic Facts |
| Package | com.cosmicfacts.app |
| Platform | Android |
| Min SDK | 24 (Android 7.0) |
| Target SDK | 36 (Android 16) |
| Flutter | 3.41.3 |
| Theme | Dark + Light (premium) |
| Offline Support | ~60% features work offline |
| Total Features | 50+ |

---

## Core Screens

### 1. Splash Screen
- Animated starfield background
- App logo + "EXPLORE THE UNIVERSE" tagline
- Gradient loading bar animation
- Auto-navigates to Home or Onboarding
- 6-second safety timeout (never gets stuck)
- Always dark theme

### 2. Onboarding
- 3-step introduction (Discover, Stay Updated, Interests)
- Glassmorphism interest selection cards (12 topics)
- Twinkling starfield animation
- Saves preferences to Hive
- Always dark theme

### 3. Home Screen
- NASA APOD (Astronomy Picture of the Day) hero card
- Quick Actions: ISS Tracker, Asteroids, Moon Phase, Events
- Space Stories section with live news
- Trending space facts
- "This Day in Space" section
- Quote of the Day card
- Full light/dark theme support

### 4. Bottom Navigation
- 5 tabs: Home, Explore, Launches, Learn, Profile
- Purple accent selected icon
- Theme-responsive colors

### 5. Profile Screen
- Avatar with gradient purple-cyan ring
- "Space Explorer" name + rank badge
- Stats: Articles Read, Lessons Done, Day Streak
- Your Journey timeline (milestones)
- Achievement badges section
- Preferences: Theme toggle (Dark/Auto/Light), Push Notifications, My Interests
- About: Rate, Share, Privacy Policy, About dialog
- Data: Clear Cache, Reset App
- "Made with love in India" footer

---

## News & Content

### 6. Story Feed (Instagram-style)
- Full-screen vertical swipe through stories
- Real news from Spaceflight News API
- Live article images with text overlay
- Like, Bookmark, Share buttons
- "Read Full Article" opens Article Detail
- Category filter pills: All, NASA, ISRO, SpaceX, ESA, Roscosmos
- Infinite scroll — loads more stories

### 7. Article Reader
- In-app article reading experience
- Full article image header
- Source info + publication date
- "Read Original Article" opens browser
- Share button (SharePlus)
- Bookmark toggle
- Dark/Light theme support

### 8. News Categories
- Filter stories by: All, NASA, ISRO, SpaceX, ESA, Roscosmos, Blue Origin, Rocket Lab, Missions, Science
- Uses Spaceflight News API search parameter
- Infinite scroll per category
- Category icon emojis

### 9. Space Quotes
- 100+ real quotes from scientists, astronauts, visionaries
- Quote of the Day (changes daily based on date)
- Categories: Exploration, Universe, Science, India, Humanity
- Share individual quotes
- Gradient hero card for daily quote
- Colored left border by category
- 100% offline

---

## Explore Section

### 10. NASA Images Grid
- 100,000+ NASA Image Library images
- 3-column masonry grid
- Search with debounce
- Category filters: All, Galaxies, Nebulae, Planets, Earth, Moon, Stars, Missions
- Image titles below tiles
- Infinite scroll pagination
- Dark/Light theme

### 11. Space Wallpapers
- HD space wallpapers from NASA
- 2-column grid (9:16 phone ratio)
- Category filters: All, Nebulae, Galaxies, Earth, Planets, Stars, Auroras
- Full-screen immersive preview
- "Download HD" saves to phone gallery
- Share functionality
- Infinite scroll

### 12. APOD Archive
- Browse any date's Astronomy Picture of the Day since June 16, 1995
- Date picker with left/right arrow navigation
- "Today" and "Random" quick buttons
- NASA timezone-aware (US Eastern to India adjustment)
- Auto-retry previous 3 days if current fails
- Pinch to zoom on images
- Video APOD support (opens YouTube)
- Full explanation text
- "Download HD" button

### 13. Earth from Space (NASA EPIC) — Editorial Cinema
Premium photo-magazine aesthetic over the same EPIC API. Inter typography
(no monospace except the small UTC stamp), no card wrappers, no big blue
buttons — built around a single full-bleed image and a magazine caption.

**Layout**
- Minimal 56 px top bar: back button + circular info "About EPIC" sheet.
- **Full-bleed hero** (60% of screen height, edge-to-edge, black backdrop):
  `InteractiveViewer` for pinch + double-tap zoom; long-press opens the
  rotation player; horizontal swipe navigates between dates; tap reveals
  ↤/↦ floating arrows that step through the day's frames before fading
  out after 2 s. Slim white bar markers along the bottom show position
  within the day's 19 frames.
- **Editorial caption block** — uppercase letter-spaced date "APRIL 25,
  2026", monospaced "00:41:06 UTC" timestamp, large 28 px / weight 300
  hero title "Earth from a million miles away", and a storytelling
  paragraph that converts numeric lat/lon to N/S/E/W form.
- **WATCH EARTH ROTATE** CTA — the only visually prominent button. 88 px
  card with a deep-blue → cyan gradient play disc, frame count subtitle.
- **Date navigation** — chevron pair around a tap-to-pick centered date
  (`CupertinoDatePicker`); next-day chevron disables when at today.
- **Technical details** — `AnimatedSize` collapsible row revealing
  Camera / Satellite / Position / Resolution / Distance + an inline
  "View full resolution →" link (replaces the old big blue button).
- **Sticky frosted action bar** — `BackdropFilter(ImageFilter.blur)` over
  semi-transparent surface, three icon-only actions (Save HD / Share /
  Save bookmark) reactive to `BookmarkController` via Obx.

**Rotation Player** (`earth_rotation_player_screen.dart`)
- Fullscreen immersive viewer (`SystemUiMode.immersive`) with PageView
  through all frames at mid-quality JPG.
- Auto-advance Timer at 800 ms / frame (1×), togglable to 2× and 4×.
- Tap toggles overlays; overlays auto-hide after 3 s of no interaction.
- Bottom progress line with 19 tap-jumpable vertical frame markers,
  large play/pause disc, and speed pill.
- Manual horizontal swipe pauses auto-play; vertical swipe-down past
  600 px/s exits the viewer. SystemChrome restored on dispose.

**Theme** — page bg `#050510` / `#FAFAFA`, deep-blue accent `#4A90E2`
(dark) / `#1E40AF` (light) — Earth-toned, not the cyan of Mission Control.
Image canvas always `Colors.black` for cinematic letterboxing.

**Preserved logic** — every API call (`getEpicAvailableDates`,
`getEpicImages`, `getEpicImageUrl`), the bookmark + share + Save HD
handlers, and the HD viewer subroute carry over unchanged. The hero +
player swap to mid-quality JPG via the documented EPIC URL pattern
(`/archive/natural/Y/M/D/jpg/<image>.jpg`) constructed inline so
`api_service.dart` stays untouched.

---

## Launches

### 14. Upcoming Launches
- Live countdown timer (ticks every second)
- Hero card with next launch countdown
- Data sources: SpaceX v5 API then Spaceflight News API then Hardcoded 2026
- Provider-colored badges (SpaceX, ISRO, NASA, etc.)
- Launch date, location, mission info
- Countdown pills: Days, Hours, Minutes, Seconds

### 15. Past Launches
- Completed launches with success/fail status
- Green "Success" badges
- Provider and location info
- Reverse chronological order

### 16. Launch Detail
- Gradient hero with stars background
- Live countdown (upcoming) or completion status (past)
- Provider, Date, Location, Status info rows
- "Watch on YouTube" button (launchUrl — Play Store safe)
- Share launch info
- Auto-transitions when countdown reaches zero

---

## Learn Hub

### 17. 84 Lessons across 12 Topics
- Black Holes (8), Galaxies (7), Stars & Supernovae (9), Planets (10)
- Moons (6), Asteroids & Comets (5), Telescopes & Missions (7)
- Space Exploration (8), Earth & Climate (6), Dark Matter & Energy (5)
- Big Bang & Universe (7), Exoplanets & Aliens (6)
- All content scientifically accurate, layman-friendly
- 150-200 words per lesson with Fun Fact callouts
- 100% offline — hardcoded content

### 18. Progress Tracking
- Lesson completion saved to Hive
- Topic cards show "3/8 completed" with progress bar
- Completed lessons show green checkmarks
- "Continue Learning" section for in-progress topics

### 19. Topic Detail + Lesson Reader
- Topic hero with gradient and emoji
- Numbered lesson list with reading time
- Medium-style article reading experience
- Fun Fact callout boxes (glassmorphism)
- "Next Lesson" button
- Auto-marks as read on open

---

## Quiz System

### 20. Quiz Hub
- Daily Challenge (5 questions, new every day)
- Streak system with fire emoji
- "Resets in X hours" countdown to midnight

### 21. Speed Round
- 20 questions, 10 seconds each
- Circular countdown timer (green to yellow to red)
- Best score tracking

### 22. Topic Expert
- Choose any topic
- 10 questions per topic
- Bottom sheet topic picker

### 23. Random Mix
- 15 random questions from all topics
- Mixed difficulty

### 24. Quiz Gameplay
- 200+ scientifically accurate questions
- 4 answer options (A, B, C, D)
- 3 lives system (hearts)
- Correct: green animation + "+10 pts"
- Wrong: red animation + correct answer shown
- Explanation after every answer
- Lifelines: 50:50 (removes 2), Skip, +10 seconds
- Smooth question transition animations

### 25. Rank System
- Space Cadet (0-50 pts)
- Space Explorer (51-200 pts)
- Star Navigator (201-500 pts)
- Galaxy Commander (501-1000 pts)
- Cosmic Legend (1000+ pts)
- Progress bar to next rank
- Rank shown on Profile

### 26. Quiz Results
- Score circle with gradient
- Correct/Wrong/Accuracy stats
- Points breakdown
- Rank progress update
- "Share Score" button
- "Play Again" option

---

## Tools & Reference

### 27. Space Calculator (8 tools)
- Weight on Planets (all 8 + Moon + Sun)
- Light Travel Time (preset distances)
- Escape Velocity (with comparisons)
- Planet Distance (travel time at different speeds)
- Size Comparator (CustomPainter circles)
- Time on Other Planets (age calculator)
- Temperature Converter (C/F/K + space presets)
- Telescope Calculator (magnification, visibility)
- All 100% offline — math only

### 28. Planet Comparator
- Side-by-side visual comparison
- 11 planets/bodies: 8 planets + Moon + Sun + Pluto
- CustomPainter proportional size circles
- 11 stats compared: Diameter, Mass, Distance, Orbital Period, Day Length, Gravity, Temperature, Moons, Rings, Atmosphere, Type
- Winner highlighted in green
- Fun comparison facts
- "Share Comparison" button

### 29. Space Glossary
- 157 space terms explained
- A-Z alphabetical index (right side quick jump)
- Categories: Astronomy, Physics, Cosmology, Technology, Biology
- Category color coding (cyan, purple, gold, green, pink)
- Expandable cards with full definitions
- Related terms as tappable chips
- Search with real-time filter
- 100% offline

### 30. Universe Timeline
- 34 events from Big Bang (13.8 BYA) to Present
- Interactive vertical timeline with alternating cards
- Era headers with gradient backgrounds:
  - The Beginning, First Stars & Galaxies, Our Solar System, Life on Earth, Human Space Age
- Quick jump buttons at top
- Expandable event cards with fun facts
- "You Are Here" ending
- 100% offline

### 31. Constellation Guide
- 30 major constellations
- CustomPainter star maps (stars + connection lines)
- Mythology stories for each
- Season filter: Winter, Spring, Summer, Autumn, Tonight
- Difficulty: Easy, Medium, Hard
- Hemisphere info (Northern, Southern, Both)
- Brightest star info
- Fun facts per constellation
- Detail screen with large animated star map
- "How to Find" tips
- Related constellations
- 100% offline

---

## Live Data (Quick Actions)

### 32. ISS Tracker
- Real-time ISS position (Open Notify API, 5s refresh)
- Radar-style visualization with pulsing dot
- Latitude/Longitude display
- ISS stats: speed, altitude, orbits/day
- Astronauts currently in space (real names, real count)
- LIVE indicator

### 33. Near-Earth Asteroids
- Today's asteroids from NASA NEO API
- Hazardous indicator (red warning or green safe)
- Size, distance, velocity for each
- Closest asteroid hero card
- Size comparison section (House/Football field/Eiffel Tower)
- 6-hour cache

### 34. Moon Phase
- Mathematical calculation (no API needed)
- CustomPainter moon visualization (lit/shadow)
- Phase name + illumination %
- 7-day lunar forecast
- Moon facts cards
- Next Full Moon / New Moon dates
- 100% offline

### 35. Space Events 2026
- 12 real astronomical events
- Past/Future badges with countdowns
- Event types: Eclipse, Meteor Shower, Planet, Solstice
- Color-coded by type

### 36. Space Statistics Dashboard — Mission Control Cockpit
NASA-inspired cockpit aesthetic with monospaced HUD typography (Space Mono),
HUD corner brackets ┌ ┐ └ ┘ on every panel, and a CRT cyan/green palette in
dark mode shifting to deep blue/purple in light mode.

**Live data sources**
- ISS telemetry — `wheretheiss.at/v1/satellites/25544` (velocity, altitude,
  lat/lon), refreshed every 15 s.
- People in space — `open-notify.org/astros.json`.
- Near-Earth asteroids today — NASA NEO Feed.
- Total confirmed exoplanets — NASA Exoplanet Archive TAP service
  (`pscomppars` count).
- Calculated: Moon distance (synodic phase), Earth–Sun distance (orbit).
- Static: Observable universe diameter (93B light-years).

**Layout**
- Top bar: "MISSION CONTROL" + STARDATE + pulsing ONLINE indicator.
- Scrolling marquee ticker bar — full-width 36 px CRT-style readout cycling
  through ISS velocity, altitude, lat/lon, exoplanet count, crew, NEO count,
  moon and sun ranges.
- Universe Age hero panel — real-time ticker advancing every 50 ms, formatted
  with comma separators and a 2-decimal CRT counter.
- ISS Live Telemetry panel — semicircular speedometer (`SpeedometerPainter`,
  0–30,000 km/h) on the left; vertical altimeter bar (`AltimeterBarPainter`,
  0–500 km) with lat/lon readout on the right; LIVE/CACHED badge.
- Instrument cluster (2-col grid): Crew in Orbit, NEO Tracked + animated
  radar sweep (`RadarSweepPainter`), Confirmed Exoplanets, Lunar Range,
  Solar Range, Observable Universe.
- Status legend: 🟢 LIVE / 🟡 CALC / ⚪ FIXED.
- Transmission Log (terminal panel): fun comparisons rendered as
  console lines (`> [HH:MM:SS] LABEL: …`).

**State**
- `SpaceStatsController` (GetX) with reactive `.obs` fields, two timers
  (50 ms age ticker, 15 s ISS refresh) and Hive-backed offline cache for
  crew, asteroid, and exoplanet counts.

**Theming** — fully theme-aware via `Theme.of(context).brightness`; no
hard-coded white backgrounds in dark mode.

### 36b. Orbital Mechanics Calculator — Mission Control Cockpit
Interactive astrodynamics playground sharing the Mission Control aesthetic
(Space Mono, HUD corner brackets, cyan/deep-blue accents). Four tabs:

- **🛰️ ORBIT** — circular orbital period & velocity for any altitude around
  Earth, Moon, Mars, Sun, or Jupiter. Sliders feed Kepler's third law:
  `T = 2π · √(r³/μ)`, `v = √(μ/r)`. Visual: dashed orbit with a satellite
  dot rotating around a colored body (`OrbitVisualPainter`).
- **🚀 ESCAPE** — surface escape velocity for Earth, Moon, Mars, Sun,
  Jupiter, Pluto. Shows km/s, km/h, and Mach (vs Earth sea-level sound).
  Visual: parabolic trajectory with animated dot + side gauge scaled to
  Earth-escape (`EscapeTrajectoryPainter`).
- **🌌 TRANSFER** — Hohmann transfer between any two heliocentric planets.
  Outputs Δv₁, Δv₂, total Δv, and one-way transfer days/years using the
  vis-viva equation. Visual: Sun-centred concentric orbits + dashed
  transfer ellipse with Sun at one focus, animated transit dot
  (`HohmannPainter`).
- **⚡ DILATION** — special-relativity time dilation. Sliders for v/c
  (0..0.999) and rest time (0.1..100 yr) drive `γ = 1/√(1−v²/c²)` and
  `Δt' = Δt·γ`. Visual: two clock faces side-by-side, the traveler's hand
  rotating at 1/γ the rate of the stationary one (`DualClockPainter`).

Shared UX:
- HUD top bar with FORMULAS eye toggle that reveals math + variable
  definitions in a green-CRT terminal panel under each calculator.
- Educational explanation paragraph under every tab.
- All inputs are `.obs` fields on `OrbitalMechanicsController`; results are
  `Obx`-reactive computed getters in km / km/s / s — no unit mixing.
- Animation controllers are screen-scoped and disposed in `dispose`.

Data lives in `lib/data/celestial_bodies.dart`: Sun, Mercury, Venus, Earth,
Moon, Mars, Jupiter, Saturn, Uranus, Neptune, Pluto with mass, radius,
gravitational parameter μ, and semi-major axis sourced from NASA fact sheets.

Sanity-checked against textbook values: ISS @ 408 km → 92.58 min / 7.668 km/s,
Earth escape → 11.186 km/s, Earth→Mars Hohmann → 5.591 km/s & 259 d,
γ(0.5c) = 1.155, γ(0.999c) = 22.37.

---

## Media

### 37. Space Sounds
- Real NASA audio recordings
- Categories: Planets, Black Holes, Stars, Spacecraft, Earth
- Audio player with play/pause
- "Now Playing" card with animated waveform
- Fallback: "Play on NASA.gov" if URL fails
- Category filter pills

---

## User Systems

### 38. Bookmarks
- Universal save system (articles, images, APOD, glossary)
- BookmarkController (GetX + Hive persistence)
- Type filter: All, Articles, Images, APOD, Glossary
- Swipe to delete
- Empty state with guidance
- Accessible from Profile + Learn screen

### 39. Achievement Badges
- 40 achievements across 5 categories
- Categories: Learning, Quiz, Explorer, Streak, Special
- Points system (10-1000 pts per badge)
- Progress tracking per achievement
- Unlocked: full color with glow
- Locked: greyscale with progress bar
- "Achievement Unlocked!" snackbar popup
- Total points displayed on Profile

### 40. Smart Notifications (Local)
- Daily Space Fact — 8 AM (30 rotating facts)
- APOD Alert — 7 AM
- Quiz Reminder — 8 PM
- Launch Alert — 1 hour + 15 min before launch
- Hazardous Asteroid Alert — when detected
- Space Event Alert — day before + day of event
- Streak Warning — evening if quiz not completed
- Configurable: individual toggle per notification type
- No server needed — schedules when app opens
- Checks every 6 hours (no battery drain)

### 41. Space Calendar
- Monthly calendar view
- Color-coded event dots per date
- Event types: Launch (purple), Eclipse (gold), Meteor (orange), Planet (blue), Moon (grey)
- Full Moon + New Moon dates for 2026
- All meteor shower peaks
- Solstice + Equinox dates
- Tap date to see events below
- Month navigation arrows

### 42. Astronaut Directory
- 50 notable astronauts
- Search by name, country, agency
- Filter by agency: NASA, ISRO, ESA, Roscosmos, CNSA, SpaceX
- Active/Retired status
- Flag emoji + country
- Famous mission + achievement
- Full bio expandable
- Stats: countries, total astronauts, currently active

### 43. Active Missions Tracker
- Complete active space missions screen with 20 real missions
- Two filter rows: by destination (Mars, Moon, Deep Space, Sun, Earth Orbit, En Route) and by agency (NASA, ISRO, ESA, CNSA, Multi-Agency)
- Hero card for Voyager 1 — farthest mission with pulsing signal animation
- Expandable mission cards with:
  - Key Discovery callout (purple card)
  - Current Activity card
  - Distance visualization bar (logarithmic scale — ISS to Voyager)
  - Visit Official Page button (url_launcher)
  - Launch year chip
- Sort bottom sheet: Distance, Launch Date, Agency, Name
- Dynamic mission count badge
- Added to Tools & Discovery section in Learn screen
- Play Store safe: agency names as text labels only, emoji flags, no official logos

### 44. Exoplanet Explorer
- Real data from NASA Exoplanet Archive TAP API (free, no key needed)
- Top 100 exoplanets fetched: radius, mass, orbital period, temperature, discovery year, method, distance
- Offline fallback: 10 hardcoded famous exoplanets (Kepler-452b, TRAPPIST-1e, etc.)
- Custom PlanetPainter (CustomPainter):
  - Radial gradient for 3D sphere effect
  - Specular highlight (top-left glint)
  - Dark limb shadow
  - Surface texture lines
  - Atmosphere glow for habitable zone planets
  - Ring system for Gas Giants and Hot Jupiters (radius > 8x Earth)
- Planet type classifier: Sub-Earth, Earth-like, Super Earth, Mini Neptune, Neptune-like, Gas Giant, Hot Jupiter
- Habitable zone detection (200K-320K temperature range)
- Hero card: Kepler-452b — "Most Earth-like" with habitable zone badge
- Search by planet name or star name
- Filter by planet type (7 types) and discovery method (Transit, Radial Velocity, Direct Imaging, Microlensing)
- Expandable card details:
  - 4 stat chips: radius, mass, orbital period, temperature
  - Size comparison bar vs Earth and Jupiter
  - Host star info with star type classification
  - Discovery year + method with one-liner explanation
  - Habitable zone status card (green/red/blue)
  - Distance context text
- Sort options: Most Earth-like, Closest, Largest, Hottest, Most Recent
- Added to Tools & Discovery section in Learn screen

### 45. Premium Topic Cards (Learn Screen)
- Each topic card now has unique gradient background based on topic
- Color themes per topic:
  - Black Holes: purple gradient + purple glow
  - Galaxies: deep blue gradient
  - Stars & Supernovae: amber/orange gradient
  - Planets: teal/green gradient
  - Moons: indigo gradient
  - Asteroids & Comets: cyan/teal gradient
  - Telescopes & Missions: cyan gradient
  - Space Exploration: blue gradient
  - Earth & Climate: lime green gradient
  - Dark Matter & Energy: indigo gradient
  - Big Bang & Universe: yellow gradient
  - Exoplanets & Aliens: pink/magenta gradient
- Decorative background icon (large, low opacity) per topic
- Star particle dots (decorative, dark mode only)
- Emoji wrapped in glowing accent container with rounded corners
- Accent colored dot before lesson count
- Thin linear progress bar at card bottom (always visible)
- Colored box shadow per topic accent color
- Premium border with accent color tint

---

## Settings & Technical

### 46. Light/Dark Theme
- Premium light theme: warm lavender #F8F7FC, white cards with purple shadows
- Deep space dark theme: #05051A, glassmorphism cards
- Instant toggle from Profile
- Persists across app restarts (Hive)
- Splash + Onboarding always dark
- Story feed always dark (immersive)
- All screens theme-responsive

### 47. 16KB Page Size Compliance
- AGP 8.11.1, Gradle 8.14, NDK r28
- compileSdk 36, targetSdk 36
- useLegacyPackaging = false
- Flutter 3.41.3 (16KB aligned engine)
- Mandatory for Play Store since Nov 2025

### 48. App Icon
- Custom designed purple planet with golden ring
- Deep space background with stars
- Adaptive icon with #0A0520 background
- Generated via flutter_launcher_icons

### 49. Offline Caching
- Hive local database
- Cache-first strategy: load from cache then refresh from API
- News: 30 min TTL
- APOD: 12 hr TTL
- Launches: 30 min TTL
- Asteroids: 6 hr TTL
- API calls: 8s timeout, 2 retries

### 50. Crash Protection
- Try-catch on all Hive operations
- Corrupted box auto-recovery
- 6-second splash safety timeout
- Fallback UI for HomeScreen errors
- Global FlutterError handler
- All GetX controllers permanent: true

---

## APIs Used (ALL FREE)

| API | Used For | Auth |
|-----|----------|------|
| NASA APOD | Astronomy Picture of the Day | API Key (free) |
| NASA NEO | Near-Earth Asteroids | API Key (free) |
| NASA Image Library | 100K+ space images | No key |
| NASA EPIC | Earth daily photos | No key (direct endpoint) |
| Spaceflight News API v4 | Space news articles | No key |
| SpaceX v5 API | Launch data | No key |
| Open Notify | ISS position + astronauts | No key |
| NASA Exoplanet Archive TAP | Exoplanet data (100 planets) | No key |

---

## Dependencies

| Package | Purpose |
|---------|---------|
| get | State management + navigation |
| hive + hive_flutter | Local database |
| http | API calls |
| cached_network_image | Image caching |
| google_fonts | Space Grotesk + Inter fonts |
| share_plus | Native share sheet |
| url_launcher | Open URLs in browser/YouTube |
| flutter_local_notifications | Scheduled notifications |
| timezone | Timezone handling |
| audioplayers | Space sounds playback |
| fl_chart | Charts and graphs |
| smooth_page_indicator | Page indicators |
| flutter_staggered_grid_view | Masonry grid |
| flutter_launcher_icons | App icon generation |

---

## Project Structure
```
lib/
├── main.dart
├── constants/
│   └── api_keys.dart
├── controllers/
│   ├── theme_controller.dart
│   ├── home_controller.dart
│   ├── explore_controller.dart
│   ├── launches_controller.dart
│   ├── quiz_controller.dart
│   ├── bookmark_controller.dart
│   └── achievement_controller.dart
├── data/
│   ├── learn_content.dart (84 lessons)
│   ├── quiz_questions.dart (200+ questions)
│   ├── glossary_data.dart (157 terms)
│   ├── planet_data.dart (11 bodies)
│   ├── space_sounds_data.dart
│   ├── space_quotes_data.dart (100+ quotes)
│   ├── constellation_data.dart (30 constellations)
│   ├── astronaut_data.dart (50 astronauts)
│   ├── calendar_events_data.dart
│   ├── achievements_data.dart (40 badges)
│   └── active_missions_data.dart (20 missions)
├── models/
│   └── bookmark_model.dart
├── services/
│   ├── api_service.dart
│   ├── cache_service.dart
│   ├── notification_service.dart
│   └── smart_notification_service.dart
├── theme/
│   ├── app_theme.dart
│   └── app_colors.dart
└── screens/
    ├── splash_screen.dart
    ├── onboarding/
    ├── home/
    │   ├── home_screen.dart
    │   ├── apod_archive_screen.dart
    │   ├── earth_from_space_screen.dart
    │   └── space_stats_screen.dart
    ├── stories/
    │   ├── story_feed_screen.dart
    │   └── article_detail_screen.dart
    ├── explore/
    │   ├── explore_screen.dart
    │   ├── image_detail_screen.dart
    │   ├── wallpapers_screen.dart
    │   ├── wallpaper_preview_screen.dart
    │   └── exoplanet_explorer_screen.dart
    ├── launches/
    │   ├── launches_screen.dart
    │   └── launch_detail_screen.dart
    ├── learn/
    │   ├── learn_screen.dart
    │   ├── topic_detail_screen.dart
    │   ├── lesson_screen.dart
    │   ├── space_calculator_screen.dart
    │   ├── planet_comparator_screen.dart
    │   ├── space_glossary_screen.dart
    │   ├── universe_timeline_screen.dart
    │   ├── constellation_guide_screen.dart
    │   ├── space_sounds_screen.dart
    │   ├── space_quotes_screen.dart
    │   ├── astronaut_directory_screen.dart
    │   └── active_missions_screen.dart
    ├── quiz/
    │   ├── quiz_hub_screen.dart
    │   ├── quiz_play_screen.dart
    │   └── quiz_results_screen.dart
    ├── quick_actions/
    │   ├── iss_tracker_screen.dart
    │   ├── asteroids_screen.dart
    │   ├── moon_phase_screen.dart
    │   ├── events_screen.dart
    │   └── space_calendar_screen.dart
    ├── bookmarks/
    │   └── bookmarks_screen.dart
    └── profile/
        ├── profile_screen.dart
        ├── achievements_screen.dart
        └── notification_settings_screen.dart
```

---

## Play Store Readiness

| Item | Status |
|------|--------|
| 16KB Page Size | Compliant |
| targetSdk 36 | Yes |
| App Name | "Cosmic Facts" |
| Package Name | com.cosmicfacts.app |
| App Icon | Custom designed |
| Privacy Policy | https://nih-alt.github.io/cosmic-facts-privacy/ |
| No YouTube WebView | Uses launchUrl only |
| No dangerous permissions | Yes |
| Agency Compliance | No official logos — emoji flags + text labels only |
| flutter analyze | 0 issues |
| AAB Build | 44.1 MB |
| Release Keystore | Needed before submission |
| Play Store Listing | Screenshots + descriptions needed |

---

## Recently Added

## 🪐 3D Solar System Explorer
- True 3D using Three.js (r128) via CDN inside flutter_inappwebview
- All 8 planets with real orbital speeds and sizes (logarithmic scale)
- Planet-specific details: Jupiter bands + Great Red Spot, Saturn rings,
  Earth continents + atmosphere, Mars polar caps, Uranus tilted rings
- 3000 stars background with varied colors (white/blue/yellow/orange)
- Sun with animated corona glow layers
- Drag to rotate, pinch to zoom, tap planet for info card
- Info card shows: diameter, day length, year, temperature, moons, distance
- Toggle: orbital lines, planet labels, animation speed slider
- Supports landscape + portrait mode
- Full immersive mode (system UI hidden)
- Files created: assets/solar_system.html,
  lib/screens/explore/solar_system_screen.dart
- Modified: explore_screen.dart, pubspec.yaml

## 🪐 3D Solar System — Full Visual Rewrite
- Sun: multi-layer corona glow, lens flare rays, animated bloom
- All 8 planets visible with proper scale + orbit distances
- Moon orbiting Earth with label
- HTML div labels — perfectly synced to planet screen positions
- Gas giants: multi-layer surface bands (Jupiter 7 bands, Saturn 6 bands)
- Jupiter Great Red Spot with inner eye detail
- Earth: continents, polar ice caps, atmosphere glow
- Mars: polar caps
- Saturn: 4-layer ring system with proper UV fix
- Uranus: tilted ring system
- ACES Filmic tone mapping for cinematic look
- Sun PointLight with shadow casting — real illumination on planets
- Pinch zoom, drag orbit, tap for info card
- Info card: mini painted planet icon + 6 stats
- goBack JS handler connected to Flutter Navigator
- Speed slider, orbit toggle, label toggle

## 🌟 AR Sky Map
- Real-time camera overlay with star, constellation and planet identification
- 90+ stars from hardcoded catalog with RA/Dec coordinates
- Proper astronomical math: Julian Date → GMST → LST → Hour Angle → Alt/Az
- 12 major constellations with connecting lines (Orion, Ursa Major, Scorpius etc.)
- 5 planets with simplified VSOP position calculation (Mercury, Venus, Mars, Jupiter, Saturn)
- Low-pass filter + azimuth smoothing for stable sensor readings
- Tap-to-identify: tap any star/planet → shows name, Bayer designation, magnitude, altitude, azimuth
- Compass rose (N/E/S/W) and horizon line overlay
- Camera fallback: static starfield background if camera unavailable
- Calibration screen with figure-8 instructions
- Toggle controls: Constellation Lines, Labels, Planets
- Play Store compliant: camera + location permissions with proper rationale
- Files created: star_catalog.dart, constellation_data.dart, astronomy_math.dart, ar_sky_map_screen.dart
- Placed as featured card in Explore screen

---

## Changelog

### v1.1.0 (April 2026)
- Active Missions Tracker: 20 real space missions with filters, hero card, expandable details
- Exoplanet Explorer: NASA Exoplanet Archive API, custom PlanetPainter, habitable zone detection
- Premium Topic Cards: unique gradient themes per topic, glowing icon containers, star particles
- Explore screen filter/sort bottom sheet (was non-functional)
- Total features: 50+

### v1.0.0 (March 2026)
- Initial release
- 47+ features
- 84 space lessons, 200+ quiz questions
- 157 glossary terms, 30 constellations
- 50 astronauts, 100+ quotes
- Live NASA APIs integration
- Light + Dark premium themes
- 16KB page size compliant
- Made with love in India

## Spacecraft Tracker — Section A (Earth Orbiters)
- Real-time ISS, Hubble, JWST tracking on 3D Earth globe
- TLE orbital data from CelesTrak (US government public domain, no API key)
- satellite.js (v4.0.0) via CDN for orbital propagation math
- Three.js (r128) via CDN for 3D rendering
- 3D Earth globe with painted continents + multi-layer atmosphere glow
- Custom 3D spacecraft models: ISS (truss + modules + 8 solar panels),
  Hubble (cylinder body + mirror dish + solar wings), JWST (7 hex mirrors + sunshield)
- Live data strip: altitude, speed, latitude, longitude, LIVE status
- Orbital path visualization (1 full orbit ahead, 90-point resolution)
- HTML div labels synced to 3D world positions via camera projection
- Flutter fetches TLE in parallel → injects into WebView via evaluateJavascript
- Fallback TLE data when offline (stale but functional for demo)
- Drag to rotate Earth, pinch to zoom, momentum-based inertia
- Tap spacecraft to select + show detailed info card (6 stats per craft)
- Spacecraft selector tabs with color-coded active states
- 3000-star background with varied star colors
- Immersive fullscreen mode
- Files: assets/spacecraft_tracker.html, lib/services/tle_service.dart,
  lib/screens/explore/spacecraft_tracker_screen.dart
- Modified: explore_screen.dart (entry card), pubspec.yaml (asset registration)

---

## ✨ UI Polish Pass — Complete

- **Theme consistency:** all 7 main screens already check `isDark` / use `AppColors.*` helper (815 calls across 25 screens, 0 deprecated `withOpacity` left)
- **Loading states:** shimmer placeholders present on all data-fetching screens (home, explore, launches, story feed, gallery)
- **Error states:** retry buttons wired through controllers (`hasError` / `loadTrendingImages` / `refreshData`)
- **Empty states:** friendly icon + message everywhere (gallery, search, launches)
- **Typography:** consistent `GoogleFonts.spaceGrotesk` (titles) / `GoogleFonts.inter` (body) usage across screens
- **Navigation:** `MaterialPageRoute` → `CupertinoPageRoute` migration in `explore_screen.dart` (5x) and `nasa_gallery_screen.dart` (1x) for native iOS swipe-back feel
- **Bottom sheets:** all modal sheets in target screens already wrapped in `Material(color: Colors.transparent)`
- **Section headers:** accent gradient bars (4×18px purple→cyan) used in JWST, Interactive Experiences, Space Image Gallery sections
- **Card shadows:** light-mode depth via `AppColors.cardShadow(context)` helper
- **Performance — `cacheExtent: 500`** added to:
  - `home_screen.dart` CustomScrollView
  - `explore_screen.dart` CustomScrollView
  - `learn_screen.dart` CustomScrollView
  - `launches_screen.dart` ListView.builder
  - `nasa_gallery_screen.dart` MasonryGridView
- **Performance — `memCacheWidth`** added to:
  - `explore_screen.dart` masonry tiles (400) + JWST PageView cards (700)
  - `nasa_gallery_screen.dart` gallery tiles (400)
  - `home_screen.dart` APOD hero (800) + trending fact cards (600)
  - `launches_screen.dart` launch background (700)
  - `story_feed_screen.dart` full-bleed article image (800)
- **SafeArea:** verified on every target screen (top-only on tabbed screens to avoid bottom-nav double-padding)
- **`flutter analyze`:** 0 issues before, 0 issues after

## 🔭 AR Sky Map — Scientific Grid Overlays

- **Equatorial grid:** RA meridians every 2 hours + Dec parallels every 30° — drawn in cyan, with 0h/2h/4h… labels along the celestial equator
- **Azimuthal grid:** altitude almucantars at 0°/30°/60° + azimuth meridians every 45° — drawn in green, with N/NE/E/SE/S/SW/W/NW cardinal labels
- **Ecliptic line:** the Sun's annual path computed parametrically as `dec = 23.4° × sin(RA)` — drawn in gold/yellow with an "Ecliptic" label
- All 3 grids toggle independently and have their own accent color
- Bottom bar reorganized into 2 rows separated by a thin divider:
  - **Row 1:** Lines / Labels / Planets (existing functionality preserved)
  - **Row 2:** Ecliptic / Eq.Grid / Az.Grid (new)
- Toggle pills are now horizontal pill-style with icon + label and per-toggle accent color
- `_SkyOverlayPainter.shouldRepaint` now also tracks the new bools so toggling updates the canvas immediately even when sensor data hasn't changed

---

## 🔭 Stargazing Visibility Forecast

- Overall stargazing score 0–100, displayed as a hero card with color-coded grade (Excellent → Very Poor)
- 3 weighted components:
  - **Weather (40 pts)** — average cloud cover for 19:00–05:00 local, with humidity penalty
  - **Moon (30 pts)** — illumination % from a date-based lunar phase calculation
  - **Light pollution (30 pts)** — Bortle scale (1–9) from nearest known city
- Cloud cover from **Open-Meteo API** — fully open data, no API key, no quota
- Hourly tonight forecast strip (7 PM → 5 AM) with cloud-tier emoji + percentage
- Best observing window detection — finds the clearest hour automatically
- "What to Observe Tonight" guide adapts to score (planets/clusters/Milky Way at high scores; bright planets/Moon/brightest stars at low scores)
- Light pollution panel with Bortle label, description, and "drive 30–40 km out" tip when Bortle ≥ 6
- Light + dark theme support throughout
- Reuses existing `geolocator` package — no new dependencies
- **Files created:**
  - `lib/screens/tools/stargazing_forecast_screen.dart`
  - `lib/services/weather_service.dart`
  - `lib/data/light_pollution_data.dart` (40+ cities — full India coverage + major world cities + dark-sky destinations)
- **Files modified:** `lib/screens/learn/learn_screen.dart` (added entry to `_toolData` + `screens` list in Tools & Discovery row)

---

## ✨ UI Surgical Polish — Round 2

- **Section headers — accent gradient bars** (4×20px purple→cyan) added to:
  - `home_screen.dart`: "Trending Facts 🔥", "This Day in Space 📅", "Quote of the Day ✨"
  - `learn_screen.dart`: "Tools & Discovery", "Continue Learning", "Topics"
  - `profile_screen.dart`: "Preferences", "About", "Data" (via shared `_buildSection` builder — single edit covers all 3)
  - All headers use `letterSpacing: -0.3` for tighter premium look
- **Light-mode card gradient + purple shadow** added to:
  - `_QuoteOfDayCard` in `home_screen.dart`
  - `_TodayInSpaceCard` in `home_screen.dart` (wrapped in `Builder` to access `isDark` since the card was a `const StatelessWidget` with no theme access)
  - Trending facts tiles intentionally skipped — they use `BackdropFilter` glass effect by design
  - APOD card and image cards skipped per spec
- **Bottom nav bar premium shadow** — wrapped existing `CupertinoTabBar` in `Container` with light-mode `BoxShadow(blurRadius: 20, offset: -4)` (top border via `AppColors.divider` was already present)
- **Profile avatar** — replaced 3-ring nested person-icon avatar with single 92px gradient circle (purple→cyan) + 🚀 emoji + purple glow shadow per spec
- **Spacing** — bumped section header top padding from 20→24 in home_screen.dart between major sections; bottom padding from 8/10→12 between header and content
- **Daily facts rotation** — verified `_getDailyFacts` at home_screen.dart:943 already uses date-seeded `Random(today.year*10000 + today.month*100 + today.day)`. ✓
- **`flutter analyze`:** 0 issues before, 0 issues after

---

### Items intentionally NOT changed in this pass

These would require visual judgment / design approval and are deferred to a separate prompt:
- Hardcoded color → `isDark` ternary refactor: not needed — codebase already uses centralized `AppColors` helper
- Typography scale rewrite: risk of visual regression across 6300+ lines; current scale is consistent
- "Premium gradient overlays" on cards: design change, needs approval
- `WillPopScope`/`PopScope` wrappers on sub-screens: not needed for plain Navigator pops
- `setState` audit for unnecessary rebuilds: requires per-screen profiling

---

## 🛸 Historic Missions 3D Explorer
- 7 iconic spacecraft: Voyager 1&2, Perseverance,
  Curiosity, Cassini, Apollo LM, New Horizons
- All models built with Three.js geometry —
  no copyrighted assets
- Drag to rotate model, pinch to zoom
- Auto-rotation toggle
- Mission stats strip: launched/distance/status
- Info card: description, 4 stats, key achievement
- Accent color per mission
- Light/dark theme via setTheme()
- Landscape support
- Fixed zoom button visibility and chip scroll
- Repositioned zoom controls to right-center to avoid info panel overlap
- 10 missions total, all using genuine NASA 3D Resources GLB models. Added: Hubble, JWST, Cassini, Space Shuttle, NEAR Shoemaker, Chandra X-ray Observatory, EVA Space Suit. Removed procedural: Curiosity, New Horizons. Models hosted: github.com/Nih-alt/cosmic-facts-3d-models
- Fixed: 3D models now rotate in all directions (horizontal + vertical drag)
- Files created: assets/missions_3d.html,
  lib/screens/explore/missions_3d_screen.dart

*Last updated: April 2026*
*Developer: Nihal*
*GitHub: https://github.com/Nih-alt/CosmicFacts*

This file should be kept updated as new features are added. After every major change, update the relevant sections and changelog.

## Sky Observation Log
- Personal diary for logging stargazing sessions
- Fields: object name, type, date/time, rating (1-5), equipment, sky conditions, location, notes
- 8 object types: Planet, Star, Nebula, Galaxy, Constellation, Meteor, Comet, Other
- Filter by object type + sort by date/rating
- Full detail bottom sheet per observation
- Swipe to delete (with confirm dialog)
- Empty state with CTA to add first observation
- Hive offline storage â€” no internet needed
- Both light and dark theme throughout
- Accessible from Profile screen
- Files created: observation_log.dart, observation_log_screen.dart, add_observation_screen.dart
