import '../../features/store/data/models/product_model.dart';

/// Helper to sort and rank products by relevance to a search query.
class SearchRelevanceHelper {
  SearchRelevanceHelper._();

  /// Strips Arabic diacritics (Harakat / Tashkeel) using char codes without regex.
  static String _stripDiacritics(String text) {
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      final c = text.codeUnitAt(i);
      // Arabic diacritics unicode range (0x064B to 0x065F) and superscript Alef (0x0670)
      final isDiacritic = (c >= 0x064B && c <= 0x065F) || c == 0x0670;
      if (!isDiacritic) {
        buffer.writeCharCode(c);
      }
    }
    return buffer.toString();
  }

  /// Normalizes Arabic and English text for forgiving, accurate matching.
  static String normalize(String text) {
    var s = text.trim().toLowerCase();

    // Strip Arabic diacritics / Harakat
    s = _stripDiacritics(s);

    // Normalize Alef variations (أ, إ, آ, ٱ -> ا)
    s = s
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ٱ', 'ا');

    // Normalize Taa Marbouta (ة -> ه)
    s = s.replaceAll('ة', 'ه');

    // Normalize Alif Maqsura (ى -> ي)
    s = s.replaceAll('ى', 'ي');

    // Normalize common cosmetic transliteration variants
    s = s.replaceAll('سيروم', 'سيرم');
    s = s.replaceAll('ريتينول', 'ريتنول');

    return s;
  }

  /// Calculates a relevance score for a product given a search query.
  /// Higher score = more relevant.
  static int calculateScore(ProductModel product, String query) {
    final cleanQuery = normalize(query);
    if (cleanQuery.isEmpty) return 0;

    final name = normalize(product.name);
    final desc = product.description != null ? normalize(product.description!) : '';
    final category = product.category != null ? normalize(product.category!) : '';
    final subcategory = product.subcategory != null ? normalize(product.subcategory!) : '';

    int score = 0;

    // 1. Exact match in name (Highest priority)
    if (name == cleanQuery) {
      score += 1000;
    }
    // 2. Name starts with query
    else if (name.startsWith(cleanQuery)) {
      score += 700;
    }

    // 3. Name contains query as a whole standalone word
    final nameWords = name.split(' ').where((w) => w.isNotEmpty).toList();
    final queryWords = cleanQuery.split(' ').where((w) => w.isNotEmpty).toList();

    bool hasExactWordMatch = false;
    for (final word in nameWords) {
      if (word == cleanQuery) {
        hasExactWordMatch = true;
        break;
      }
    }
    if (hasExactWordMatch) {
      score += 500;
    } else if (name.contains(cleanQuery)) {
      // 4. Name contains query substring
      score += 350;
    }

    // Multi-word query matching in name
    if (queryWords.length > 1) {
      int matchedWords = 0;
      for (final qw in queryWords) {
        if (name.contains(qw)) matchedWords++;
      }
      if (matchedWords == queryWords.length) {
        score += 300;
      } else if (matchedWords > 0) {
        score += matchedWords * 60;
      }
    }

    // 5. Category or Subcategory matches query
    if (category.contains(cleanQuery) || subcategory.contains(cleanQuery)) {
      score += 150;
    }

    // 6. Description matches query (lower priority than name)
    if (desc.contains(cleanQuery)) {
      score += 50;
    }

    return score;
  }

  /// Sorts a list of products in-place by relevance to the query.
  static List<ProductModel> sortByRelevance(
    List<ProductModel> products,
    String query,
  ) {
    final trimmed = query.trim();
    if (trimmed.isEmpty || products.isEmpty) return products;

    final list = List<ProductModel>.from(products);
    list.sort((a, b) {
      final scoreA = calculateScore(a, trimmed);
      final scoreB = calculateScore(b, trimmed);
      return scoreB.compareTo(scoreA);
    });

    return list;
  }
}

