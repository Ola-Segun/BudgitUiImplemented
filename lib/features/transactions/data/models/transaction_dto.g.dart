// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_dto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionDtoAdapter extends TypeAdapter<TransactionDto> {
  @override
  final int typeId = 0;

  @override
  TransactionDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionDto()
      ..id = fields[0] as String
      ..title = fields[1] as String
      ..amount = fields[2] as double
      ..type = fields[3] as String
      ..date = fields[4] as DateTime
      ..categoryId = fields[5] as String
      ..accountId = fields[6] as String?
      ..toAccountId = fields[7] as String?
      ..transferFee = fields[8] as double?
      ..description = fields[9] as String?
      ..receiptUrl = fields[10] as String?
      ..tags = (fields[11] as List?)?.cast<String>()
      ..currencyCode = fields[12] as String;
  }

  @override
  void write(BinaryWriter writer, TransactionDto obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.categoryId)
      ..writeByte(6)
      ..write(obj.accountId)
      ..writeByte(7)
      ..write(obj.toAccountId)
      ..writeByte(8)
      ..write(obj.transferFee)
      ..writeByte(9)
      ..write(obj.description)
      ..writeByte(10)
      ..write(obj.receiptUrl)
      ..writeByte(11)
      ..write(obj.tags)
      ..writeByte(12)
      ..write(obj.currencyCode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionCategoryDtoAdapter
    extends TypeAdapter<TransactionCategoryDto> {
  @override
  final int typeId = 1;

  @override
  TransactionCategoryDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionCategoryDto()
      ..id = fields[0] as String
      ..name = fields[1] as String
      ..icon = fields[2] as String
      ..color = fields[3] as int
      ..type = fields[4] as String
      ..isArchived = fields[5] as bool
      ..usageCount = fields[6] as int;
  }

  @override
  void write(BinaryWriter writer, TransactionCategoryDto obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.color)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.isArchived)
      ..writeByte(6)
      ..write(obj.usageCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionCategoryDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
