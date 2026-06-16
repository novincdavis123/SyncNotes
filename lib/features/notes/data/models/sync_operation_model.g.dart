// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_operation_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SyncOperationModelAdapter extends TypeAdapter<SyncOperationModel> {
  @override
  final int typeId = 10;

  @override
  SyncOperationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyncOperationModel(
      id: fields[0] as String,
      noteId: fields[1] as String,
      type: fields[2] as String,
      timestamp: fields[3] as DateTime,
      status: fields[4] as String,
      retryCount: (fields[5] as num).toInt(),
      lastTriedAt: fields[6] as DateTime?,
      isInProgress: fields[7] as bool,
      title: fields[8] as String,
      body: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SyncOperationModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.noteId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.retryCount)
      ..writeByte(6)
      ..write(obj.lastTriedAt)
      ..writeByte(7)
      ..write(obj.isInProgress)
      ..writeByte(8)
      ..write(obj.title)
      ..writeByte(9)
      ..write(obj.body);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncOperationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
