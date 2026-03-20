import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../data/quiz_questions.dart';

class QuizController extends GetxController {
  // ── State ──
  final currentQuestion = 0.obs;
  final score = 0.obs;
  final lives = 3.obs;
  final correctCount = 0.obs;
  final wrongCount = 0.obs;
  final answered = false.obs;
  final selectedAnswer = (-1).obs;
  final timeLeft = 10.obs;
  final lifelines = <bool>[true, true, true].obs; // 50:50, skip, +10s
  final hiddenOptions = <int>[].obs;
  final showExplanation = false.obs;

  late List<QuizQuestion> questions;
  late String mode; // daily, speed, topic, random

  Timer? _timer;
  late Box _statsBox;

  QuizQuestion get current => questions[currentQuestion.value];
  int get totalQuestions => questions.length;
  bool get isLastQuestion => currentQuestion.value >= totalQuestions - 1;
  bool get isSpeedMode => mode == 'speed';
  bool get hasLives => mode != 'speed' && mode != 'random';

  // ── Lifecycle ──

  Future<void> startQuiz(List<QuizQuestion> q, String m) async {
    questions = q;
    mode = m;
    currentQuestion.value = 0;
    score.value = 0;
    lives.value = 3;
    correctCount.value = 0;
    wrongCount.value = 0;
    answered.value = false;
    selectedAnswer.value = -1;
    timeLeft.value = 10;
    lifelines.value = [true, true, true];
    hiddenOptions.clear();
    showExplanation.value = false;

    _statsBox = await Hive.openBox('quiz_stats');

    if (isSpeedMode) {
      _startTimer();
    }
  }

  // ── Answer ──

  void selectAnswer(int index) {
    if (answered.value) return;
    answered.value = true;
    selectedAnswer.value = index;
    _stopTimer();

    final isCorrect = index == current.correctIndex;
    if (isCorrect) {
      correctCount.value++;
      int points = 10;
      if (current.difficulty == 'hard') points = 15;
      if (current.difficulty == 'easy') points = 5;
      score.value += points;
    } else {
      wrongCount.value++;
      if (hasLives) {
        lives.value--;
        HapticFeedback.heavyImpact();
      }
    }

    showExplanation.value = true;

    // Auto advance after delay
    Future.delayed(Duration(milliseconds: isCorrect ? 1500 : 2000), () {
      if (lives.value <= 0 && hasLives) {
        endQuiz();
      } else if (isLastQuestion) {
        endQuiz();
      } else {
        nextQuestion();
      }
    });
  }

  void _onTimeUp() {
    if (answered.value) return;
    // Treat time-up as wrong
    answered.value = true;
    selectedAnswer.value = -1;
    wrongCount.value++;
    showExplanation.value = true;

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (isLastQuestion) {
        endQuiz();
      } else {
        nextQuestion();
      }
    });
  }

  // ── Navigation ──

  void nextQuestion() {
    if (currentQuestion.value < totalQuestions - 1) {
      currentQuestion.value++;
      answered.value = false;
      selectedAnswer.value = -1;
      hiddenOptions.clear();
      showExplanation.value = false;

      if (isSpeedMode) {
        timeLeft.value = 10;
        _startTimer();
      }
    }
  }

  // ── Lifelines ──

  void useLifeline(int index) {
    if (!lifelines[index] || answered.value) return;

    switch (index) {
      case 0: // 50:50
        _useFiftyFifty();
        break;
      case 1: // Skip
        _useSkip();
        break;
      case 2: // +10s
        _useExtraTime();
        break;
    }
    lifelines[index] = false;
  }

  void _useFiftyFifty() {
    final correct = current.correctIndex;
    final wrongIndices = [0, 1, 2, 3]
        .where((i) => i != correct && !hiddenOptions.contains(i))
        .toList();
    wrongIndices.shuffle(Random());
    hiddenOptions.addAll(wrongIndices.take(2));
  }

  void _useSkip() {
    _stopTimer();
    if (isLastQuestion) {
      endQuiz();
    } else {
      nextQuestion();
    }
  }

  void _useExtraTime() {
    if (isSpeedMode) {
      timeLeft.value += 10;
    }
  }

  // ── Timer ──

  void _startTimer() {
    _stopTimer();
    timeLeft.value = 10;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft.value > 0) {
        timeLeft.value--;
      } else {
        _stopTimer();
        _onTimeUp();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  // ── End & Save ──

  void endQuiz() {
    _stopTimer();
    _saveResults();
    // Navigate to results — handled by the play screen
  }

  void _saveResults() {
    final totalQuizzes = _statsBox.get('totalQuizzes', defaultValue: 0) as int;
    final totalCorrect = _statsBox.get('totalCorrect', defaultValue: 0) as int;
    final totalWrong = _statsBox.get('totalWrong', defaultValue: 0) as int;
    final totalPoints = _statsBox.get('totalPoints', defaultValue: 0) as int;

    _statsBox.put('totalQuizzes', totalQuizzes + 1);
    _statsBox.put('totalCorrect', totalCorrect + correctCount.value);
    _statsBox.put('totalWrong', totalWrong + wrongCount.value);
    _statsBox.put('totalPoints', totalPoints + score.value);

    // Speed best
    if (mode == 'speed') {
      final best = _statsBox.get('speedBestScore', defaultValue: 0) as int;
      if (correctCount.value > best) {
        _statsBox.put('speedBestScore', correctCount.value);
      }
    }

    // Daily streak
    if (mode == 'daily') {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final lastDate = _statsBox.get('lastQuizDate', defaultValue: '') as String;

      _statsBox.put('dailyCompleted', true);
      _statsBox.put('lastQuizDate', today);

      // Check if consecutive
      if (lastDate.isNotEmpty) {
        final lastDt = DateTime.tryParse(lastDate);
        if (lastDt != null) {
          final diff = DateTime.now().difference(lastDt).inDays;
          if (diff == 1) {
            final streak = _statsBox.get('currentStreak', defaultValue: 0) as int;
            _statsBox.put('currentStreak', streak + 1);
            final best = _statsBox.get('bestStreak', defaultValue: 0) as int;
            if (streak + 1 > best) _statsBox.put('bestStreak', streak + 1);
          } else if (diff > 1) {
            _statsBox.put('currentStreak', 1);
          }
        }
      } else {
        _statsBox.put('currentStreak', 1);
      }

      // Bonus
      score.value += 20;
      _statsBox.put('totalPoints', (_statsBox.get('totalPoints', defaultValue: 0) as int) + 20);
    }
  }

  // ── Rank ──

  static String getRank(int points) {
    if (points > 1000) return '\u{1F52D} Cosmic Legend';
    if (points > 500) return '\u{1F30C} Galaxy Commander';
    if (points > 200) return '\u2B50 Star Navigator';
    if (points > 50) return '\u{1F680} Space Explorer';
    return '\u{1F331} Space Cadet';
  }

  static int getNextRankThreshold(int points) {
    if (points > 1000) return 2000;
    if (points > 500) return 1001;
    if (points > 200) return 501;
    if (points > 50) return 201;
    return 51;
  }

  static int getCurrentRankThreshold(int points) {
    if (points > 1000) return 1001;
    if (points > 500) return 501;
    if (points > 200) return 201;
    if (points > 50) return 51;
    return 0;
  }

  @override
  void onClose() {
    _stopTimer();
    super.onClose();
  }
}
