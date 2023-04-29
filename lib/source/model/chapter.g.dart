// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChapterAdapter extends TypeAdapter<Chapter> {
  @override
  final int typeId = 0;

  @override
  Chapter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Chapter(
      id: fields[0] as String,
      title: fields[1] as String,
      volume: fields[2] as String?,
      chapter: fields[3] as String?,
      pages: fields[4] as int?,
      url: fields[5] as String?,
      publishAt: fields[6] as String?,
      readableAt: fields[7] as String?,
      scanGroup: fields[8] as String?,
      officialScan: fields[9] as bool?,
      downloaded: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Chapter obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.volume)
      ..writeByte(3)
      ..write(obj.chapter)
      ..writeByte(4)
      ..write(obj.pages)
      ..writeByte(5)
      ..write(obj.url)
      ..writeByte(6)
      ..write(obj.publishAt)
      ..writeByte(7)
      ..write(obj.readableAt)
      ..writeByte(8)
      ..write(obj.scanGroup)
      ..writeByte(9)
      ..write(obj.officialScan)
      ..writeByte(10)
      ..write(obj.downloaded);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChapterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
