import 'package:hive/hive.dart';

part 'observation_log.g.dart';

@HiveType(typeId: 10)
class ObservationLog extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String objectName;

  @HiveField(2)
  late String objectType;

  @HiveField(3)
  late DateTime observedAt;

  @HiveField(4)
  late String notes;

  @HiveField(5)
  late int rating;

  @HiveField(6)
  late String equipment;

  @HiveField(7)
  late String conditions;

  @HiveField(8)
  late String location;

  @HiveField(9)
  late bool isVisible;
}
