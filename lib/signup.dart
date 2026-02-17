import 'package:edupresence/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edupresence/widgets/snackbar_utils.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController namecontroller = TextEditingController();
  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _selectedDepartment;

  final List<String> _departments = [
    'Computer Science',
    'Information Technology',
    'Electronics',
    'Mechanical',
    'Civil',
    'Electrical',
    'Mathematics',
    'Physics',
    'Chemistry',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1A56BE).withOpacity(0.04),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(32, 100, 32, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Added Logo
                    Center(
                      child: Hero(
                        tag: 'logo',
                        child: Image.asset(
                          "assets/logo.png",
                          height: 200, // Increased for visibility
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A56BE).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.school_rounded,
                              size: 100,
                              color: Color(0xFF1A56BE),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B),
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Join the community of smart educators",
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildInputField(
                      controller: namecontroller,
                      hint: "Full Name",
                      icon: Icons.person_outline_rounded,
                      validator: (v) =>
                          v!.isEmpty ? 'What is your name?' : null,
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      controller: emailcontroller,
                      hint: "Email Address",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v!.isEmpty || !v.contains('@')
                          ? 'Enter a valid email'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedDepartment,
                        decoration: const InputDecoration(
                          hintText: "Select Department",
                          hintStyle: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.normal),
                          prefixIcon: Icon(Icons.business_rounded,
                              color: Color(0xFF1A56BE), size: 22),
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 18, horizontal: 20),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            borderSide:
                                BorderSide(color: Color(0xFF1A56BE), width: 2),
                          ),
                        ),
                        items: _departments
                            .map((dept) => DropdownMenuItem(
                                  value: dept,
                                  child: Text(dept,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500)),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedDepartment = value),
                        validator: (value) =>
                            value == null ? 'Select your department' : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      controller: passwordcontroller,
                      hint: "Password",
                      icon: Icons.lock_outline_rounded,
                      isPassword: true,
                      isPasswordVisible: _isPasswordVisible,
                      onTogglePassword: () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible),
                      validator: (v) =>
                          v!.length < 6 ? 'Password too short (min 6)' : null,
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      controller: confirmPasswordController,
                      hint: "Confirm Password",
                      icon: Icons.lock_reset_rounded,
                      isPassword: true,
                      isPasswordVisible: _isPasswordVisible,
                      validator: (value) {
                        if (value != passwordcontroller.text)
                          return "Passwords do not match";
                        return null;
                      },
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A56BE),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() => _isLoading = true);
                                  String? error =
                                      await authProvider.signUpTeacher(
                                    namecontroller.text.trim(),
                                    emailcontroller.text.trim(),
                                    passwordcontroller.text.trim(),
                                    _selectedDepartment!,
                                  );
                                  if (mounted)
                                    setState(() => _isLoading = false);
                                  if (error != null && mounted) {
                                    SnackbarUtils.showError(context, error);
                                  } else if (mounted) {
                                    SnackbarUtils.showSuccess(
                                        context, "Welcome to EduPresence!");
                                    Navigator.of(context).pop();
                                  }
                                }
                              },
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5))
                            : const Text(
                                "CREATE ACCOUNT",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1),
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? ",
                            style: TextStyle(color: Color(0xFF64748B))),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            "Sign In",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A56BE),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onTogglePassword,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        keyboardType: keyboardType,
        style: const TextStyle(
            fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              color: Color(0xFF94A3B8), fontWeight: FontWeight.normal),
          prefixIcon: Icon(icon, color: const Color(0xFF1A56BE), size: 22),
          suffixIcon: isPassword && onTogglePassword != null
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF64748B),
                    size: 20,
                  ),
                  onPressed: onTogglePassword,
                )
              : null,
          filled: true,
          fillColor: Colors.transparent,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF1A56BE), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
        ),
        validator: validator,
      ),
    );
  }
}
