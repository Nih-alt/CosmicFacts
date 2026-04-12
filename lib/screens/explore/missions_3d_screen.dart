import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class Missions3DScreen extends StatefulWidget {
  const Missions3DScreen({super.key});

  @override
  State<Missions3DScreen> createState() => _Missions3DScreenState();
}

class _Missions3DScreenState extends State<Missions3DScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: InAppWebView(
        initialFile: 'assets/missions_3d.html',
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
            source: 'setTheme(${isDark ? 'true' : 'false'});',
          );
        },
      ),
    );
  }
}
