/// Egyptian Governorates and shipping pricing rules.
///
/// Shipping Policy:
/// - Al Sharqia (محافظة الشرقية): FREE Shipping (0 EGP / $0).
/// - All other Governorates: 100 EGP / $100.
class EgyptGovernorates {
  EgyptGovernorates._();

  /// Exact value expected by backend `order.services.ts`:
  /// `if (selectedAddress.state === "محافظة الشرقية") { taxPrice = 0; }`
  static const String sharqia = 'محافظة الشرقية';

  /// Complete list of all 27 Egyptian Governorates.
  /// Sharqia is placed first for convenient selection.
  static const List<String> governorates = [
    'محافظة الشرقية', // Free delivery!
    'محافظة القاهرة',
    'محافظة الجيزة',
    'محافظة الإسكندرية',
    'محافظة القليوبية',
    'محافظة الدقهلية',
    'محافظة الغربية',
    'محافظة المنوفية',
    'محافظة البحيرة',
    'محافظة كفر الشيخ',
    'محافظة دمياط',
    'محافظة بورسعيد',
    'محافظة الإسماعيلية',
    'محافظة السويس',
    'محافظة شمال سيناء',
    'محافظة جنوب سيناء',
    'محافظة البحر الأحمر',
    'محافظة الفيوم',
    'محافظة بني سويف',
    'محافظة المنيا',
    'محافظة أسيوط',
    'محافظة سوهاج',
    'محافظة قنا',
    'محافظة الأقصر',
    'محافظة أسوان',
    'محافظة الوادي الجديد',
    'محافظة مطروح',
  ];

  /// Checks whether a given state/governorate string represents Sharqia.
  static bool isSharqia(String? state) {
    if (state == null) return false;
    final lower = state.trim().toLowerCase();
    return state.contains('الشرقية') || lower.contains('sharqia') || lower.contains('sharkia');
  }

  /// Calculates the shipping fee for a given governorate:
  /// - 0.0 for Sharqia
  /// - 100.0 for any other governorate
  static double getShippingFee(String? state) {
    if (state == null || state.trim().isEmpty) return 100.0;
    return isSharqia(state) ? 0.0 : 100.0;
  }
}

