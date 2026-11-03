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
}
