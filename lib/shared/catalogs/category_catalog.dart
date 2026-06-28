import '../models/category.dart';

/// Curated category catalog (17 initial — easily extendable).
class CategoryCatalog {
  CategoryCatalog._();

  static const List<Category> all = [
    Category(id: 'education', name: 'Education'),
    Category(id: 'gaming', name: 'Gaming'),
    Category(id: 'technology', name: 'Technology'),
    Category(id: 'ai', name: 'AI'),
    Category(id: 'motivation', name: 'Motivation'),
    Category(id: 'finance', name: 'Finance'),
    Category(id: 'business', name: 'Business'),
    Category(id: 'health', name: 'Health'),
    Category(id: 'fitness', name: 'Fitness'),
    Category(id: 'food', name: 'Food'),
    Category(id: 'travel', name: 'Travel'),
    Category(id: 'comedy', name: 'Comedy'),
    Category(id: 'religion', name: 'Religion'),
    Category(id: 'news', name: 'News'),
    Category(id: 'sports', name: 'Sports'),
    Category(id: 'entertainment', name: 'Entertainment'),
    Category(id: 'lifestyle', name: 'Lifestyle'),
  ];

  static Category get defaultCategory => all.first;
}
