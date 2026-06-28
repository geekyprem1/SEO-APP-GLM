import '../models/country.dart';

/// Curated country catalog (10 initial — easily extendable).
class CountryCatalog {
  CountryCatalog._();

  static const List<Country> all = [
    Country(code: 'IN', name: 'India'),
    Country(code: 'US', name: 'United States'),
    Country(code: 'GB', name: 'United Kingdom'),
    Country(code: 'CA', name: 'Canada'),
    Country(code: 'AU', name: 'Australia'),
    Country(code: 'DE', name: 'Germany'),
    Country(code: 'FR', name: 'France'),
    Country(code: 'BR', name: 'Brazil'),
    Country(code: 'ID', name: 'Indonesia'),
    Country(code: 'AE', name: 'UAE'),
  ];

  static Country get defaultCountry => all.first;
}
