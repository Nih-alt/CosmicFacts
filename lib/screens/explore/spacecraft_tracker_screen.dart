import 'dart:async' show unawaited;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../services/analytics_service.dart';
import '../../services/tle_service.dart';

class SpacecraftTrackerScreen extends StatefulWidget {
  const SpacecraftTrackerScreen({super.key});

  @override
  State<SpacecraftTrackerScreen> createState() =>
      _SpacecraftTrackerScreenState();
}

class _SpacecraftTrackerScreenState extends State<SpacecraftTrackerScreen> {
  InAppWebViewController? _webController;
  bool _webReady = false;
  bool _tleLoaded = false;
  String? _pendingTleJson;

  @override
  void initState() {
    super.initState();
    unawaited(AnalyticsService.logFeatureUsed('iss_tracker'));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _fetchAndInjectTle();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _fetchAndInjectTle() async {
    final tleMap = await TleService.fetchAllTles();

    final tleJson = jsonEncode({
      'ISS': tleMap['ISS'] != null
          ? {'line1': tleMap['ISS']!['line1'], 'line2': tleMap['ISS']!['line2']}
          : null,
      'Hubble': tleMap['Hubble'] != null
          ? {
              'line1': tleMap['Hubble']!['line1'],
              'line2': tleMap['Hubble']!['line2'],
            }
          : null,
      'JWST': tleMap['JWST'] != null
          ? {
              'line1': tleMap['JWST']!['line1'],
              'line2': tleMap['JWST']!['line2'],
            }
          : null,
    });

    if (!mounted) return;
    setState(() => _tleLoaded = true);

    if (_webReady && _webController != null) {
      await _injectTle(tleJson);
    } else {
      _pendingTleJson = tleJson;
    }
  }

  Future<void> _injectTle(String tleJson) async {
    if (_webController == null) return;
    final escaped = tleJson.replaceAll("'", "\\'");
    await _webController!.evaluateJavascript(
      source: "initWithTle('$escaped');",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          InAppWebView(
            initialFile: 'assets/spacecraft_tracker.html',
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
              _webController = controller;
              controller.addJavaScriptHandler(
                handlerName: 'goBack',
                callback: (_) => Navigator.of(context).pop(),
              );
            },
            onLoadStop: (controller, url) async {
              _webReady = true;

              // Inject theme first
              final isDark =
                  Theme.of(context).brightness == Brightness.dark;
              await controller.evaluateJavascript(
                source: 'setTheme(${isDark ? 'true' : 'false'});',
              );

              // Then inject TLE
              if (_pendingTleJson != null) {
                await Future.delayed(const Duration(milliseconds: 300));
                await _injectTle(_pendingTleJson!);
                _pendingTleJson = null;
              }
            },
          ),
          if (!_tleLoaded)
            Container(
              color: const Color(0xFF000008),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF6C63FF),
                      ),
                    ),
                    SizedBox(height: 14),
                    Text(
                      'Fetching orbital data...',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
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
