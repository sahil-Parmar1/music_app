// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'songs.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SongAdapter extends TypeAdapter<Song> {
  @override
  final int typeId = 0;

  @override
  Song read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Song(
      album: fields[3] as String?,
      artist: fields[1] as String?,
      title: fields[0] as String?,
      Image: fields[4] as String?,
      publisher: fields[5] as String?,
      genre: fields[6] as String?,
      path: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Song obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.artist)
      ..writeByte(2)
      ..write(obj.path)
      ..writeByte(3)
      ..write(obj.album)
      ..writeByte(4)
      ..write(obj.Image)
      ..writeByte(5)
      ..write(obj.publisher)
      ..writeByte(6)
      ..write(obj.genre);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
