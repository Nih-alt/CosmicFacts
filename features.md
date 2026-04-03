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

### 13. Earth from Space (NASA EPIC)
- Daily Earth photos from DSCOVR satellite
- EPIC camera at L1 Lagrange Point (1.5M km away)
- Uses epic.gsfc.nasa.gov direct API (no key needed)
- Thumbnail-first loading (fast), HD on demand
- Multiple photos per day (Earth rotation)
- Earth Rotation auto-play feature
- Date navigation through available dates
- Camera/satellite info section

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

### 36. Space Statistics Dashboard
- Age of Universe (real-time ticking counter)
- ISS Speed: 27,600 km/h
- ISS Altitude: 408 km
- People in Space: LIVE from API
- Asteroids Today: LIVE from NASA
- Moon Distance: calculated
- Earth-Sun Distance: calculated from orbit
- Known Exoplanets: 5,800+
- Observable Universe: 93 billion light-years
- Fun Comparisons section

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

---

*Last updated: April 2026*
*Developer: Nihal*
*GitHub: https://github.com/Nih-alt/CosmicFacts*

This file should be kept updated as new features are added. After every major change, update the relevant sections and changelog.
