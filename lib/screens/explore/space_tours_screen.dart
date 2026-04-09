import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class SpaceToursScreen extends StatefulWidget {
  const SpaceToursScreen({super.key});

  @override
  State<SpaceToursScreen> createState() => _SpaceToursScreenState();
}

class _SpaceToursScreenState extends State<SpaceToursScreen> {


  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: InAppWebView(
        initialFile: 'assets/space_tours.html',
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          transparentBackground: false,
          disableHorizontalScroll: true,
          disableVerticalScroll: true,
          supportZoom: false,
          useHybridComposition: true,
          cacheEnabled: false,
          clearCache: true,
        ),
        onWebViewCreated: (controller) {
          controller.addJavaScriptHandler(
            handlerName: 'goBack',
            callback: (_) => Navigator.of(context).pop(),
          );
        },
        onLoadStop: (controller, url) async {
          final isDark =
            Theme.of(context).brightness == Brightness.dark;
          await controller.evaluateJavascript(
            source:
              'setTheme(${isDark ? 'true' : 'false'});',
          );
        },
      ),
    );
  }
}
