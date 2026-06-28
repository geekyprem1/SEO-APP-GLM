import '../models/language.dart';

/// Curated language catalog (8 initial — easily extendable).
class LanguageCatalog {
  LanguageCatalog._();

  static const List<Language> all = [
    Language(code: 'en', name: 'English'),
    Language(code: 'hi', name: 'Hindi'),
    Language(code: 'es', name: 'Spanish'),
    Language(code: 'pt', name: 'Portuguese'),
    Language(code: 'fr', name: 'French'),
    Language(code: 'de', name: 'German'),
    Language(code: 'ar', name: 'Arabic'),
    Language(code: 'id', name: 'Indonesian'),
  ];

  static Language get defaultLanguage => all.first;
}
