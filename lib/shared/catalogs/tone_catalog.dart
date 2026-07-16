import '../models/tone.dart';

/// Curated tone catalog (easily extendable).
class ToneCatalog {
  ToneCatalog._();

  static const List<Tone> all = [
    Tone(label: 'Casual', promptHint: 'casual and conversational'),
    Tone(label: 'Professional', promptHint: 'professional and polished'),
    Tone(label: 'Energetic', promptHint: 'high-energy, punchy and exciting'),
    Tone(label: 'Educational', promptHint: 'clear, informative and educational'),
    Tone(label: 'Funny', promptHint: 'light-hearted, humorous and playful'),
    Tone(label: 'Inspirational', promptHint: 'motivational and inspiring'),
  ];

  static Tone get defaultTone => all.first;

  /// Resolves a tone by its [label], falling back to the default.
  static Tone byLabel(String label) => all.firstWhere(
        (t) => t.label == label,
        orElse: () => defaultTone,
      );
}
