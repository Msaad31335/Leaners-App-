import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  final List<Map<String, dynamic>> skills = const [
    {'name': 'Python', 'progress': 0.6, 'lessons': 12, 'total': 20},
    {'name': 'HTML / CSS', 'progress': 0.3, 'lessons': 6, 'total': 20},
    {'name': 'JavaScript', 'progress': 0.1, 'lessons': 2, 'total': 20},
  ];

  final List<Map<String, dynamic>> badges = const [
    {'icon': Icons.local_fire_department_rounded, 'name': '7-Day Streak', 'earned': true},
    {'icon': Icons.code_rounded, 'name': 'Python Beginner', 'earned': true},
    {'icon': Icons.bolt_rounded, 'name': 'Fast Learner', 'earned': false},
    {'icon': Icons.emoji_events_rounded, 'name': '30-Day Streak', 'earned': false},
    {'icon': Icons.psychology_rounded, 'name': 'DSA Master', 'earned': false},
    {'icon': Icons.star_rounded, 'name': '1000 XP Club', 'earned': true},
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            FadeInDown(
              duration: const Duration(milliseconds: 600),
              child: const Text(
                'Your Progress',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Stats Card
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 100),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      label: 'Total XP',
                      value: '${user?.xp ?? 0}',
                      icon: Icons.star_rounded,
                    ),
                    _StatItem(
                      label: 'Level',
                      value: '${user?.level ?? 1}',
                      icon: Icons.emoji_events_rounded,
                    ),
                    _StatItem(
                      label: 'Best Streak',
                      value: '${user?.bestStreak ?? 0}',
                      icon: Icons.local_fire_department_rounded,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            FadeInUp(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 200),
              child: const Text(
                'Skills Progress',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),

            ...skills.asMap().entries.map((entry) {
              final index = entry.key;
              final skill = entry.value;
              return FadeInUp(
                duration: const Duration(milliseconds: 400),
                delay: Duration(milliseconds: 250 + index * 80),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            skill['name'],
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '${skill['lessons']}/${skill['total']} lessons',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${(skill['progress'] * 100).toInt()}%',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: skill['progress'],
                          backgroundColor: AppColors.card,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(
                                  AppColors.primary),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 28),

            FadeInUp(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 400),
              child: const Text(
                'Achievements',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),

            FadeInUp(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 450),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.9,
                ),
                itemCount: badges.length,
                itemBuilder: (context, index) {
                  final badge = badges[index];
                  final earned = badge['earned'] as bool;
                  return Container(
                    decoration: BoxDecoration(
                      color: earned
                          ? AppColors.primary.withOpacity(0.15)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: earned
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          badge['icon'] as IconData,
                          color: earned
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          size: 28,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          badge['name'],
                          style: TextStyle(
                            color: earned
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (!earned) ...[
                          const SizedBox(height: 4),
                          const Icon(
                            Icons.lock_rounded,
                            color: AppColors.textSecondary,
                            size: 12,
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}