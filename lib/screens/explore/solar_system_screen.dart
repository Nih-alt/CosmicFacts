import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class SolarSystemScreen extends StatefulWidget {
  const SolarSystemScreen({super.key});

  @override
  State<SolarSystemScreen> createState() => _SolarSystemScreenState();
}

class _SolarSystemScreenState extends State<SolarSystemScreen> {
  bool _isLoading = true;

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
      body: Stack(
        children: [
          // WebView
          InAppWebView(
            initialFile: 'assets/solar_system.html',
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              transparentBackground: true,
              disableHorizontalScroll: true,
              disableVerticalScroll: true,
              supportZoom: false,
              useHybridComposition: true,
              cacheEnabled: false,
              clearCache: true,
              clearSessionCache: true,
            ),
            onWebViewCreated: (controller) {
              controller.addJavaScriptHandler(
                handlerName: 'planetTapped',
                callback: (args) {
                  // Handler for JS planet tap events
                  return null;
                },
              );
              controller.addJavaScriptHandler(
                handlerName: 'goBack',
                callback: (args) {
                  Navigator.of(context).pop();
                  return null;
                },
              );
            },
            onLoadStop: (controller, url) {
              setState(() => _isLoading = false);
            },
            onReceivedError: (controller, request, error) {
              setState(() => _isLoading = false);
            },
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: const Color(0xFF000005),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF6C63FF),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading Solar System...',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),


        ],
      ),
    );
  }
}
