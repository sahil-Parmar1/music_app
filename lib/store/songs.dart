import 'package:hive_flutter/hive_flutter.dart';
part 'songs.g.dart';

@HiveType(typeId:0)
class Song extends HiveObject
{
  @HiveField(0)
  String? title;
  @HiveField(1)
  String? artist;
  @HiveField(2)
  String path;
  @HiveField(3)
  String? album;
  Song({
    this.album,
    this.artist,
    this.title,
    required this.path
  });
}