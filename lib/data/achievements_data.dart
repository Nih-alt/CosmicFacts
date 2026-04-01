import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String category;
  final int requirement;
  final String requirementType;
  final Color color;
  final int points;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.requirement,
    required this.requirementType,
    required this.color,
    required this.points,
  });
}

const allAchievements = <Achievement>[
  // ══════════════════════════════════════
  // LEARNING BADGES (1-8)
  // ══════════════════════════════════════
  Achievement(
    id: 'first_lesson', name: '\u{1F4D6} First Steps',
    description: 'Complete your first lesson',
    icon: '\u{1F4D6}', category: 'Learning',
    requirement: 1, requirementType: 'lessons_completed',
    color: Color(0xFF7B5BFF), points: 10,
  ),
  Achievement(
    id: 'five_lessons', name: '\u{1F4DA} Bookworm',
    description: 'Complete 5 lessons',
    icon: '\u{1F4DA}', category: 'Learning',
    requirement: 5, requirementType: 'lessons_completed',
    color: Color(0xFF7B5BFF), points: 25,
  ),
  Achievement(
    id: 'ten_lessons', name: '\u{1F393} Scholar',
    description: 'Complete 10 lessons',
    icon: '\u{1F393}', category: 'Learning',
    requirement: 10, requirementType: 'lessons_completed',
    color: Color(0xFF7B5BFF), points: 50,
  ),
  Achievement(
    id: 'twenty_lessons', name: '\u{1F9D1}\u200D\u{1F52C} Scientist',
    description: 'Complete 20 lessons',
    icon: '\u{1F9D1}\u200D\u{1F52C}', category: 'Learning',
    requirement: 20, requirementType: 'lessons_completed',
    color: Color(0xFF7B5BFF), points: 100,
  ),
  Achievement(
    id: 'all_lessons', name: '\u{1F3C5} Professor',
    description: 'Complete all 84 lessons',
    icon: '\u{1F3C5}', category: 'Learning',
    requirement: 84, requirementType: 'lessons_completed',
    color: Color(0xFFFFD700), points: 500,
  ),
  Achievement(
    id: 'first_topic', name: '\u{1F3AF} Topic Master',
    description: 'Complete all lessons in one topic',
    icon: '\u{1F3AF}', category: 'Learning',
    requirement: 1, requirementType: 'topics_completed',
    color: Color(0xFF38BDF8), points: 75,
  ),
  Achievement(
    id: 'all_topics', name: '\u{1F31F} Space Encyclopedia',
    description: 'Complete all 12 topics',
    icon: '\u{1F31F}', category: 'Learning',
    requirement: 12, requirementType: 'topics_completed',
    color: Color(0xFFFFD700), points: 1000,
  ),
  Achievement(
    id: 'glossary_reader', name: '\u{1F4D6} Wordsmith',
    description: 'Read 50 glossary terms',
    icon: '\u{1F4D6}', category: 'Learning',
    requirement: 50, requirementType: 'glossary_read',
    color: Color(0xFFDAA520), points: 30,
  ),

  // ══════════════════════════════════════
  // QUIZ BADGES (9-16)
  // ══════════════════════════════════════
  Achievement(
    id: 'first_quiz', name: '\u{1F9E0} Quiz Rookie',
    description: 'Complete your first quiz',
    icon: '\u{1F9E0}', category: 'Quiz',
    requirement: 1, requirementType: 'quizzes_completed',
    color: Color(0xFFDAA520), points: 10,
  ),
  Achievement(
    id: 'ten_quizzes', name: '\u{1F4A1} Quiz Pro',
    description: 'Complete 10 quizzes',
    icon: '\u{1F4A1}', category: 'Quiz',
    requirement: 10, requirementType: 'quizzes_completed',
    color: Color(0xFFDAA520), points: 50,
  ),
  Achievement(
    id: 'perfect_score', name: '\u{1F4AF} Perfectionist',
    description: 'Get 100% on any quiz',
    icon: '\u{1F4AF}', category: 'Quiz',
    requirement: 1, requirementType: 'perfect_quizzes',
    color: Color(0xFFFFD700), points: 100,
  ),
  Achievement(
    id: 'speed_demon', name: '\u26A1 Speed Demon',
    description: 'Score 15+ in Speed Round',
    icon: '\u26A1', category: 'Quiz',
    requirement: 15, requirementType: 'speed_best',
    color: Color(0xFFFF6B35), points: 75,
  ),
  Achievement(
    id: 'daily_five', name: '\u{1F4C5} Committed',
    description: 'Complete 5 Daily Challenges',
    icon: '\u{1F4C5}', category: 'Quiz',
    requirement: 5, requirementType: 'daily_completed',
    color: Color(0xFF38BDF8), points: 50,
  ),
  Achievement(
    id: 'daily_thirty', name: '\u{1F5D3}\uFE0F Dedicated',
    description: 'Complete 30 Daily Challenges',
    icon: '\u{1F5D3}\uFE0F', category: 'Quiz',
    requirement: 30, requirementType: 'daily_completed',
    color: Color(0xFF38BDF8), points: 200,
  ),
  Achievement(
    id: 'quiz_master', name: '\u{1F3C6} Quiz Master',
    description: 'Answer 500 questions correctly',
    icon: '\u{1F3C6}', category: 'Quiz',
    requirement: 500, requirementType: 'total_correct',
    color: Color(0xFFFFD700), points: 300,
  ),
  Achievement(
    id: 'all_topics_quiz', name: '\u{1F393} Expert in All',
    description: 'Complete quiz for all topics',
    icon: '\u{1F393}', category: 'Quiz',
    requirement: 12, requirementType: 'topics_quizzed',
    color: Color(0xFF7B5BFF), points: 250,
  ),

  // ══════════════════════════════════════
  // EXPLORER BADGES (17-28)
  // ══════════════════════════════════════
  Achievement(
    id: 'first_article', name: '\u{1F4F0} News Reader',
    description: 'Read your first article',
    icon: '\u{1F4F0}', category: 'Explorer',
    requirement: 1, requirementType: 'articles_read',
    color: Color(0xFF4A90D9), points: 10,
  ),
  Achievement(
    id: 'twenty_articles', name: '\u{1F4F0} Informed',
    description: 'Read 20 articles',
    icon: '\u{1F4F0}', category: 'Explorer',
    requirement: 20, requirementType: 'articles_read',
    color: Color(0xFF4A90D9), points: 50,
  ),
  Achievement(
    id: 'apod_viewer', name: '\u{1F52D} Stargazer',
    description: 'View 10 APOD photos',
    icon: '\u{1F52D}', category: 'Explorer',
    requirement: 10, requirementType: 'apod_viewed',
    color: Color(0xFF00BFA5), points: 30,
  ),
  Achievement(
    id: 'explorer_nasa', name: '\u{1F6F0}\uFE0F Space Explorer',
    description: 'Browse 50 space images',
    icon: '\u{1F6F0}\uFE0F', category: 'Explorer',
    requirement: 50, requirementType: 'images_browsed',
    color: Color(0xFF1E88E5), points: 50,
  ),
  Achievement(
    id: 'wallpaper_setter', name: '\u{1F5BC}\uFE0F Decorator',
    description: 'Download a space wallpaper',
    icon: '\u{1F5BC}\uFE0F', category: 'Explorer',
    requirement: 1, requirementType: 'wallpapers_saved',
    color: Color(0xFFE040FB), points: 15,
  ),
  Achievement(
    id: 'iss_tracker', name: '\u{1F6F0}\uFE0F ISS Spotter',
    description: 'Check ISS location 5 times',
    icon: '\u{1F6F0}\uFE0F', category: 'Explorer',
    requirement: 5, requirementType: 'iss_checks',
    color: Color(0xFF00E096), points: 25,
  ),
  Achievement(
    id: 'asteroid_watcher', name: '\u2604\uFE0F Asteroid Hunter',
    description: 'Check near-Earth asteroids 5 times',
    icon: '\u2604\uFE0F', category: 'Explorer',
    requirement: 5, requirementType: 'asteroid_checks',
    color: Color(0xFFFF4D6A), points: 25,
  ),
  Achievement(
    id: 'moon_watcher', name: '\u{1F319} Lunar Observer',
    description: 'Check Moon phase 10 times',
    icon: '\u{1F319}', category: 'Explorer',
    requirement: 10, requirementType: 'moon_checks',
    color: Color(0xFFB0B0C0), points: 25,
  ),
  Achievement(
    id: 'sound_listener', name: '\u{1F50A} Cosmic Listener',
    description: 'Listen to 5 space sounds',
    icon: '\u{1F50A}', category: 'Explorer',
    requirement: 5, requirementType: 'sounds_played',
    color: Color(0xFF00BFA5), points: 25,
  ),
  Achievement(
    id: 'calculator_user', name: '\u{1F9EE} Math Wizard',
    description: 'Use all 8 space calculators',
    icon: '\u{1F9EE}', category: 'Explorer',
    requirement: 8, requirementType: 'calculators_used',
    color: Color(0xFF7B5BFF), points: 50,
  ),
  Achievement(
    id: 'comparator_user', name: '\u{1F4CA} Comparator',
    description: 'Compare 10 planet pairs',
    icon: '\u{1F4CA}', category: 'Explorer',
    requirement: 10, requirementType: 'comparisons_made',
    color: Color(0xFF38BDF8), points: 30,
  ),
  Achievement(
    id: 'timeline_reader', name: '\u231B Time Traveler',
    description: 'Read the complete Universe Timeline',
    icon: '\u231B', category: 'Explorer',
    requirement: 1, requirementType: 'timeline_completed',
    color: Color(0xFFFF6B35), points: 50,
  ),

  // ══════════════════════════════════════
  // STREAK BADGES (29-33)
  // ══════════════════════════════════════
  Achievement(
    id: 'streak_3', name: '\u{1F525} Warming Up',
    description: '3 day streak',
    icon: '\u{1F525}', category: 'Streak',
    requirement: 3, requirementType: 'max_streak',
    color: Color(0xFFFF6B35), points: 15,
  ),
  Achievement(
    id: 'streak_7', name: '\u{1F525} On Fire',
    description: '7 day streak',
    icon: '\u{1F525}', category: 'Streak',
    requirement: 7, requirementType: 'max_streak',
    color: Color(0xFFFF6B35), points: 50,
  ),
  Achievement(
    id: 'streak_14', name: '\u{1F525}\u{1F525} Unstoppable',
    description: '14 day streak',
    icon: '\u{1F525}\u{1F525}', category: 'Streak',
    requirement: 14, requirementType: 'max_streak',
    color: Color(0xFFFF4D6A), points: 100,
  ),
  Achievement(
    id: 'streak_30', name: '\u{1F525}\u{1F525}\u{1F525} Legendary',
    description: '30 day streak',
    icon: '\u{1F525}\u{1F525}\u{1F525}', category: 'Streak',
    requirement: 30, requirementType: 'max_streak',
    color: Color(0xFFFF4D6A), points: 250,
  ),
  Achievement(
    id: 'streak_100', name: '\u{1F48E} Diamond Streak',
    description: '100 day streak',
    icon: '\u{1F48E}', category: 'Streak',
    requirement: 100, requirementType: 'max_streak',
    color: Color(0xFF38BDF8), points: 1000,
  ),

  // ══════════════════════════════════════
  // SPECIAL BADGES (34-40)
  // ══════════════════════════════════════
  Achievement(
    id: 'first_bookmark', name: '\u2B50 Collector',
    description: 'Save your first bookmark',
    icon: '\u2B50', category: 'Special',
    requirement: 1, requirementType: 'bookmarks_saved',
    color: Color(0xFFFFD700), points: 10,
  ),
  Achievement(
    id: 'ten_bookmarks', name: '\u{1F4CC} Curator',
    description: 'Save 10 bookmarks',
    icon: '\u{1F4CC}', category: 'Special',
    requirement: 10, requirementType: 'bookmarks_saved',
    color: Color(0xFFFFD700), points: 30,
  ),
  Achievement(
    id: 'first_share', name: '\u{1F4E4} Ambassador',
    description: 'Share something from the app',
    icon: '\u{1F4E4}', category: 'Special',
    requirement: 1, requirementType: 'shares_made',
    color: Color(0xFF00E096), points: 10,
  ),
  Achievement(
    id: 'night_owl', name: '\u{1F989} Night Owl',
    description: 'Use the app between 12-4 AM',
    icon: '\u{1F989}', category: 'Special',
    requirement: 1, requirementType: 'night_usage',
    color: Color(0xFF5B3FBF), points: 20,
  ),
  Achievement(
    id: 'early_bird', name: '\u{1F426} Early Bird',
    description: 'Use the app before 6 AM',
    icon: '\u{1F426}', category: 'Special',
    requirement: 1, requirementType: 'early_usage',
    color: Color(0xFFFF9933), points: 20,
  ),
  Achievement(
    id: 'theme_switcher', name: '\u{1F3A8} Customizer',
    description: 'Switch between light and dark theme',
    icon: '\u{1F3A8}', category: 'Special',
    requirement: 1, requirementType: 'theme_switched',
    color: Color(0xFFE040FB), points: 10,
  ),
  Achievement(
    id: 'cosmic_legend', name: '\u{1F30C} Cosmic Legend',
    description: 'Earn 3000 total points',
    icon: '\u{1F30C}', category: 'Special',
    requirement: 3000, requirementType: 'total_points',
    color: Color(0xFFFFD700), points: 500,
  ),
];
