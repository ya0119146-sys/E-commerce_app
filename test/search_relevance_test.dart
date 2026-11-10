import 'package:flutter_test/flutter_test.dart';
import 'package:e_commerce/core/utils/search_relevance_helper.dart';
import 'package:e_commerce/features/store/data/models/product_model.dart';

void main() {
  group('SearchRelevanceHelper - Relevance Ranking & Normalization', () {
    test('Arabic normalization normalizes Alef, Taa Marbouta, Yaa, and diacritics', () {
      expect(SearchRelevanceHelper.normalize('أَحْمَد'), equals('احمد'));
      expect(SearchRelevanceHelper.normalize('عنايةٌ بالبشرةِ'), equals('عنايه بالبشره'));
      expect(SearchRelevanceHelper.normalize('سيروم'), equals('سيرم'));
      expect(SearchRelevanceHelper.normalize('ريتينول'), equals('ريتنول'));
    });

    test('Prioritizes products whose name matches over description-only matches', () {
      const hairProduct = ProductModel(
        id: 'p1',
        name: 'روتين الشعر الكيرلى',
        description: 'مجموعة ترطيب للشعر الكيرلي',
        price: 300,
      );

      const laserProduct = ProductModel(
        id: 'p2',
        name: 'ميكس بديل الليزر',
        description: 'يساعد على تقليل نمو شعر الجسم والمناطق الحساسة',
        price: 250,
      );

      const unrelatedProduct = ProductModel(
        id: 'p3',
        name: 'عطر الفانيليا',
        description: 'عطر مميز يدوم طويلاً',
        price: 500,
      );

      final products = [unrelatedProduct, laserProduct, hairProduct];

      final sorted = SearchRelevanceHelper.sortByRelevance(products, 'شعر');

      // hairProduct has "الشعر" in its name -> ranks #1
      expect(sorted.first.id, equals('p1'));
      // laserProduct has "شعر" in description -> ranks #2
      expect(sorted[1].id, equals('p2'));
      // unrelatedProduct -> ranks last
      expect(sorted.last.id, equals('p3'));
    });

    test('Exact name match gets the highest priority score', () {
      const serumProduct = ProductModel(
        id: 'p1',
        name: 'ريتنول سيرم',
        description: 'سيرم فعال للبشرة',
        price: 450,
      );

      const otherSerum = ProductModel(
        id: 'p2',
        name: 'سيرم النضارة والتفتيح الثلاثي',
        description: 'سيرم تفتيح ثلاثي المفعول',
        price: 350,
      );

      const bundleProduct = ProductModel(
        id: 'p3',
        name: 'باندل glow& grow',
        description: 'يحتوي على سيرم إطالة الرموش وسيرم تقوية الأظافر',
        price: 300,
      );

      final products = [bundleProduct, otherSerum, serumProduct];

      final sorted = SearchRelevanceHelper.sortByRelevance(products, 'ريتنول سيرم');

      expect(sorted.first.id, equals('p1'));
    });

    test('Cosmetic synonym matching (سيروم vs سيرم)', () {
      const serumProduct = ProductModel(
        id: 'p1',
        name: 'ريتنول سيرم',
        description: 'سيرم ريتينول مركز',
        price: 450,
      );

      const creamProduct = ProductModel(
        id: 'p2',
        name: 'كريم اليدين',
        description: 'ترطيب عميق',
        price: 100,
      );

      final sorted = SearchRelevanceHelper.sortByRelevance([creamProduct, serumProduct], 'سيروم');

      expect(sorted.first.id, equals('p1'));
    });
  });
}

