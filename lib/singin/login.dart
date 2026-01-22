  import 'dart:convert';
  import 'dart:math';
  import 'package:flutter/gestures.dart';
  import 'package:flutter/material.dart';
  import 'package:http/http.dart' as http;
  import 'package:lms_pro/ApiHelper/apihelper.dart';
  import 'package:lms_pro/singin/register_page.dart';
  import 'package:shared_preferences/shared_preferences.dart';

  class OnboardingScreen extends StatefulWidget {
    @override
    State<OnboardingScreen> createState() => _OnboardingScreenState();
  }

  class _OnboardingScreenState extends State<OnboardingScreen> {
    final PageController _pageController = PageController();
    int _currentPage = 0;

    final List<Map<String, dynamic>> _onboardingData = [
      {
        'title': 'Learn Without Limits',
        'description': 'Expand your skills with expert-led courses and hands-on projects that prepare you for real-world challenges',
        'icon': Icons.school,
        'color': Color(0xFF6366F1),
        'gradient': [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        'bgGradient': [Color(0xFFF0F9FF), Color(0xFFE0F2FE)],
      },
      {
        'title': 'Learn Your Way',
        'description': 'Study at your own pace with flexible learning paths designed to fit your schedule and learning style',
        'icon': Icons.schedule,
        'color': Color(0xFFEC4899),
        'gradient': [Color(0xFFEC4899), Color(0xFFF472B6)],
        'bgGradient': [Color(0xFFFDF2F8), Color(0xFFFCE7F3)],
      },
      {
        'title': 'Achieve Goals',
        'description': 'Get certified and advance your career with skills that employers actually want and value',
        'icon': Icons.emoji_events,
        'color': Color(0xFF10B981),
        'gradient': [Color(0xFF10B981), Color(0xFF34D399)],
        'bgGradient': [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
      },
    ];

    @override
    void initState() {
      super.initState();
    }

    @override
    void dispose() {
      _pageController.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Stack(
          children: [

            AnimatedContainer(
              duration: Duration(milliseconds: 500),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _onboardingData[_currentPage]['bgGradient'],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),


            ..._buildFloatingElements(),


            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 60, right: 24),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: _currentPage < _onboardingData.length - 1
                        ? TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => LoginPage()),
                        );
                      },
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: _onboardingData[_currentPage]['color'],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                        : const SizedBox(),
                  ),
                ),

                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _onboardingData.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (context, i) => _buildPage(_onboardingData[i]),
                  ),
                ),


                _buildDotsIndicator(),


                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage == _onboardingData.length - 1) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => LoginPage()),
                          );
                        } else {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _onboardingData[_currentPage]['color'],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        shadowColor: _onboardingData[_currentPage]['color'].withOpacity(0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == 2 ? 'Get Started' : 'Continue',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    Widget _buildPage(Map<String, dynamic> d) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: d['gradient'],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: d['color'].withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                d['icon'],
                size: 60,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 40),

            // Title
            AnimatedOpacity(
              opacity: 1,
              duration: Duration(milliseconds: 600),
              child: Transform.translate(
                offset: Offset(0, 0),
                child: Text(
                  d['title'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: d['color'],
                    height: 1.2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            AnimatedOpacity(
              opacity: 1,
              duration: Duration(milliseconds: 600),
              child: Transform.translate(
                offset: Offset(0, 0),
                child: Text(
                  d['description'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildDotsIndicator() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_onboardingData.length, (i) {
          final bool isActive = i == _currentPage;
          final double width = isActive ? 32.0 : 8.0;

          return AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: width,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: isActive
                  ? _onboardingData[_currentPage]['color']
                  : _onboardingData[_currentPage]['color'].withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      );
    }

    List<Widget> _buildFloatingElements() {
      final random = Random();
      return List.generate(15, (index) {
        final double size = 2 + random.nextDouble() * 4;

        return Positioned(
          left: random.nextDouble() * MediaQuery.of(context).size.width,
          top: random.nextDouble() * MediaQuery.of(context).size.height,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _onboardingData[_currentPage]['color'].withOpacity(0.2),
            ),
          ),
        );
      });
    }
  }

  class LoginPage extends StatefulWidget {
    @override
    State<LoginPage> createState() => _LoginPageState();
  }

  class _LoginPageState extends State<LoginPage> {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    bool isLoading = false;
    bool obscurePassword = true;
    bool _isAnimating = false;

    final String apiUrl = '${ApiHelper.baseUrl}/api/student/login';

    @override
    void initState() {
      super.initState();
      _checkLogin();
      Future.delayed(Duration(milliseconds: 100), () {
        setState(() => _isAnimating = true);
      });
    }

    Future<void> _checkLogin() async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null && token.isNotEmpty) {
        Navigator.pushReplacementNamed(context, '/student-dashboard');
      }
    }

    Future<void> loginUser() async {
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        _showSnackbar('Please fill in all fields', Colors.orange);
        return;
      }

      setState(() => isLoading = true);

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'email': emailController.text.trim(),
            'password': passwordController.text.trim(),
          }),
        );

        final data = json.decode(response.body);

        if (response.statusCode == 200) {
          final prefs = await SharedPreferences.getInstance();

          await prefs.setString('auth_token', data['token']);
          await prefs.setInt('user_id', data['user']['id']);
          await prefs.setString('user_name', data['user']['name']);
          await prefs.setString('user_email', data['user']['email']);

          _showSnackbar('Welcome back!', Colors.green);
          Future.delayed(Duration(milliseconds: 500), () {
            Navigator.pushReplacementNamed(context, '/student-dashboard');
          });
        } else {
          _showSnackbar(data['message'] ?? 'Login failed', Colors.red);
        }
      } catch (e) {
        _showSnackbar('Connection error. Please try again.', Colors.red);
      } finally {
        setState(() => isLoading = false);
      }
    }

    void _showSnackbar(String message, Color color) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Stack(
          children: [
            // Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFF0F9FF),
                    Color(0xFFE0F2FE),
                    Color(0xFFF0FDF4),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // Floating Elements
            ..._buildLoginBackground(),

            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                  bottom: 40,
                  left: 24,
                  right: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back Button
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_ios_rounded),
                      color: Colors.black87,
                    ),

                    // Welcome Text
                    AnimatedOpacity(
                      opacity: _isAnimating ? 1 : 0,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                      child: Transform.translate(
                        offset: Offset(0, _isAnimating ? 0 : 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Back',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sign in to continue your learning journey',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Login Form
                    AnimatedOpacity(
                      opacity: _isAnimating ? 1 : 0,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                      child: Transform.translate(
                        offset: Offset(0, _isAnimating ? 0 : 30),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF6366F1).withOpacity(0.1),
                                blurRadius: 40,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Email Field
                              TextField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email Address',
                                  labelStyle: TextStyle(color: Colors.black54),
                                  prefixIcon: Icon(Icons.email_rounded, color: Color(0xFF6366F1)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade200),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade200),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Color(0xFF6366F1), width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),

                              const SizedBox(height: 20),

                              // Password Field
                              TextField(
                                controller: passwordController,
                                obscureText: obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  labelStyle: TextStyle(color: Colors.black54),
                                  prefixIcon: Icon(Icons.lock_rounded, color: Color(0xFF6366F1)),
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(() => obscurePassword = !obscurePassword),
                                    icon: Icon(
                                      obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade200),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade200),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Color(0xFF6366F1), width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Forgot Password
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: Color(0xFF6366F1),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Login Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : loginUser,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF6366F1),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                    shadowColor: Color(0xFF6366F1).withOpacity(0.3),
                                  ),
                                  child: isLoading
                                      ? SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                      : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Sign In',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(Icons.arrow_forward_ios_rounded, size: 20),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Divider
                              Row(
                                children: [
                                  Expanded(child: Divider(color: Colors.grey.shade300)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      'Or continue with',
                                      style: TextStyle(color: Colors.grey.shade600),
                                    ),
                                  ),
                                  Expanded(child: Divider(color: Colors.grey.shade300)),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // Social Login
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildSocialButton(
                                    icon: Icons.g_mobiledata,
                                    color: Color(0xFFDB4437),
                                    onTap: () {},
                                  ),
                                  const SizedBox(width: 16),
                                  _buildSocialButton(
                                    icon: Icons.facebook,
                                    color: Color(0xFF4267B2),
                                    onTap: () {},
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Sign Up Link
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(color: Colors.black54),
                          children: [
                            TextSpan(
                              text: 'Sign Up',
                              style: TextStyle(
                                color: Color(0xFF6366F1),
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const RegisterPage(),
                                      fullscreenDialog: true,
                                    ),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildSocialButton({required IconData icon, required Color color, required VoidCallback onTap}) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
      );
    }

    List<Widget> _buildLoginBackground() {
      final random = Random();
      return List.generate(10, (index) {
        final double size = 3 + random.nextDouble() * 5;

        return Positioned(
          left: random.nextDouble() * MediaQuery.of(context).size.width,
          top: random.nextDouble() * MediaQuery.of(context).size.height,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF6366F1).withOpacity(0.1),
            ),
          ),
        );
      });
    }
  }