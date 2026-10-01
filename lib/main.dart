/*import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'screen/product_page.dart';
import 'screen/jobs_page.dart';
import 'name_entry_page.dart';
import 'screen/seller_profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }

  await Supabase.initialize(
    url: 'https://viewtkzwqffcyttvehlw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZpZXd0a3p3cWZmY3l0dHZlaGx3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIxMDYzMzEsImV4cCI6MjA4NzY4MjMzMX0.AnXTz3dVz2Tv2ubspCcg2nxsZNfQlCIWQvyj19gV03s',
  );

  runApp(const TalentMartApp());
}

class TalentMartApp extends StatelessWidget {
  const TalentMartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TalentMart',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: const TalentMartLanding(),
    );
  }
}

class TalentMartLanding extends StatelessWidget {
  const TalentMartLanding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF3FC),
      body: Stack(
        children: [
          // ─── BACKGROUND BLOBS ─────────────────────────────
          Positioned(
            top: -40,
            left: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withAlpha(30),
              ),
            ),
          ),
          Positioned(
            top: 60,
            right: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withAlpha(20),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 80,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withAlpha(25),
              ),
            ),
          ),

          // ─── MAIN CONTENT ──────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // ─── LOGO ICONS ────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.work_rounded,
                          size: 70, color: const Color(0xFF2B4EDB)),
                      const SizedBox(width: 8),
                      Icon(Icons.shopping_cart_rounded,
                          size: 55, color: const Color(0xFF4D82F3)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ─── TITLE ─────────────────────────────────
                  const Text(
                    'Jobs & Market',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A1A2E),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ─── SUBTITLE ──────────────────────────────
                  const Text(
                    'Find Jobs. Explore Products.\nBuild Your Future.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // ─── ILLUSTRATION ──────────────────────────
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDE8FB),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // City background suggestion
                        Positioned(
                          bottom: 0,
                          child: Container(
                            width: 300,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.blue.withAlpha(15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        // Left person (woman with laptop)
                        Positioned(
                          left: 20,
                          bottom: 10,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withAlpha(40),
                                      blurRadius: 8,
                                    )
                                  ],
                                ),
                                child: const Icon(Icons.work_outline,
                                    color: Color(0xFF2B4EDB), size: 22),
                              ),
                              const SizedBox(height: 6),
                              const Icon(Icons.person,
                                  size: 70, color: Color(0xFF2B4EDB)),
                              const Icon(Icons.laptop_mac,
                                  size: 30, color: Color(0xFF4D82F3)),
                            ],
                          ),
                        ),
                        // Plant in center
                        Positioned(
                          bottom: 10,
                          child: Column(
                            children: [
                              const Icon(Icons.eco,
                                  size: 40, color: Color(0xFF4D82F3)),
                              Container(
                                width: 30,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4D82F3).withAlpha(80),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Right person (man with phone)
                        Positioned(
                          right: 20,
                          bottom: 10,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withAlpha(40),
                                      blurRadius: 8,
                                    )
                                  ],
                                ),
                                child: const Icon(Icons.shopping_cart_outlined,
                                    color: Color(0xFF2B4EDB), size: 22),
                              ),
                              const SizedBox(height: 6),
                              const Icon(Icons.person,
                                  size: 70, color: Color(0xFF2B4EDB)),
                              const Icon(Icons.phone_android,
                                  size: 30, color: Color(0xFF4D82F3)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // ─── JOBS BUTTON (filled blue) ─────────────
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const JobsPage()),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2B4EDB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(width: 8),
                          Icon(Icons.work_rounded, size: 22),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Jobs',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, size: 16),
                          SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ─── MARKET BUTTON (outlined) ──────────────
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: OutlinedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final buyerName = prefs.getString('buyer_name') ?? '';
                        if (!context.mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => buyerName.isEmpty
                                ? const NameEntryPage()
                                : const ProductPage(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2B4EDB),
                        side: const BorderSide(
                            color: Color(0xFF2B4EDB), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(width: 8),
                          Icon(Icons.shopping_cart_rounded, size: 22),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Market',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, size: 16),
                          SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ─── OR DIVIDER ────────────────────────────
                  Row(
                    children: [
                      Expanded(
                          child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                          child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ─── SIGN IN / SIGN UP BUTTON ──────────────
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: OutlinedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AuthPage()),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2B4EDB),
                        side: const BorderSide(
                            color: Color(0xFF2B4EDB), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_outline_rounded, size: 22),
                          SizedBox(width: 10),
                          Text(
                            'Sign In / Sign Up',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ─── FOOTER ────────────────────────────────
                  RichText(
                    text: const TextSpan(
                      text: 'Your journey starts ',
                      style: TextStyle(
                          color: Colors.grey, fontSize: 13),
                      children: [
                        TextSpan(
                          text: 'here.',
                          style: TextStyle(
                            color: Color(0xFF2B4EDB),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── AUTH PAGE ────────────────────────────────────────────────────────────────

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showSnack('Please fill in all fields');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        _showSnack('Signed in successfully!');
        
        Navigator.pushReplacement(
         context,
        MaterialPageRoute(builder: (_) => const SellerProfilePage()),
     );
      }
    } on FirebaseAuthException catch (e) {
      _showSnack(e.message ?? 'Sign in failed');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUp() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showSnack('Please fill in all fields');
      return;
    }
    if (_passwordController.text.trim().length < 6) {
      _showSnack('Password must be at least 6 characters');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await credential.user
          ?.updateDisplayName(_nameController.text.trim());
      if (mounted) {
        _showSnack('Account created successfully!');
        Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (_) => const SellerProfilePage()),
);
      }
    } on FirebaseAuthException catch (e) {
      _showSnack(e.message ?? 'Sign up failed');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
  setState(() => _isLoading = true);
  try {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: '372021798808-51drnp2p60oh7e7kevffqlap8fo1bblp.apps.googleusercontent.com',
      scopes: ['email', 'profile'],
    );
    
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      setState(() => _isLoading = false);
      return;
    }
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await FirebaseAuth.instance.signInWithCredential(credential);
    if (mounted) {
      _showSnack('Signed in with Google!');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SellerProfilePage()),
      );
    }
  } catch (e) {
    _showSnack('Error: $e');
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2B4EDB),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF3FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEEF3FC),
        elevation: 0,
        iconTheme:
            const IconThemeData(color: Color(0xFF2B4EDB)),
        title: const Text(
          'Welcome to TalentMart',
          style: TextStyle(
              color: Color(0xFF1A1A2E),
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // ─── TAB BAR ───────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 8)
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: const Color(0xFF2B4EDB),
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15),
                tabs: const [
                  Tab(text: 'Sign In'),
                  Tab(text: 'Sign Up'),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // ─── TAB CONTENT ───────────────────────────────
            SizedBox(
              height: 420,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // ── SIGN IN TAB ─────────────────────────
                  _buildSignInForm(),
                  // ── SIGN UP TAB ─────────────────────────
                  _buildSignUpForm(),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ─── OR DIVIDER ────────────────────────────────
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade300)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('OR',
                      style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13)),
                ),
                Expanded(child: Divider(color: Colors.grey.shade300)),
              ],
            ),
            const SizedBox(height: 20),

            // ─── GOOGLE SIGN IN ────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton(
                onPressed: _isLoading ? null : _signInWithGoogle,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF4285F4),
                      ),
                      child: const Icon(Icons.g_mobiledata,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Continue with Google',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInForm() {
    return Column(
      children: [
        _buildTextField(
          controller: _emailController,
          hint: 'Email address',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _passwordController,
          hint: 'Password',
          icon: Icons.lock_outline,
          obscure: _obscurePassword,
          suffix: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.grey,
              size: 20,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _signIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2B4EDB),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text('Sign In',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpForm() {
    return Column(
      children: [
        _buildTextField(
          controller: _nameController,
          hint: 'Full name',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          hint: 'Email address',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _passwordController,
          hint: 'Password (min 6 characters)',
          icon: Icons.lock_outline,
          obscure: _obscurePassword,
          suffix: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.grey,
              size: 20,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _signUp,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2B4EDB),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text('Create Account',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(icon,
              color: const Color(0xFF2B4EDB).withAlpha(160), size: 20),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              vertical: 16, horizontal: 12),
        ),
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'screen/product_page.dart';
import 'screen/jobs_page.dart';
import 'name_entry_page.dart';
import 'screen/seller_profile_page.dart';
import 'dart:convert';
import 'screen/admin_page.dart';
import 'screen/shared_paywall.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
const String kFirestoreUrl =
    'https://firestore.googleapis.com/v1/projects/marketplaneproducts/databases/(default)/documents';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }

  await Supabase.initialize(
    url: 'https://viewtkzwqffcyttvehlw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZpZXd0a3p3cWZmY3l0dHZlaGx3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIxMDYzMzEsImV4cCI6MjA4NzY4MjMzMX0.AnXTz3dVz2Tv2ubspCcg2nxsZNfQlCIWQvyj19gV03s',
  );

  runApp(const TalentMartApp());
}

class TalentMartApp extends StatelessWidget {
  const TalentMartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jobs & Market',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: const TalentMartLanding(),
    );
  }
}

class TalentMartLanding extends StatefulWidget {
  const TalentMartLanding({super.key});

  @override
  State<TalentMartLanding> createState() => _TalentMartLandingState();
}

class _TalentMartLandingState extends State<TalentMartLanding> {

 /* void _showPaywallDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: Color(0xFF2B4EDB)),
            SizedBox(width: 8),
            Text('Premium Access',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF3FC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('💰 Premium Access: \$1/month',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  SizedBox(height: 10),
                  Text('Pay through:', style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text('• OMT\n• Wish Money\n• Western Union'),
                  SizedBox(height: 10),
                  Text('Recipient Name:', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text('Mohammad Alwan'),
                  SizedBox(height: 10),
                  Text('Phone Number:', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text('+961 70 813 682'),
                  SizedBox(height: 10),
                  Text('After payment, send screenshot to:',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                  Text('WhatsApp: +961 70 813 682'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '⏳ Your access will be activated after payment verification.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF3FC),
      body: Stack(
        children: [
          // ─── BACKGROUND BLOBS ─────────────────────────────
          Positioned(
            top: -40,
            left: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withAlpha(30),
              ),
            ),
          ),
          Positioned(
            top: 60,
            right: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withAlpha(20),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 80,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withAlpha(25),
              ),
            ),
          ),

          // ─── MAIN CONTENT ──────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // ─── LOGO ICONS ────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.work_rounded,
                          size: 70, color: const Color(0xFF2B4EDB)),
                      const SizedBox(width: 8),
                      Icon(Icons.shopping_cart_rounded,
                          size: 55, color: const Color(0xFF4D82F3)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ─── TITLE ─────────────────────────────────
                  const Text(
                    'Jobs & Market',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A1A2E),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ─── SUBTITLE ──────────────────────────────
                  const Text(
                    'Find Jobs. Explore Products.\nBuild Your Future.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // ─── ILLUSTRATION (photo asset) ────────────
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                    width: double.infinity,
                    color: const Color(0xFFDDE8FB),
                    child: Image.asset(
                     'assets/photo.jfif',
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                   ),
                  ),
               ),
                  const SizedBox(height: 30),

                  // ─── JOBS BUTTON (filled blue) ─────────────
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                     onPressed: () async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    Navigator.push(context,
      MaterialPageRoute(builder: (_) => const AuthPage()));
    return;
  }

  try {
    final res = await http.get(
      Uri.parse('$kFirestoreUrl/sellers/${user.uid}'),
      headers: {'Content-Type': 'application/json'},
    );
    if (res.statusCode == 200) {
      final doc = jsonDecode(res.body);
      final fields = doc['fields'] as Map<String, dynamic>?;
      final jobsAccess = fields?['jobsAccess']?['booleanValue'] ?? false;
      final visits = int.tryParse(
            fields?['jobsPageVisits']?['integerValue']?.toString() ?? '0',
          ) ??
          0;

      if (jobsAccess == true) {
        if (context.mounted) {
          Navigator.push(context,
            MaterialPageRoute(
              builder: (_) => JobsPage(uid: user.uid, paid: true),
            ));
        }
      } else if (visits < 1) {
        // first visit is free
        if (context.mounted) {
          Navigator.push(context,
            MaterialPageRoute(
              builder: (_) => JobsPage(uid: user.uid, paid: false),
            ));
        }
      } else {
        if (context.mounted) showPaywallDialog(context);
      }
    }
  } catch (e) {
    if (context.mounted) showPaywallDialog(context);
  }
},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2B4EDB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(width: 8),
                          Icon(Icons.work_rounded, size: 22),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Jobs',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, size: 16),
                          SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ─── MARKET BUTTON (outlined) ──────────────
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: OutlinedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final buyerName = prefs.getString('buyer_name') ?? '';
                        if (!context.mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => buyerName.isEmpty
                                ? const NameEntryPage()
                                : const ProductPage(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2B4EDB),
                        side: const BorderSide(
                            color: Color(0xFF2B4EDB), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(width: 8),
                          Icon(Icons.shopping_cart_rounded, size: 22),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Market',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, size: 16),
                          SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ─── OR DIVIDER ────────────────────────────
                  Row(
                    children: [
                      Expanded(
                          child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                          child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ─── SIGN IN / SIGN UP BUTTON ──────────────
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: OutlinedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AuthPage()),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2B4EDB),
                        side: const BorderSide(
                            color: Color(0xFF2B4EDB), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_outline_rounded, size: 22),
                          SizedBox(width: 10),
                          Text(
                            'Sign In / Sign Up',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ─── FOOTER ────────────────────────────────
                  RichText(
                    text: const TextSpan(
                      text: 'Your journey starts ',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                      children: [
                        TextSpan(
                          text: 'here.',
                          style: TextStyle(
                            color: Color(0xFF2B4EDB),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── AUTH PAGE ────────────────────────────────────────────────────────────────

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showSnack('Please fill in all fields');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
  _showSnack('Signed in successfully!');
  final email = FirebaseAuth.instance.currentUser?.email ?? '';
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => email == 'admin@gmail.com'
          ? const AdminPage()
          : const SellerProfilePage(),
    ),
  );
}
    } on FirebaseAuthException catch (e) {
      _showSnack(e.message ?? 'Sign in failed');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUp() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showSnack('Please fill in all fields');
      return;
    }
    if (_passwordController.text.trim().length < 6) {
      _showSnack('Password must be at least 6 characters');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await credential.user?.updateDisplayName(_nameController.text.trim());
      if (mounted) {
        _showSnack('Account created successfully!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SellerProfilePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showSnack(e.message ?? 'Sign up failed');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId:
            '372021798808-51drnp2p60oh7e7kevffqlap8fo1bblp.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (mounted) {
        _showSnack('Signed in with Google!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SellerProfilePage()),
        );
      }
    } catch (e) {
      _showSnack('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2B4EDB),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF3FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEEF3FC),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2B4EDB)),
        title: const Text(
          'Welcome to Jobs & Market',
          style: TextStyle(
              color: Color(0xFF1A1A2E),
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // ─── TAB BAR ───────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withAlpha(13), blurRadius: 8)
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: const Color(0xFF2B4EDB),
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15),
                tabs: const [
                  Tab(text: 'Sign In'),
                  Tab(text: 'Sign Up'),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // ─── TAB CONTENT ───────────────────────────────
            SizedBox(
              height: 420,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSignInForm(),
                  _buildSignUpForm(),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ─── OR DIVIDER ────────────────────────────────
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade300)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('OR',
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 13)),
                ),
                Expanded(child: Divider(color: Colors.grey.shade300)),
              ],
            ),
            const SizedBox(height: 20),

            // ─── GOOGLE SIGN IN ────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton(
                onPressed: _isLoading ? null : _signInWithGoogle,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF4285F4),
                      ),
                      child: const Icon(Icons.g_mobiledata,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Continue with Google',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInForm() {
    return Column(
      children: [
        _buildTextField(
          controller: _emailController,
          hint: 'Email address',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _passwordController,
          hint: 'Password',
          icon: Icons.lock_outline,
          obscure: _obscurePassword,
          suffix: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.grey,
              size: 20,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _signIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2B4EDB),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text('Sign In',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpForm() {
    return Column(
      children: [
        _buildTextField(
          controller: _nameController,
          hint: 'Full name',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          hint: 'Email address',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _passwordController,
          hint: 'Password (min 6 characters)',
          icon: Icons.lock_outline,
          obscure: _obscurePassword,
          suffix: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.grey,
              size: 20,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _signUp,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2B4EDB),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text('Create Account',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(icon,
              color: const Color(0xFF2B4EDB).withAlpha(160), size: 20),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        ),
      ),
    );
  }
}