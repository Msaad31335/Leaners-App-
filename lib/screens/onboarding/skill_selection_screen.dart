import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';

class SkillSelectionScreen extends StatefulWidget {
  const SkillSelectionScreen({super.key});

  @override
  State<SkillSelectionScreen> createState() => _SkillSelectionScreenState();
}

class _SkillSelectionScreenState extends State<SkillSelectionScreen> {
  final List<Map<String, dynamic>> skills = const [
    {'id': 'python',     'name': 'Python',          'icon': Icons.code_rounded},
    {'id': 'html',       'name': 'HTML / CSS',       'icon': Icons.language_rounded},
    {'id': 'javascript', 'name': 'JavaScript',       'icon': Icons.javascript_rounded},
    {'id': 'java',       'name': 'Java',             'icon': Icons.coffee_rounded},
    {'id': 'cpp',        'name': 'C++',              'icon': Icons.memory_rounded},
    {'id': 'dsa',        'name': 'Data Structures',  'icon': Icons.account_tree_rounded},
    {'id': 'database',   'name': 'SQL',              'icon': Icons.storage_rounded},
    {'id': 'git',        'name': 'Git & GitHub',     'icon': Icons.merge_rounded},
    {'id': 'aiml',       'name': 'AI / ML',          'icon': Icons.psychology_rounded},
    {'id': 'sap',        'name': 'SAP ERP',          'icon': Icons.business_rounded},
  ];

  final List<String> _selected = [];
  bool _isLoading = false;

  void _toggleSkill(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  Future<void> _continue() async {
    if (_selected.isEmpty) return;
    setState(() => _isLoading = true);

    await context.read<AuthProvider>().updateSkills(_selected);

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(selectedSkills: _selected),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              FadeInDown(
                child: const Text('Select Your Skills',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 8),
              const Text('Choose topics you want to learn (select multiple)',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),

              const SizedBox(height: 8),

              // Selected count badge
              if (_selected.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Text(
                    '${_selected.length} selected',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),

              const SizedBox(height: 16),

              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: skills.length,
                  itemBuilder: (context, index) {
                    final skill      = skills[index];
                    final isSelected = _selected.contains(skill['id']);
                    return FadeInUp(
                      duration: const Duration(milliseconds: 400),
                      delay: Duration(milliseconds: index * 60),
                      child: GestureDetector(
                        onTap: () => _toggleSkill(skill['id']),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.15)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                skill['icon'] as IconData,
                                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                size: 32,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                skill['name'],
                                style: TextStyle(
                                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (isSelected) ...[
                                const SizedBox(height: 4),
                                const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 16),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: (_selected.isEmpty || _isLoading) ? null : _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selected.isEmpty ? AppColors.surface : AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          _selected.isEmpty
                              ? 'Select at least one skill'
                              : 'Start Learning (${_selected.length} selected)',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}