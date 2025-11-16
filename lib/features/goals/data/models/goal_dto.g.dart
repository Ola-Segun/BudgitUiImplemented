// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_dto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GoalDtoAdapter extends TypeAdapter<GoalDto> {
  @override
  final int typeId = 4;

  @override
  GoalDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GoalDto()
      ..id = fields[0] as String
      ..title = fields[1] as String
      ..description = fields[2] as String
      ..targetAmount = fields[3] as double
      ..currentAmount = fields[4] as double
      ..deadline = fields[5] as DateTime
      ..priority = fields[6] as String
      ..categoryId = fields[7] as String
      ..createdAt = fields[8] as DateTime
      ..updatedAt = fields[9] as DateTime
      ..tags = (fields[10] as List?)?.cast<String>()
      ..contributionIds = (fields[11] as List?)?.cast<String>();
  }

  @override
  void write(BinaryWriter writer, GoalDto obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.targetAmount)
      ..writeByte(4)
      ..write(obj.currentAmount)
      ..writeByte(5)
      ..write(obj.deadline)
      ..writeByte(6)
      ..write(obj.priority)
      ..writeByte(7)
      ..write(obj.categoryId)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt)
      ..writeByte(10)
      ..write(obj.tags)
      ..writeByte(11)
      ..write(obj.contributionIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
