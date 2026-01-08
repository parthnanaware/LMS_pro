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
  String? userId;
  final String baseUrl = "https://abcf1818992c.ngrok-free.app";

  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("userId");
    if (userId != null) {
      loadCart();
    }
  }

  Future<void> loadCart() async {
    if (userId == null) return;
    setState(() => isLoading = true);
    try {
      final url = "$baseUrl/api/cart/$userId";
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        if (jsonBody["status"] == "success") {
          setState(() {
            cart = List<Map<String, dynamic>>.from(jsonBody["data"]);
          });
        }
      }
    } catch (e) {
      print(" Cart Fetch Error: $e");
    }
    setState(() => isLoading = false);
  }

  Future<void> removeFromCart(String cartId, int index) async {
    try {
      final url = "$baseUrl/api/cart/remove/$cartId";
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() => cart.removeAt(index));
        _showSnackBar("Item removed from cart", Colors.red);
      }
    } catch (e) {
      print("Remove Cart Error: $e");
    }
  }

  Future<void> checkout() async {
    if (userId == null) return;
    setState(() => isCheckingOut = true);
    final url = "$baseUrl/api/place-order/$userId";
    try {
      final response = await http.post(Uri.parse(url));
      final jsonBody = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonBody["status"] == "success") {
        setState(() {
          cart.clear();
          isCheckingOut = false;
        });
        _showSnackBar("Order placed successfully! 🎉", Colors.green);
      } else {
        setState(() => isCheckingOut = false);
        _showSnackBar(jsonBody["message"] ?? "Checkout failed", Colors.red);
      }
    } catch (e) {
      setState(() => isCheckingOut = false);
      _showSnackBar("Error: $e", Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

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

  double calculateTotal() => calculateSubtotal() - calculateDiscount();

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

  Widget _buildEmptyCart(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              IconsaxPlusLinear.shopping_cart,
              size: 60,
              color: isDarkMode ? Colors.grey[400] : Colors.grey,
            ),
          ),
          SizedBox(height: 24),
          Text(
            "Your Cart is Empty",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 12),
          Text(
            "Browse courses and add them to your cart",
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode ? Color(0xFF667EEA) : Color(0xFF667EEA),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Explore Courses",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index, BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final color = _getCourseColor(index);
    final name = item['course_name'] ?? "Course";
    final price = double.tryParse(item['sell_price'].toString()) ?? 0;
    final img = item['course_image'];
    final imgUrl = img != null && img.toString().isNotEmpty
        ? "$baseUrl/storage/course_images/$img"
        : null;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Dismissible(
        key: Key(item['cart_id'].toString()),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => removeFromCart(item['cart_id'].toString(), index),
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(isDarkMode ? 0.3 : 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 20),
          child: Icon(IconsaxPlusLinear.trash, color: Colors.red, size: 28),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isDarkMode ? null : [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: Offset(0, 4),
              ),
            ],
            border: isDarkMode ? Border.all(color: Colors.grey[800]!) : null,
          ),
          child: Row(
            children: [
              // Course Image
              Container(
                width: 90,
                height: 90,
                margin: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      color,
                      color.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: imgUrl != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imgUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          IconsaxPlusLinear.book_1,
                          color: Colors.white,
                          size: 32,
                        ),
                      );
                    },
                  ),
                )
                    : Center(
                  child: Icon(
                    IconsaxPlusLinear.book_1,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),

              // Course Info
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "Course",
                              style: TextStyle(
                                fontSize: 12,
                                color: color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Spacer(),
                          Text(
                            "₹${price.round()}",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Remove Button
              Padding(
                padding: EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () => removeFromCart(item['cart_id'].toString(), index),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      IconsaxPlusLinear.trash,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final subtotal = calculateSubtotal();
    final discount = calculateDiscount();
    final total = calculateTotal();

    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF121212) : Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          "My Cart",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(IconsaxPlusLinear.arrow_left_2),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(IconsaxPlusLinear.refresh),
            onPressed: loadCart,
          ),
        ],
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: isDarkMode ? Color(0xFF667EEA) : Color(0xFF667EEA),
        ),
      )
          : cart.isEmpty
          ? _buildEmptyCart(context)
          : Column(
        children: [
          // Header with item count
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            child: Row(
              children: [
                Text(
                  "Your Courses",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Color(0xFF667EEA) : Color(0xFF667EEA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${cart.length} ${cart.length == 1 ? 'item' : 'items'}",
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Color(0xFF667EEA),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 8),

          // Cart Items List
          Expanded(
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: cart.length,
              itemBuilder: (context, index) =>
                  _buildCartItem(cart[index], index, context),
            ),
          ),

          // Bottom Summary
          _buildBottomSummary(subtotal, discount, total, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildBottomSummary(double subtotal, double discount, double total, bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Price Summary
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildPriceRow("Subtotal", subtotal, isDarkMode),
                SizedBox(height: 8),
                _buildPriceRow("Discount", discount, isDarkMode, isDiscount: true),
                Divider(color: isDarkMode ? Colors.grey[700] : Colors.grey[300], height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Amount",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      "₹${total.round()}",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Checkout Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isCheckingOut ? null : checkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF667EEA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: isCheckingOut
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  SizedBox(width: 12),
                  Text(
                    "Processing...",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(IconsaxPlusLinear.wallet, color: Colors.white, size: 22),
                  SizedBox(width: 10),
                  Text(
                    "Proceed to Checkout",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 8),

          // Security Message
          Text(
            "Secure payment · 30-day money-back guarantee",
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, bool isDarkMode, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
          ),
        ),
        Text(
          "₹${amount.round()}",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDiscount ? Colors.red : (isDarkMode ? Colors.white : Colors.black),
          ),
        ),
      ],
    );
  }
}