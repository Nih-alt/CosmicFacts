class LaunchModel {
  final String id;
  final String name;
  final String status;
  final DateTime launchDate;
  final String provider;
  final String rocketName;
  final String missionName;
  final String padLocation;
  final String imageUrl;
  final String videoUrl;

  LaunchModel({
    required this.id,
    required this.name,
    required this.status,
    required this.launchDate,
    required this.provider,
    required this.rocketName,
    required this.missionName,
    required this.padLocation,
    required this.imageUrl,
    this.videoUrl = '',
  });

  /// Parse from Spaceflight News API, SpaceX API, or cache format.
  factory LaunchModel.fromJson(Map<String, dynamic> json) {
    final fullName = json['name']?.toString() ?? 'Unknown Launch';
    final parts = fullName.split('|');
    final rocket = parts.first.trim();
    final mission = parts.length > 1 ? parts.last.trim() : '';

    // status can be a Map (LL2 / SNAPI) or a plain String (cache/SpaceX)
    final rawStatus = json['status'];
    final status = rawStatus is Map
        ? (rawStatus['name']?.toString() ?? 'Unknown')
        : rawStatus?.toString() ?? 'Unknown';

    // provider can be a Map (LL2 / SNAPI) or a plain String (cache)
    final rawProvider = json['launch_service_provider'];
    final provider = rawProvider is Map
        ? (rawProvider['name']?.toString() ?? 'Unknown')
        : rawProvider?.toString() ?? 'Unknown';

    // pad → location → name
    final rawPad = json['pad'];
    String padLocation = '';
    if (rawPad is Map) {
      final loc = rawPad['location'];
      if (loc is Map) {
        padLocation = loc['name']?.toString() ?? '';
      }
    }

    // date
    final dateStr = json['net']?.toString() ??
        json['date_utc']?.toString() ??
        json['launchDate']?.toString() ??
        '';

    final resolvedRocket = json['rocketName']?.toString() ?? rocket;
    final resolvedMission = json['missionName']?.toString() ?? mission;

    // Infer provider from rocket name if unknown
    var resolvedProvider = provider;
    if (resolvedProvider.isEmpty || resolvedProvider == 'Unknown') {
      if (resolvedRocket.contains('Falcon') ||
          resolvedRocket.contains('Starship')) {
        resolvedProvider = 'SpaceX';
      } else if (resolvedRocket.contains('GSLV') ||
          resolvedRocket.contains('PSLV')) {
        resolvedProvider = 'ISRO';
      } else if (resolvedRocket.contains('SLS') ||
          resolvedRocket.contains('Atlas')) {
        resolvedProvider = 'NASA';
      } else if (resolvedRocket.contains('Ariane')) {
        resolvedProvider = 'Arianespace';
      } else if (resolvedRocket.contains('New Glenn')) {
        resolvedProvider = 'Blue Origin';
      } else {
        resolvedProvider = 'Space Agency';
      }
    }

    // Video URL — try links.webcast, links.youtube_id, or flat videoUrl
    final rawLinks = json['links'];
    String videoUrl = '';
    if (rawLinks is Map) {
      videoUrl = rawLinks['webcast']?.toString() ??
          rawLinks['youtube_id']?.toString() ??
          '';
    }
    if (videoUrl.isEmpty) {
      videoUrl = json['videoUrl']?.toString() ?? '';
    }

    return LaunchModel(
      id: json['id']?.toString() ?? '',
      name: fullName,
      status: status,
      launchDate: DateTime.tryParse(dateStr) ?? DateTime.now(),
      provider: resolvedProvider,
      rocketName: resolvedRocket,
      missionName: resolvedMission,
      padLocation: json['padLocation']?.toString() ?? padLocation,
      imageUrl:
          json['image']?.toString() ?? json['imageUrl']?.toString() ?? '',
      videoUrl: videoUrl,
    );
  }

  /// Flat JSON for Hive cache.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'status': status,
        'launchDate': launchDate.toIso8601String(),
        'provider': provider,
        'rocketName': rocketName,
        'missionName': missionName,
        'padLocation': padLocation,
        'imageUrl': imageUrl,
        'videoUrl': videoUrl,
      };

  bool get isSuccess => status.toLowerCase().contains('success');
  bool get isFailure => status.toLowerCase().contains('failure');
  bool get isPartial => status.toLowerCase().contains('partial');
}
