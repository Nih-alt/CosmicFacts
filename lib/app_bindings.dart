import 'package:get/get.dart';

import 'controllers/achievement_controller.dart';
import 'controllers/bookmark_controller.dart';
import 'controllers/explore_controller.dart';
import 'controllers/home_controller.dart';
import 'controllers/launches_controller.dart';
import 'controllers/orbital_mechanics_controller.dart';
import 'controllers/quiz_controller.dart';

/// Lazy GetX dependency registration.
///
/// Runs as `GetMaterialApp.initialBinding` — every controller is registered
/// as a factory and only constructed the first time it is accessed via
/// `Get.find` / `Get.put`. `fenix: true` lets fenix-managed controllers be
/// rebuilt after disposal so we never lose them.
///
/// `ThemeController` is intentionally NOT here: it is registered eagerly in
/// `main.dart` before `runApp` because the very first build reads the saved
/// theme mode from Hive to render the correct theme on frame 1.
class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController(), fenix: true);
    Get.lazyPut(() => ExploreController(), fenix: true);
    Get.lazyPut(() => LaunchesController(), fenix: true);
    Get.lazyPut(() => BookmarkController(), fenix: true);
    Get.lazyPut(() => AchievementController(), fenix: true);
    Get.lazyPut(() => QuizController(), fenix: true);
    Get.lazyPut(() => OrbitalMechanicsController(), fenix: true);
  }
}
