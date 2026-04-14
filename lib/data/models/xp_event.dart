import 'package:isar/isar.dart';

part 'xp_event.g.dart';

@Collection()
class XpEvent {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String eventKey;

  @Index()
  late String sourceType;

  late String sourceId;

  int baseXp = 0;
  int bonusXp = 0;
  double multiplier = 1.0;
  int totalAwardedXp = 0;

  late DateTime awardedAt;
  String? note;
}
