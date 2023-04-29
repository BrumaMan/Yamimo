// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_details.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MangaDetailsAdapter extends TypeAdapter<MangaDetails> {
  @override
  final int typeId = 1;

  @override
  MangaDetails read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MangaDetails(
      synopsis: fields[0] as String,
      type: fields[1] as String?,
      year: fields[2] as String,
      status: fields[3] as String,
      tags: (fields[4] as List?)?.cast<dynamic>(),
      author: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MangaDetails obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.synopsis)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.year)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.tags)
      ..writeByte(5)
      ..write(obj.author);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MangaDetailsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
