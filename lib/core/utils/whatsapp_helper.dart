import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Helper utility for opening WhatsApp chat with the merchant.
class WhatsAppHelper {
  WhatsAppHelper._();

  /// Merchant WhatsApp phone number in international format (+201093727578).
  static const String merchantPhone = '201093727578';
  static const String displayPhone = '01093727578';

  /// Open WhatsApp chat with an optional prefilled message.
  static Future<bool> launchWhatsApp({String? text}) async {
    final messageParam = text != null && text.isNotEmpty
        ? '?text=${Uri.encodeComponent(text)}'
        : '';

    // Primary: universal WhatsApp web link (https://wa.me/...)
    final webUri = Uri.parse('https://wa.me/$merchantPhone$messageParam');

    // Deep link fallback: native app scheme (whatsapp://send?phone=...)
    final appUri = Uri.parse(
      'whatsapp://send?phone=+$merchantPhone${text != null && text.isNotEmpty ? '&text=${Uri.encodeComponent(text)}' : ''}',
    );

    try {
      // Try native WhatsApp app scheme first
      if (await canLaunchUrl(appUri)) {
        return await launchUrl(appUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('WhatsApp native launch exception: $e');
    }

    try {
      // Fallback to universal web link (which Android/iOS forwards to app or web)
      return await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('WhatsApp web launch exception: $e');
      return false;
    }
  }

  /// Open WhatsApp chat with prefilled product inquiry details.
  static Future<bool> inquireAboutProduct({
    required String productName,
    required double price,
    double? originalPrice,
    bool onSale = false,
    String? size,
    String? category,
    String? subcategory,
    String? productId,
    bool inStock = true,
    bool isArabic = true,
  }) {
    final buffer = StringBuffer();
    if (isArabic) {
      buffer.writeln('مرحباً، أود الاستفسار عن هذا المنتج من متجر لابيلا:');
      buffer.writeln('━━━━━━━━━━━━━━━━');
      buffer.writeln('🛍️ المنتج: $productName');
      buffer.writeln('💰 السعر: \$${price.toStringAsFixed(2)}');
      if (onSale && originalPrice != null) {
        buffer.writeln(
          '🏷️ السعر قبل الخصم: \$${originalPrice.toStringAsFixed(2)}',
        );
      }
      if (size != null && size.isNotEmpty) {
        buffer.writeln('📏 المقاس: $size');
      }
      if (category != null && category.isNotEmpty) {
        if (subcategory != null &&
            subcategory.isNotEmpty &&
            subcategory != category) {
          buffer.writeln('📂 التصنيف: $category › $subcategory');
        } else {
          buffer.writeln('📂 التصنيف: $category');
        }
      } else if (subcategory != null && subcategory.isNotEmpty) {
        buffer.writeln('📂 التصنيف: $subcategory');
      }
      buffer.writeln('📦 الحالة: ${inStock ? 'متوفر بالمخزون' : 'غير متوفر'}');

      buffer.writeln('━━━━━━━━━━━━━━━━');
      buffer.write('هل المنتج متاح للطلب الآن؟');
    } else {
      buffer.writeln(
        'Hello, I would like to inquire about this product from Labella:',
      );
      buffer.writeln('━━━━━━━━━━━━━━━━');
      buffer.writeln('🛍️ Product: $productName');
      buffer.writeln('💰 Price: \$${price.toStringAsFixed(2)}');
      if (onSale && originalPrice != null) {
        buffer.writeln(
          '🏷️ Original Price: \$${originalPrice.toStringAsFixed(2)}',
        );
      }
      if (size != null && size.isNotEmpty) {
        buffer.writeln('📏 Size: $size');
      }
      if (category != null && category.isNotEmpty) {
        if (subcategory != null &&
            subcategory.isNotEmpty &&
            subcategory != category) {
          buffer.writeln('📂 Category: $category › $subcategory');
        } else {
          buffer.writeln('📂 Category: $category');
        }
      } else if (subcategory != null && subcategory.isNotEmpty) {
        buffer.writeln('📂 Category: $subcategory');
      }
      buffer.writeln('📦 Status: ${inStock ? 'In Stock' : 'Out of Stock'}');

      buffer.writeln('━━━━━━━━━━━━━━━━');
      buffer.write('Is this product available for order?');
    }

    return launchWhatsApp(text: buffer.toString());
  }
}
