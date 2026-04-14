import 'package:isar/isar.dart';

part 'trophy_unlock.g.dart';

@Collection()
class TrophyUnlock {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String trophyKey;

  DateTime? unlockedAt;
  int progress = 0;
  int target = 1;
  String? metadataJson;
}
