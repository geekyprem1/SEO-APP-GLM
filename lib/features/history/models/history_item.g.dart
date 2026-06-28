// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HistoryItemAdapter extends TypeAdapter<HistoryItem> {
  @override
  final int typeId = 1;

  @override
  HistoryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HistoryItem(
      id: fields[0] as String,
      type: fields[1] as HistoryType,
      displayTitle: fields[2] as String,
      data: (fields[3] as Map).cast<String, dynamic>(),
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, HistoryItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.displayTitle)
      ..writeByte(3)
      ..write(obj.data)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HistoryTypeAdapter extends TypeAdapter<HistoryType> {
  @override
  final int typeId = 0;

  @override
  HistoryType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HistoryType.title;
      case 1:
        return HistoryType.hashtag;
      case 2:
        return HistoryType.description;
      case 3:
        return HistoryType.content;
      case 4:
        return HistoryType.viralIdeas;
      case 5:
        return HistoryType.trending;
      case 6:
        return HistoryType.thumbnail;
      case 7:
        return HistoryType.seo;
      default:
        return HistoryType.title;
    }
  }

  @override
  void write(BinaryWriter writer, HistoryType obj) {
    switch (obj) {
      case HistoryType.title:
        writer.writeByte(0);
        break;
      case HistoryType.hashtag:
        writer.writeByte(1);
        break;
      case HistoryType.description:
        writer.writeByte(2);
        break;
      case HistoryType.content:
        writer.writeByte(3);
        break;
      case HistoryType.viralIdeas:
        writer.writeByte(4);
        break;
      case HistoryType.trending:
        writer.writeByte(5);
        break;
      case HistoryType.thumbnail:
        writer.writeByte(6);
        break;
      case HistoryType.seo:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
