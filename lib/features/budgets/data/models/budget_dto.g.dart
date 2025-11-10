// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_dto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BudgetDtoAdapter extends TypeAdapter<BudgetDto> {
  @override
  final int typeId = 13;

  @override
  BudgetDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BudgetDto(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as String,
      startDate: fields[3] as int,
      endDate: fields[4] as int,
      createdAt: fields[5] as int,
      categories: (fields[6] as List).cast<BudgetCategoryDto>(),
      description: fields[7] as String?,
      isActive: fields[8] as bool,
      allowRollover: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, BudgetDto obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.startDate)
      ..writeByte(4)
      ..write(obj.endDate)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.categories)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.isActive)
      ..writeByte(9)
      ..write(obj.allowRollover);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BudgetCategoryDtoAdapter extends TypeAdapter<BudgetCategoryDto> {
  @override
  final int typeId = 3;

  @override
  BudgetCategoryDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BudgetCategoryDto(
      id: fields[0] as String,
      name: fields[1] as String,
      amount: fields[2] as double,
      description: fields[3] as String?,
      icon: fields[4] as String?,
      color: fields[5] as int?,
      subcategories: (fields[6] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, BudgetCategoryDto obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.icon)
      ..writeByte(5)
      ..write(obj.color)
      ..writeByte(6)
      ..write(obj.subcategories);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetCategoryDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
