import 'package:isar/isar.dart';

part 'badge_unlock.g.dart';

@Collection()
class BadgeUnlock {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String badgeKey;

  DateTime? unlockedAt;
  int progress = 0;
  int target = 1;
  String tier = 'bronze';
  String? metadataJson;
}
