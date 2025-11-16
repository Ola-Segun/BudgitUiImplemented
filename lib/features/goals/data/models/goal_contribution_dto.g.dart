// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_contribution_dto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GoalContributionDtoAdapter extends TypeAdapter<GoalContributionDto> {
  @override
  final int typeId = 5;

  @override
  GoalContributionDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GoalContributionDto()
      ..id = fields[0] as String
      ..goalId = fields[1] as String
      ..amount = fields[2] as double
      ..date = fields[3] as DateTime
      ..transactionId = fields[4] as String?
      ..note = fields[5] as String?;
  }

  @override
  void write(BinaryWriter writer, GoalContributionDto obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.goalId)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.transactionId)
      ..writeByte(5)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalContributionDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
