  import 'dart:convert';
  import 'package:flutter/material.dart';
  import 'package:http/http.dart' as http;
  import 'package:lms_pro/addtocart/cartscreen.dart';
  import 'package:lms_pro/course/coursesubject.dart';
  import 'package:iconsax_plus/iconsax_plus.dart';
  import 'package:shared_preferences/shared_preferences.dart';

  class CourseListPage extends StatefulWidget {
    final String apiBase;

    const CourseListPage({
      super.key,
      required this.apiBase,
    });

    @override
    State<CourseListPage> createState() => _CourseListPageState();
  }

  class _CourseListPageState extends State<CourseListPage> {
    bool loading = true;
    bool error = false;
    List courses = [];
    final List<String> categories = ["All", "Development", "Design", "Business", "AI/ML", "Marketing"];
    String selectedCategory = "All";
    TextEditingController searchController = TextEditingController();
    bool _showSearch = false;

    @override
    void initState() {
      super.initState();
      fetchCourses();
    }

    Future<void> fetchCourses() async {
      final url = "${widget.apiBase}/api/courses";
      print("Fetching: $url");

      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {"Accept": "application/json"},
        );

        if (response.statusCode == 200) {
          final jsonData = jsonDecode(response.body);
          setState(() {
            courses = jsonData["data"] ?? [];
            loading = false;
          });
        } else {
          setState(() {
            error = true;
            loading = false;
          });
        }
      } catch (e) {
        print("Error → $e");
        setState(() {
          error = true;
          loading = false;
        });
      }
    }

    Future<void> addToCart(String courseId, String courseName) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString("userId");
        final token = prefs.getString("auth_token");

        if (userId == null || token == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(IconsaxPlusBold.info_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text("Please login first to add to cart"),
                ],
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          return;
        }

        final url = Uri.parse("${widget.apiBase}/api/cart/add");
        final response = await http.post(
          url,
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
          body: {
            "user_id": userId,
            "course_id": courseId,
          },
        );
        final jsonRes = jsonDecode(response.body);

        // Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(IconsaxPlusBold.tick_circle, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Added '$courseName' to cart",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: Duration(seconds: 2),
            action: SnackBarAction(
              label: "View Cart",
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CartPage(),
                  ),
                );
              },
            ),
          ),
        );
      } catch (e) {
        print("Cart Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(IconsaxPlusBold.close_circle, color: Colors.white),
                SizedBox(width: 8),
                Text("Failed to add to cart"),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }

    Widget _buildLoadingState(BuildContext context) {
      final theme = Theme.of(context);
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Loading Courses...",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Fetching the best courses for you",
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildErrorState(BuildContext context) {
      final theme = Theme.of(context);
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.surface,
                      theme.colorScheme.surfaceVariant,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  IconsaxPlusBold.cloud_remove,
                  size: 50,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              SizedBox(height: 24),
              Text(
                "Oops! Something went wrong",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "We couldn't load the courses. Please check your internet connection and try again.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: fetchCourses,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(IconsaxPlusBold.refresh, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Try Again",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildEmptyState(BuildContext context) {
      final theme = Theme.of(context);
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.surface,
                      theme.colorScheme.surfaceVariant,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  IconsaxPlusBold.book_saved,
                  size: 50,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              SizedBox(height: 24),
              Text(
                "No Courses Available",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "We're working on adding new courses. Check back soon for exciting learning opportunities!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildSearchBar(BuildContext context) {
      final theme = Theme.of(context);
      return AnimatedContainer(
        duration: Duration(milliseconds: 300),
        height: _showSearch ? 56 : 0,
        margin: EdgeInsets.symmetric(horizontal: 16),
        child: _showSearch
            ? TextField(
          controller: searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Search courses...",
            hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(IconsaxPlusBold.search_normal_1,
                color: theme.colorScheme.primary),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _showSearch = false;
                  searchController.clear();
                });
              },
              icon: Icon(Icons.close, color: theme.colorScheme.onSurface.withOpacity(0.5)),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          ),
          style: TextStyle(color: theme.colorScheme.onSurface),
        )
            : SizedBox.shrink(),
      );
    }

    @override
    Widget build(BuildContext context) {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;

      return Scaffold(
        backgroundColor: theme.colorScheme.background,
        body: loading
            ? _buildLoadingState(context)
            : error
            ? _buildErrorState(context)
            : courses.isEmpty
            ? _buildEmptyState(context)
            : _buildContent(context),
      );
    }

    Widget _buildContent(BuildContext context) {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;

      return CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          // App Bar with Search
          SliverAppBar(
            pinned: true,
            floating: true,
            backgroundColor: theme.colorScheme.surface,
            elevation: 0,
            surfaceTintColor: theme.colorScheme.surface,
            expandedHeight: 180,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                      theme.colorScheme.primary.withOpacity(0.1),
                      theme.colorScheme.secondary.withOpacity(0.05),
                    ]
                        : [
                      theme.colorScheme.primary.withOpacity(0.08),
                      theme.colorScheme.secondary.withOpacity(0.04),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Explore Courses",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Learn from industry experts and boost your career",
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(_showSearch ? 70 : 120),
              child: Column(
                children: [
                  _buildSearchBar(context),
                  if (!_showSearch) _buildFilterSection(context),
                ],
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _showSearch = !_showSearch;
                  });
                },
                icon: Icon(
                  _showSearch ? Icons.close : IconsaxPlusBold.search_normal_1,
                  color: theme.colorScheme.primary,
                ),
              ),
              IconButton(
                onPressed: fetchCourses,
                icon: Icon(IconsaxPlusBold.refresh, color: theme.colorScheme.primary),
              ),
            ],
          ),

          // Courses Count
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${courses.length} Courses Found",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    selectedCategory != "All" ? "Category: $selectedCategory" : "All Categories",
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Courses Grid
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 0.75, // Slightly taller cards for better content
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final c = courses[index];
                  final id = c["course_id"].toString();
                  final name = c["course_name"] ?? "Course";
                  final img = c["course_image_url"];
                  final desc = c["course_description"] ?? "No description";
                  final price = c["sell_price"]?.toString() ?? "0";
                  final rating = c["rating"] ?? 4.5;
                  final level = c["level"] ?? "Beginner";

                  // Dark mode aware gradient colors
                  final colors = isDark
                      ? [
                    [theme.colorScheme.primary, theme.colorScheme.secondary],
                    [Color(0xFFEC4899), Color(0xFFF472B6)],
                    [Color(0xFF10B981), Color(0xFF34D399)],
                    [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                    [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                  ]
                      : [
                    [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    [Color(0xFFEC4899), Color(0xFFF472B6)],
                    [Color(0xFF10B981), Color(0xFF34D399)],
                    [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                    [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                  ];
                  final colorPair = colors[index % colors.length];

                  return CourseCard(
                    id: id,
                    name: name,
                    img: img,
                    desc: desc,
                    price: price,
                    rating: rating,
                    level: level,
                    gradientColors: colorPair,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CourseSubjectPage(courseId: id),
                        ),
                      );
                    },
                    onAddToCart: () => addToCart(id, name),
                  );
                },
                childCount: courses.length,
              ),
            ),
          ),
        ],
      );
    }

    Widget _buildFilterSection(BuildContext context) {
      final theme = Theme.of(context);
      return Container(
        color: theme.colorScheme.surface,
        child: Column(
          children: [
            SizedBox(height: 8),
            // Categories
            SizedBox(
              height: 42,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategory == category;
                  return Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        category,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                      selectedColor: theme.colorScheme.primary,
                      backgroundColor: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : theme.colorScheme.surfaceVariant,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity(0.2),
                          width: isSelected ? 1 : 0.5,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      );
    }
  }

  class CourseCard extends StatelessWidget {
    final String id;
    final String name;
    final String img;
    final String desc;
    final String price;
    final double rating;
    final String level;
    final List<Color> gradientColors;
    final VoidCallback onTap;
    final VoidCallback onAddToCart;

    const CourseCard({
      required this.id,
      required this.name,
      required this.img,
      required this.desc,
      required this.price,
      required this.rating,
      required this.level,
      required this.gradientColors,
      required this.onTap,
      required this.onAddToCart,
    });

    @override
    Widget build(BuildContext context) {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;

      return Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.3) : Color(0xFFE2E8F0).withOpacity(0.8),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Image with Gradient Overlay
            Stack(
              children: [
                Container(
                  height: 140, // Increased height for better image visibility
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: img.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.network(
                      img,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 140,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            IconsaxPlusBold.video_play,
                            size: 40,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        );
                      },
                    ),
                  )
                      : Center(
                    child: Icon(
                      IconsaxPlusBold.video_play,
                      size: 40,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),

                // Price Tag - Moved to top left for better visibility
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Text(
                      "₹$price",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),

                // Add to Cart Button - Positioned better
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: onAddToCart,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          IconsaxPlusBold.shopping_cart,
                          color: gradientColors[0],
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Course Info - Improved spacing
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course Name
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),

                      // Rating and Level Row
                      Row(
                        children: [
                          Icon(IconsaxPlusBold.star, size: 14, color: Color(0xFFFBBF24)),
                          SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onSurface.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: gradientColors[0].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              level,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: gradientColors[0],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Explore Course Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gradientColors[0],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        shadowColor: gradientColors[0].withOpacity(0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(IconsaxPlusBold.eye, size: 16),
                          SizedBox(width: 8),
                          Text(
                            "Explore Course",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
  }