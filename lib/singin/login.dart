import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lms_pro/singin/register_page.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
        'title': 'Learn Without Limits',
      'description': 'Expand your skills with expert-led courses and hands-on projects',
      'icon': IconsaxPlusLinear.book_1,
      'color': Color(0xFF667EEA),
      'bgColor': Color(0xFF667EEA).withOpacity(0.08),
      'gradient': [Color(0xFF667EEA), Color(0xFF764BA2)],
    },
    {
      'title': 'Learn Your Way',
      'description': 'Study at your own pace with flexible learning paths',
      'icon': IconsaxPlusLinear.clock,
      'color': Color(0xFFF093FB),
      'bgColor': Color(0xFFF093FB).withOpacity(0.08),
      'gradient': [Color(0xFFF093FB), Color(0xFFF5576C)],
    },
    {
      'title': 'Achieve Goals',
      'description': 'Get certified and advance your career with new skills',
      'icon': IconsaxPlusLinear.award,
      'color': Color(0xFF4FACFE),
      'bgColor': Color(0xFF4FACFE).withOpacity(0.08),
      'gradient': [Color(0xFF4FACFE), Color(0xFF00F2FE)],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.topRight,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Page View
            Expanded(
              flex: 3,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(_onboardingData[index]);
                },
              ),
            ),

            // Dots and Button
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  // Dots Indicator
                  _buildDotsIndicator(),
                  SizedBox(height: 40),

                  // Next/Get Started Button
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: _onboardingData[_currentPage]['gradient'],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _onboardingData[_currentPage]['color'].withOpacity(0.3),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentPage == _onboardingData.length - 1) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => LoginPage()),
                            );
                          } else {
                            _pageController.nextPage(
                              duration: Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentPage == _onboardingData.length - 1 ? 'Get Started' : 'Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              IconsaxPlusLinear.arrow_right_3,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildDotsIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_onboardingData.length, (index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            gradient: _currentPage == index
                ? LinearGradient(
              colors: _onboardingData[_currentPage]['gradient'],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
            color: _currentPage == index ? null : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildOnboardingPage(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon Container with enhanced design
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: data['gradient'],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: data['color'].withOpacity(0.3),
                  blurRadius: 25,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Container(
              margin: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  data['icon'],
                  size: 50,
                  color: data['color'],
                ),
              ),
            ),
          ),
          SizedBox(height: 60),
          Text(
            data['title'],
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 1.3,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Text(
            data['description'],
            style: TextStyle(
              fontSize: 16,
  color: Colors.grey.shade600,
  height: 1.6,
  fontWeight: FontWeight.w400,
  ),
  textAlign: TextAlign.center,
  ),
  ],
  ),
  );
}
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool obscurePassword = true;

  final String apiUrl = 'https://f71ed3300e16.ngrok-free.app/api/student/login';


  Future<void> loginUser() async {
    setState(() => isLoading = true);

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Please enter both email and password', Colors.red);
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      final data = json.decode(response.body);
      print(data);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        final String? token = data['token'];
        final dynamic user = data['user'];  // full user object

        if (token != null && user != null) {
          final String userId = user['id'].toString();   // ⭐ FIXED

          await prefs.setString('auth_token', token);
          await prefs.setString('userId', userId);       // ⭐ FIXED
          await prefs.setString('user_name', user['name']);
          await prefs.setString('user_email', user['email']);
        }

        _showSnackBar('Login successful! 🎉', Color(0xFF10B981));

        Navigator.pushReplacementNamed(context, '/student-dashboard');

      } else if (response.statusCode == 403) {
        _showSnackBar(data['message'] ?? 'Your account is inactive.', Colors.orange);
      } else if (response.statusCode == 401) {
        _showSnackBar(data['message'] ?? 'Invalid email or password.', Colors.red);
      } else {
        _showSnackBar(data['message'] ?? 'Unexpected error occurred.', Colors.red);
      }

    } catch (e) {
      print('Error: $e');
      _showSnackBar('Failed to connect to the server.', Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }


  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button with enhanced design
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back_rounded, color: Colors.grey.shade700, size: 22),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => OnboardingScreen()),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),

              // Welcome Section
              _buildWelcomeSection(),
              SizedBox(height: 40),

              // Login Form
              _buildLoginForm(),
              SizedBox(height: 30),

              // Divider
              _buildDivider(),
              SizedBox(height: 30),

              // Social Login
              _buildSocialLogin(),
              SizedBox(height: 30),

              // Sign Up Link
              _buildSignUpLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 12),
        Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Sign in to continue your learning journey',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        // Email Field
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade800, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              labelText: 'Email Address',
              labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w500),
              prefixIcon: Container(
                margin: EdgeInsets.only(right: 12, left: 8),
                decoration: BoxDecoration(
                  color: Color(0xFF667EEA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(IconsaxPlusLinear.sms, color: Color(0xFF667EEA), size: 22),
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Color(0xFF667EEA), width: 2),
              ),
            ),
          ),
        ),
        SizedBox(height: 20),

        // Password Field
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: TextField(
            controller: passwordController,
            obscureText: obscurePassword,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade800, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w500),
              prefixIcon: Container(
                margin: EdgeInsets.only(right: 12, left: 8),
                decoration: BoxDecoration(
                  color: Color(0xFF667EEA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(IconsaxPlusLinear.lock_1, color: Color(0xFF667EEA), size: 22),
              ),
              suffixIcon: Container(
                margin: EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    obscurePassword ? IconsaxPlusLinear.eye_slash : IconsaxPlusLinear.eye,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Color(0xFF667EEA), width: 2),
              ),
            ),
          ),
        ),
        SizedBox(height: 16),

        // Forgot Password
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              _showSnackBar('Password reset feature coming soon!', Color(0xFF667EEA));
            },
            child: Text(
              'Forgot Password?',
              style: TextStyle(
                color: Color(0xFF667EEA),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
        SizedBox(height: 20),

        // Login Button
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF667EEA).withOpacity(0.3),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isLoading ? null : loginUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(color: Colors.grey.shade300, thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Or continue with',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: Colors.grey.shade300, thickness: 1),
        ),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(Icons.g_mobiledata, 'Google', Colors.red),
        SizedBox(width: 16),
        _buildSocialButton(Icons.facebook, 'Facebook', Color(0xFF1877F2)),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            _showSnackBar('$label sign in coming soon!', Color(0xFF667EEA));
          },
          child: Container(
            width: 60,
            height: 60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Center(
      child: RichText(
        text: TextSpan(
          text: "Don't have an account? ",
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),children: [
          TextSpan(
            text: 'Sign Up',
            style: const TextStyle(
              color: Color(0xFF667EEA),
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RegisterPage(),
                  ),
                );
              },
          ),
        ],

        ),
      ),
    );
  }
}
