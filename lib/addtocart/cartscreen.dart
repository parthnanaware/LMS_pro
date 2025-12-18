import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> cart = [];

  bool isLoading = false;
  bool isCheckingOut = false;

  String? userId; // ⭐ Logged-in user ID

  // 🔗 Change ONLY Base URL
  final String baseUrl = "https://0fef2e6c7c31.ngrok-free.app";

  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  // ------------------------------------------------------------------
  // 📌 LOAD USER ID FROM SharedPreferences
  // ------------------------------------------------------------------
  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("userId");

    print("🔐 Logged-in userId = $userId");

    if (userId != null) {
      loadCart();
    } else {
      print("⚠ No user id found in SharedPreferences!");
    }
  }

  // ------------------------------------------------------------------
  // 🛒 FETCH CART API
  // ------------------------------------------------------------------
  Future<void> loadCart() async {
    if (userId == null) return;

    setState(() => isLoading = true);

    try {
      final url = "$baseUrl/api/cart/$userId";
      print("📥 Fetch Cart URL = $url");

      final response = await http.get(Uri.parse(url));

      print("📥 Cart Response = ${response.body}");

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);

        if (jsonBody["status"] == "success") {
          setState(() {
            cart = List<Map<String, dynamic>>.from(jsonBody["data"]);
          });
        } else {
          setState(() => cart = []);
        }
      }
    } catch (e) {
      print("❌ Cart Fetch Error: $e");
    }

    setState(() => isLoading = false);
  }

  // ------------------------------------------------------------------
  // ❌ Remove Cart Item
  // ------------------------------------------------------------------
  Future<void> removeFromCart(String cartId, int index) async {
    try {
      final url = "$baseUrl/api/cart/remove/$cartId";
      print("🗑 Remove URL = $url");

      final response = await http.delete(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() => cart.removeAt(index));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Item removed from cart"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to remove item")),
        );
      }
    } catch (e) {
      print("❌ Remove Cart Error: $e");
    }
  }

  // ------------------------------------------------------------------
  // 💳 CHECKOUT → PLACE ORDER
  // ------------------------------------------------------------------
  Future<void> checkout() async {
    if (userId == null) return;

    setState(() => isCheckingOut = true);

    final url = "$baseUrl/api/place-order/$userId";
    print("💳 PLACE ORDER URL = $url");

    try {
      final response = await http.post(Uri.parse(url));

      final jsonBody = jsonDecode(response.body);

      print("💳 Order Response = $jsonBody");

      if (response.statusCode == 200 && jsonBody["status"] == "success") {
        setState(() {
          cart.clear();
          isCheckingOut = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Order placed successfully! 🎉"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() => isCheckingOut = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonBody["message"] ?? "Checkout failed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => isCheckingOut = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ------------------------------------------------------------------
  // 💰 PRICE CALCULATION
  // ------------------------------------------------------------------
  double calculateSubtotal() {
    double subtotal = 0;
    for (var item in cart) {
      subtotal += double.tryParse(item['sell_price'].toString()) ?? 0;
    }
    return subtotal;
  }

  double calculateDiscount() {
    final subtotal = calculateSubtotal();
    if (subtotal > 5000) return subtotal * 0.1;
    return 0;
  }

  double calculateTotal() {
    return calculateSubtotal() - calculateDiscount();
  }

  // ------------------------------------------------------------------
  // 🎨 Colors for Courses
  // ------------------------------------------------------------------
  Color _getCourseColor(int index) {
    final colors = [
      Color(0xFF667EEA),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFF8B5CF6),
      Color(0xFFEC4899),
      Color(0xFF3B82F6),
      Color(0xFF6366F1),
      Color(0xFF14B8A6),
    ];
    return colors[index % colors.length];
  }

  // ------------------------------------------------------------------
  // 🛒 EMPTY CART UI
  // ------------------------------------------------------------------
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(IconsaxPlusLinear.shopping_cart, size: 100, color: Colors.grey),
          SizedBox(height: 15),
          Text("Your Cart is Empty",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("Add courses to your cart to start learning"),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // 🛒 CART ITEM
  // ------------------------------------------------------------------
  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    final color = _getCourseColor(index);

    final name = item['course_name'] ?? "Course";
    final price = double.tryParse(item['sell_price'].toString()) ?? 0;

    final img = item['course_image'];
    final imgUrl = img != null && img.toString().isNotEmpty
        ? "$baseUrl/storage/course_images/$img"
        : null;

    return Dismissible(
      key: Key(item['cart_id'].toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => removeFromCart(item['cart_id'].toString(), index),
      background: Container(
        color: Colors.red.withOpacity(0.15),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(IconsaxPlusLinear.trash, color: Colors.red, size: 28),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: imgUrl != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(imgUrl, fit: BoxFit.cover),
              )
                  : Icon(IconsaxPlusLinear.book_1, color: color),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: 5),
                  Text("₹${price.round()}",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () =>
                  removeFromCart(item['cart_id'].toString(), index),
              child: Icon(IconsaxPlusLinear.trash, color: Colors.red),
            )
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // UI
  // ------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final subtotal = calculateSubtotal();
    final discount = calculateDiscount();
    final total = calculateTotal();

    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text("My Cart"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(IconsaxPlusLinear.arrow_left_2),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: Icon(IconsaxPlusLinear.refresh), onPressed: loadCart)
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : cart.isEmpty
          ? _buildEmptyCart()
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) =>
                  _buildCartItem(cart[index], index),
            ),
          ),
          _buildBottomSheet(subtotal, discount, total)
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // Bottom Price Summary
  // ------------------------------------------------------------------
  Widget _buildBottomSheet(double subtotal, double discount, double total) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: Column(
        children: [
          _priceRow("Subtotal", "₹${subtotal.round()}"),
          _priceRow("Discount", "-₹${discount.round()}",
              isDiscount: true),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total",
                  style:
                  TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text("₹${total.round()}",
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.green)),
            ],
          ),
          SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: isCheckingOut ? null : checkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF667EEA),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: isCheckingOut
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Proceed to Checkout",
                  style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDiscount ? Colors.red : Colors.black,
          ),
        ),
      ],
    );
  }
}
