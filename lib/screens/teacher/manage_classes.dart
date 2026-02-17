import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edupresence/providers/student_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edupresence/widgets/snackbar_utils.dart';

class ManageClasses extends StatefulWidget {
  const ManageClasses({super.key});

  @override
  State<ManageClasses> createState() => _ManageClassesState();
}

class _ManageClassesState extends State<ManageClasses> {
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _classController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Classes')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Academic Config",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Set total session count for attendance tracking.",
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              _buildField(
                controller: _classController,
                label: "Class Name",
                icon: Icons.school_outlined,
                hint: "e.g., Computer Science 101",
                onChanged: (v) {
                  if (v.isNotEmpty) {
                    FirebaseFirestore.instance
                        .collection('classes')
                        .doc(v.trim())
                        .get()
                        .then((doc) {
                      if (doc.exists &&
                          _classController.text.trim() == v.trim() &&
                          mounted) {
                        setState(() {
                          _daysController.text =
                              (doc.data()?['totalDays'] ?? '').toString();
                        });
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              _buildField(
                controller: _daysController,
                label: "Total Working Days",
                icon: Icons.calendar_month_rounded,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          final className = _classController.text.trim();
                          final daysText = _daysController.text.trim();

                          if (className.isEmpty || daysText.isEmpty) {
                            SnackbarUtils.showError(
                                context, "Please fill all fields");
                            return;
                          }

                          int? days = int.tryParse(daysText);
                          if (days == null || days <= 0) {
                            SnackbarUtils.showError(
                                context, "Please enter a valid number");
                            return;
                          }

                          setState(() => _isLoading = true);
                          await studentProvider.setTotalDays(className, days);
                          if (mounted) setState(() => _isLoading = false);

                          if (mounted) {
                            SnackbarUtils.showSuccess(
                                context, "Total days updated successfully");
                            _classController.clear();
                            _daysController.clear();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A56BE),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 3))
                      : const Text("UPDATE ACADEMIC DAYS",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 48),
              const Text(
                "Existing Configurations",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('classes')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text("No class configurations yet.",
                        style: TextStyle(color: Color(0xFF64748B)));
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.school_rounded,
                                color: Color(0xFF1A56BE)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                doc.id,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A56BE).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "${data['totalDays']} Days",
                                style: const TextStyle(
                                    color: Color(0xFF1A56BE),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Color(0xFF64748B)),
        prefixIcon: Icon(icon, color: const Color(0xFF475569)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF1A56BE), width: 2),
        ),
      ),
    );
  }
}
