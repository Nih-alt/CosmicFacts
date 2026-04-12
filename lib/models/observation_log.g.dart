// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'observation_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ObservationLogAdapter extends TypeAdapter<ObservationLog> {
  @override
  final int typeId = 10;

  @override
  ObservationLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ObservationLog()
      ..id = fields[0] as String
      ..objectName = fields[1] as String
      ..objectType = fields[2] as String
      ..observedAt = fields[3] as DateTime
      ..notes = fields[4] as String
      ..rating = fields[5] as int
      ..equipment = fields[6] as String
      ..conditions = fields[7] as String
      ..location = fields[8] as String
      ..isVisible = fields[9] as bool;
  }

  @override
  void write(BinaryWriter writer, ObservationLog obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.objectName)
      ..writeByte(2)
      ..write(obj.objectType)
      ..writeByte(3)
      ..write(obj.observedAt)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.rating)
      ..writeByte(6)
      ..write(obj.equipment)
      ..writeByte(7)
      ..write(obj.conditions)
      ..writeByte(8)
      ..write(obj.location)
      ..writeByte(9)
      ..write(obj.isVisible);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ObservationLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
