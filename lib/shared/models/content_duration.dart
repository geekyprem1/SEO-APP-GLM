/// A target playback length for generated content.
///
/// [label] is shown in the UI; [promptHint] is threaded into the AI prompt so
/// the generated script matches the requested length. Available options depend
/// on the selected [ContentFormat] — see `DurationCatalog.forFormat`.
class ContentDuration {
  const ContentDuration({required this.label, required this.promptHint});

  final String label;
  final String promptHint;

  @override
  String toString() => label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContentDuration && other.label == label);

  @override
  int get hashCode => label.hashCode;
}
