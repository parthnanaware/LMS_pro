import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import '../screen/profilescreen.dart';
import '../course/courselist.dart';
import '../addtocart/cartscreen.dart';
import '../enrolment/enrolment.dart';
import '../singin/login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const apiBase = "https://82e50f0ae86b.ngrok-free.app";

  int _currentIndex = 0;
  int _cartCount = 0;
  bool _loading = true;
  double _carouselOffset = 0.0;

  Map<String, dynamic>? user;

  final List<Map<String, dynamic>> _carouselItems = [
    {
      "title": "Master Flutter 3.0",
      "subtitle": "With Hands-on Projects",
      "tag": "🔥 Trending Now",
      "gradient": [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      "icon": IconsaxPlusBold.code
    },
    {
      "title": "AI & Machine Learning",
      "subtitle": "From Beginner to Pro",
      "tag": "🌟 New Course",
      "gradient": [Color(0xFFEC4899), Color(0xFFF472B6)],
      "icon": IconsaxPlusBold.cpu
    },
    {
      "title": "UI/UX Design",
      "subtitle": "Complete Figma Guide",
      "tag": "💫 Popular",
      "gradient": [Color(0xFF10B981), Color(0xFF34D399)],
      "icon": IconsaxPlusBold.designtools
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadCartBadge();
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");

      if (token == null) {
        _loading = false;
        setState(() {});
        return;
      }

      final res = await http.get(
        Uri.parse("$apiBase/api/profile"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)["data"];
        user = {
          "name": data["name"],
          "email": data["email"],
          "avatar": data["photo_url"],
          "total_courses": 12,
          "enrolled_hours": "36h",
          "streak_days": 7,
        };
      }

      _loading = false;
      setState(() {});
    } catch (e) {
      _loading = false;
      setState(() {});
    }
  }

  Future<void> _loadCartBadge() async {
    _cartCount = 3; // your static count
    setState(() {});
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = themeNotifier.value == ThemeMode.dark;

    if (_loading || user == null) {
      return Scaffold(
        backgroundColor: isDark ? Color(0xFF0F172A) : Color(0xFFF8FAFC),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Color(0xFF6366F1),
                strokeWidth: 2,
              ),
              SizedBox(height: 16),
              Text(
                "Loading your dashboard...",
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      );
    }

    String name = user!["name"];
    String avatar = user!["avatar"] ?? "";

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF0F172A) : Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(theme, scheme, name, avatar),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await _loadProfile();
                },
                color: Color(0xFF6366F1),
                backgroundColor: isDark ? Color(0xFF1E293B) : Colors.white,
                child: ListView(
                  padding: EdgeInsets.zero,
                  physics: BouncingScrollPhysics(),
                  children: [
                    SizedBox(height: 20),
                    _carousel(theme, scheme),
                    SizedBox(height: 25),
                    _stats(theme, scheme),
                    SizedBox(height: 25),
                    _quickAccess(theme, scheme),
                    SizedBox(height: 25),
                    _featuredCourses(theme, scheme),
                    SizedBox(height: 25),
                    _learningProgress(theme, scheme),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNav(theme, scheme),
    );
  }

  // -------------------------------------------------------------------
  // APP BAR WITH AVATAR & THEME TOGGLE
  // -------------------------------------------------------------------

  Widget _buildAppBar(
      ThemeData theme, ColorScheme scheme, String name, String avatar) {
    final isDark = themeNotifier.value == ThemeMode.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E293B) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black : Color(0xFFE2E8F0),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with gradient border
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: isDark ? Color(0xFF1E293B) : Colors.white,
              backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
              child: avatar.isEmpty
                  ? Text(
                name.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: Color(0xFF6366F1),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              )
                  : null,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back, ${name.split(" ").first}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _greeting(),
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Color(0xFF94A3B8) : Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          // Theme Toggle Button
          _iconButton(
            theme,
            isDark ? IconsaxPlusLinear.sun_1 : IconsaxPlusLinear.moon,
                () => MyApp.setTheme(!isDark),
            Color(0xFF6366F1),
          ),

          const SizedBox(width: 8),

          _iconButton(theme, IconsaxPlusLinear.notification, () {}, Color(0xFF10B981)),

          const SizedBox(width: 8),

          Stack(
            children: [
              _iconButton(
                theme,
                IconsaxPlusLinear.shopping_cart,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartPage()),
                  );
                },
                Color(0xFFF59E0B),
              ),
              if (_cartCount > 0)
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFEF4444).withOpacity(0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      _cartCount > 9 ? "9+" : "$_cartCount",
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
            ],
          ),
        ],
      ),
    );
  }
  Widget _iconButton(ThemeData theme, IconData icon, VoidCallback onTap, Color color) {
    final isDark = themeNotifier.value == ThemeMode.dark;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF334155) : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Color(0xFF475569) : color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, size: 20, color: color),
        padding: EdgeInsets.zero,
      ),
    );
  }

  // -------------------------------------------------------------------
  // CAROUSEL (Gradient banners)
  // -------------------------------------------------------------------
  Widget _carousel(ThemeData theme, ColorScheme scheme) {
    final isDark = themeNotifier.value == ThemeMode.dark;

    return SizedBox(
      height: 170,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            setState(() {
              _carouselOffset = notification.metrics.pixels;
            });
          }
          return false;
        },
        child: PageView.builder(
          itemCount: _carouselItems.length,
          controller: PageController(viewportFraction: 0.88),
          itemBuilder: (context, index) {
            final item = _carouselItems[index];
            final gradient = item["gradient"] as List<Color>;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.1, 0.9],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: gradient[0].withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned(
                      right: -40,
                      bottom: -40,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(.05),
                        ),
                      ),
                    ),
                    Positioned(
                      top: -20,
                      left: -20,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(.03),
                        ),
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item["tag"] as String,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            item["title"] as String,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item["subtitle"] as String,
                            style: TextStyle(
                              color: Colors.white.withOpacity(.9),
                              fontSize: 14,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                width: 70,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  item["icon"] as IconData,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: gradient[0],
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  "Explore Course",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // STATS CARDS
  // -------------------------------------------------------------------

  Widget _stats(ThemeData theme, ColorScheme scheme) {
    final isDark = themeNotifier.value == ThemeMode.dark;

    return Row(
      children: [
        Expanded(
          child: _statCard(
            theme,
            scheme,
            "Courses",
            user!["total_courses"].toString(),
            IconsaxPlusBold.book_1,
                () => _open(const CourseListPage(apiBase: apiBase)),
            gradient: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            iconColor: Color(0xFFC7D2FE),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            theme,
            scheme,
            "enrolled",
            user!["enrolled_hours"].toString(),
            IconsaxPlusBold.clock,
                () => _open(const EnrollmentPage()),
            gradient: [Color(0xFF10B981), Color(0xFF34D399)],
            iconColor: Color(0xFFA7F3D0),
          ),
        ),
        // const SizedBox(width: 12),
        // Expanded(
        //   child: _statCard(
        //     theme,
        //     scheme,
        //     "Day Streak",
        //     "${user!["streak_days"]} days",
        //     IconsaxPlusBold.flash,
        //         () {},
        //     gradient: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
        //     iconColor: Color(0xFFFDE68A),
        //   ),
        // ),
      ],
    );
  }

  Widget _statCard(ThemeData theme, ColorScheme scheme, String title,
      String value, IconData icon, VoidCallback onTap,
      {required List<Color> gradient, required Color iconColor}) {
    final isDark = themeNotifier.value == ThemeMode.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.25),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background icon
            Positioned(
              right: 12,
              top: 12,
              child: Icon(
                icon,
                size: 36,
                color: Colors.white.withOpacity(0.15),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // QUICK ACCESS GRID
  // -------------------------------------------------------------------

  Widget _quickAccess(ThemeData theme, ColorScheme scheme) {
    final isDark = themeNotifier.value == ThemeMode.dark;

    final List<Map<String, dynamic>> quickItems = [
      {"icon": IconsaxPlusBold.video_play, "label": "Live Class", "color": Color(0xFF6366F1)},
      {"icon": IconsaxPlusBold.document_download, "label": "Materials", "color": Color(0xFF10B981)},
      {"icon": IconsaxPlusBold.task_square, "label": "Assignments", "color": Color(0xFFF59E0B)},
      {"icon": IconsaxPlusBold.message_question, "label": "AI Tutor", "color": Color(0xFFEC4899)},
      {"icon": IconsaxPlusBold.book, "label": "Library", "color": Color(0xFF8B5CF6)},
      {"icon": IconsaxPlusBold.chart_2, "label": "Progress", "color": Color(0xFF3B82F6)},
      {"icon": IconsaxPlusBold.message, "label": "Forum", "color": Color(0xFFEF4444)},
      {"icon": IconsaxPlusBold.setting_2, "label": "Settings", "color": Color(0xFF6B7280)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Quick Access",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Color(0xFF1E293B),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  "View All",
                  style: TextStyle(
                    color: Color(0xFF6366F1),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: quickItems.map((item) {
              return _quickItem(
                item["icon"] as IconData,
                item["label"] as String,
                item["color"] as Color,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _quickItem(IconData icon, String label, Color color) {
    final isDark = themeNotifier.value == ThemeMode.dark;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isDark ? Color(0xFF94A3B8) : Color(0xFF64748B),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // -------------------------------------------------------------------
  // FEATURED COURSES
  // -------------------------------------------------------------------

  Widget _featuredCourses(ThemeData theme, ColorScheme scheme) {
    final isDark = themeNotifier.value == ThemeMode.dark;

    final List<Map<String, dynamic>> courses = [
      {
        "category": "Mobile Dev",
        "title": "Advanced Flutter",
        "instructor": "Sarah Wilson",
        "rating": "4.8",
        "price": "₹2,999",
        "color": Color(0xFF6366F1),
        "icon": IconsaxPlusBold.code,
      },
      {
        "category": "UI/UX Design",
        "title": "Figma Masterclass",
        "instructor": "Mike Chen",
        "rating": "4.9",
        "price": "₹3,499",
        "color": Color(0xFFEC4899),
        "icon": IconsaxPlusBold.designtools,
      },
      {
        "category": "Data Science",
        "title": "Python & ML",
        "instructor": "Dr. Emily",
        "rating": "4.7",
        "price": "₹4,199",
        "color": Color(0xFF10B981),
        "icon": IconsaxPlusBold.cpu,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Featured Courses",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Color(0xFF1E293B),
                ),
              ),
              TextButton(
                onPressed: () => _open(const CourseListPage(apiBase: apiBase)),
                child: Row(
                  children: [
                    Text(
                      "View All",
                      style: TextStyle(
                        color: Color(0xFF6366F1),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(IconsaxPlusBold.arrow_right_3, size: 16, color: Color(0xFF6366F1)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 260,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 20, right: 20),
            children: [
              for (var course in courses)
                _courseCard(course, isDark),
              SizedBox(width: 12),
            ],
          ),
        ),
      ],
    );
  }

  Widget _courseCard(Map<String, dynamic> course, bool isDark) {
    Color courseColor = course["color"] as Color;

    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black : Color(0xFFE2E8F0).withOpacity(0.8),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course header with gradient
          Container(
            height: 130,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [courseColor, courseColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Stack(
              children: [
                // Background pattern
                Positioned(
                  right: 16,
                  top: 16,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(course["icon"] as IconData, color: Colors.white, size: 24),
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          course["category"] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 180,
                        child: Text(
                          course["title"] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Course details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "by ${course["instructor"]}",
                  style: TextStyle(
                    color: isDark ? Color(0xFF94A3B8) : Color(0xFF64748B),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(IconsaxPlusBold.star,
                            color: Color(0xFFFBBF24), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          course["rating"] as String,
                          style: TextStyle(
                            color: isDark ? Colors.white : Color(0xFF1E293B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Color(0xFF10B981).withOpacity(0.3)),
                      ),
                      child: Text(
                        course["price"] as String,
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: courseColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {},
                    child: const Text(
                      "Enroll Now",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // LEARNING PROGRESS
  // -------------------------------------------------------------------

  Widget _learningProgress(ThemeData theme, ColorScheme scheme) {
    final isDark = themeNotifier.value == ThemeMode.dark;

    final List<Map<String, dynamic>> progressItems = [
      {"title": "Mobile Development", "progress": 75, "color": Color(0xFF6366F1)},
      {"title": "UI/UX Design", "progress": 60, "color": Color(0xFFEC4899)},
      {"title": "Data Science", "progress": 40, "color": Color(0xFF10B981)},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Color(0xFF1E293B), Color(0xFF0F172A)]
                : [Colors.white, Color(0xFFF8FAFC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black : Color(0xFFE2E8F0),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: isDark ? Color(0xFF334155) : Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Learning Progress",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Color(0xFF1E293B),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(IconsaxPlusBold.trend_up, color: Color(0xFF10B981), size: 16),
                      SizedBox(width: 6),
                      Text(
                        "+12% this week",
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                for (var item in progressItems)
                  _progressItem(item, isDark),
                const SizedBox(height: 8),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _open(const EnrollmentPage()),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Color(0xFF6366F1),
                  side: BorderSide(color: Color(0xFF6366F1)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "View Detailed Progress",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressItem(Map<String, dynamic> item, bool isDark) {
    Color itemColor = item["color"] as Color;
    int progress = item["progress"] as int;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: itemColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item["title"] as String,
                style: TextStyle(
                  color: isDark ? Color(0xFFCBD5E1) : Color(0xFF475569),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              "$progress%",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: itemColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: progress / 100,
          minHeight: 8,
          borderRadius: BorderRadius.circular(10),
          color: itemColor,
          backgroundColor: isDark ? Color(0xFF334155) : Color(0xFFE2E8F0),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // -------------------------------------------------------------------
  // BOTTOM NAVIGATION
  // -------------------------------------------------------------------

  Widget _bottomNav(ThemeData theme, ColorScheme scheme) {
    final isDark = themeNotifier.value == ThemeMode.dark;

    final List<Map<String, dynamic>> navItems = [
      {"icon": IconsaxPlusBold.home_2, "label": "Home"},
      {"icon": IconsaxPlusBold.book_1, "label": "Courses"},
      {"icon": IconsaxPlusBold.calendar_2, "label": "Schedule"},
      {"icon": IconsaxPlusBold.profile_circle, "label": "Profile"},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black : Color(0xFFE2E8F0).withOpacity(0.8),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isDark ? Color(0xFF334155) : Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: navItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final active = _currentIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() => _currentIndex = index);
              if (index == 1) _open(const CourseListPage(apiBase: apiBase));
              if (index == 2) _open(const EnrollmentPage());
              if (index == 3) _open(const ProfilePage());
            },
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: active
                  ? BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              )
                  : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item["icon"] as IconData,
                    size: active ? 22 : 20,
                    color: active
                        ? Colors.white
                        : isDark
                        ? Color(0xFF94A3B8)
                        : Color(0xFF64748B),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item["label"] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: active
                          ? Colors.white
                          : isDark
                          ? Color(0xFF94A3B8)
                          : Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // -------------------------------------------------------------------
  // HELPERS
  // -------------------------------------------------------------------

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning 🌅";
    if (hour < 17) return "Good Afternoon ☀️";
    return "Good Evening 🌙";
  }

  void _open(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }
}