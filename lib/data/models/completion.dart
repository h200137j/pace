import 'package:isar/isar.dart';

part 'completion.g.dart';

/// Records that a specific activity was completed on a specific date.
@Collection()
class Completion {
  Id id = Isar.autoIncrement;

  /// Foreign key to [Activity].
  @Index()
  late int activityId;

  /// ISO date string `yyyy-MM-dd` — the day this completion applies to.
  @Index(composite: [CompositeIndex('activityId')], unique: true)
  late String dateKey;

  /// When the user actually tapped "done".
  late DateTime completedAt;

  /// Optional local path to an uploaded photo.
  String? photoPath;

  /// Optional free-text note for the session.
  String? note;
}
