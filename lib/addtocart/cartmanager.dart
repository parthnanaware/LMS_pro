import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CartManager {
  static const String _cartKey = "my_cart";


  static Future<List<Map<String, dynamic>>> getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_cartKey);

    if (data == null || data.isEmpty) return [];

    final List decoded = jsonDecode(data);
    return decoded
        .map<Map<String, dynamic>>(
            (e) => Map<String, dynamic>.from(e))
        .toList();
  }


  static Future<void> _saveCart(
      List<Map<String, dynamic>> cart) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cartKey, jsonEncode(cart));
  }


  static Future<void> addToCart(
      Map<String, dynamic> course) async {
    final cart = await getCart();

    final String courseId =
    (course['course_id'] ?? course['id']).toString();

    final bool alreadyExists = cart.any((item) {
      final String itemId =
      (item['course_id'] ?? item['id']).toString();
      return itemId == courseId;
    });

    if (!alreadyExists) {
      cart.add(course);
      await _saveCart(cart);
    }
  }

  static Future<void> removeFromCart(String courseId) async {
    final cart = await getCart();

    cart.removeWhere((item) {
      final String itemId =
      (item['course_id'] ?? item['id']).toString();
      return itemId == courseId;
    });

    await _saveCart(cart);
  }

  static Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }


  static Future<bool> isInCart(String courseId) async {
    final cart = await getCart();
    return cart.any((item) {
      final String itemId =
      (item['course_id'] ?? item['id']).toString();
      return itemId == courseId;
    });
  }
}
