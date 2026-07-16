/// A presentation style (voice) for generated content.
///
/// [label] is shown in the UI; [promptHint] is a short phrase threaded into
/// the AI prompt so the generated copy adopts the requested voice.
class Tone {
  const Tone({required this.label, required this.promptHint});

  final String label;
  final String promptHint;

  @override
  String toString() => label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Tone && other.label == label);

  @override
  int get hashCode => label.hashCode;
}
