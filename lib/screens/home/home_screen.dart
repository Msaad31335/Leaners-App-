import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../tasks/daily_task_screen.dart';
import '../progress/progress_screen.dart';
import '../profile/profile_screen.dart';
import '../leaderboard/leaderboard_screen.dart';

class HomeScreen extends StatefulWidget {
  final List<String> selectedSkills;
  const HomeScreen({super.key, this.selectedSkills = const []});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      _HomeDashboard(selectedSkills: widget.selectedSkills),
      const DailyTaskScreen(skillId: 'python', skillName: 'Python'),
      const LeaderboardScreen(),
      const ProgressScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded),        label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.task_alt_rounded),    label: 'Tasks'),
            BottomNavigationBarItem(icon: Icon(Icons.leaderboard_rounded), label: 'Ranks'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded),   label: 'Progress'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded),      label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class _HomeDashboard extends StatelessWidget {
  final List<String> selectedSkills;
  const _HomeDashboard({required this.selectedSkills});

  final List<Map<String, dynamic>> allSkills = const [
    {'id': 'python',     'name': 'Python'},
    {'id': 'html',       'name': 'HTML / CSS'},
    {'id': 'javascript', 'name': 'JavaScript'},
    {'id': 'java',       'name': 'Java'},
    {'id': 'cpp',        'name': 'C++'},
    {'id': 'dsa',        'name': 'Data Structures'},
    {'id': 'sql',        'name': 'SQL'},
    {'id': 'git',        'name': 'Git & GitHub'},
    {'id': 'aiml',       'name': 'AI / ML'},
    {'id': 'sap',        'name': 'SAP ERP'},
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final mySkills = allSkills
        .where((s) => selectedSkills.contains(s['id']))
        .toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // ── Header ───────────────────────────────────
            FadeInDown(
              duration: const Duration(milliseconds: 600),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Good Morning',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(
                        user?.name ?? 'Learner',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.notifications_rounded,
                        color: AppColors.primary, size: 24),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Stats Row ────────────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: Row(
                children: [
                  Expanded(child: _StatCard(icon: Icons.local_fire_department_rounded, label: 'Streak',   value: '${user?.streakCount ?? 0}', color: AppColors.streakColor)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(icon: Icons.star_rounded,           label: 'Total XP', value: '${user?.xp ?? 0}',          color: AppColors.xpColor)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(icon: Icons.emoji_events_rounded,   label: 'Level',    value: '${user?.level ?? 1}',        color: AppColors.primary)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Daily Goal Card ──────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Daily Goal',  style: TextStyle(color: Colors.white,   fontSize: 16, fontWeight: FontWeight.w700)),
                        Text('2 / 5 Tasks', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: const LinearProgressIndicator(
                        value: 0.4,
                        backgroundColor: Colors.white30,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('40% complete - Keep going!',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── My Skills ────────────────────────────────
            if (mySkills.isNotEmpty) ...[
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: const Text('My Skills',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                delay: const Duration(milliseconds: 350),
                child: Column(
                  children: mySkills
                      .map((skill) => _SkillProgressCard(skill: skill))
                      .toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ── Continue Learning ────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: const Text('Continue Learning',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 12),

            FadeInUp(
              delay: const Duration(milliseconds: 450),
              child: Column(
                children: [
                  _LessonCard(
                    title: 'Python Basics',
                    subtitle: 'Lesson 4 - Variables and Types',
                    icon: Icons.code_rounded,
                    xp: 20,
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const DailyTaskScreen(skillId: 'python', skillName: 'Python'),
                    )),
                  ),
                  const SizedBox(height: 10),
                  _LessonCard(
                    title: 'HTML Fundamentals',
                    subtitle: 'Lesson 2 - Tags and Structure',
                    icon: Icons.language_rounded,
                    xp: 15,
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const DailyTaskScreen(skillId: 'html', skillName: 'HTML'),
                    )),
                  ),
                  const SizedBox(height: 10),
                  _LessonCard(
                    title: 'JavaScript Intro',
                    subtitle: 'Lesson 1 - Variables',
                    icon: Icons.javascript_rounded,
                    xp: 15,
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const DailyTaskScreen(skillId: 'javascript', skillName: 'JavaScript'),
                    )),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Stat Card ────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── Skill Progress Card ──────────────────────────────────────
class _SkillProgressCard extends StatelessWidget {
  final Map<String, dynamic> skill;
  const _SkillProgressCard({required this.skill});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.code_rounded, color: AppColors.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(skill['name'],
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    value: 0.3,
                    backgroundColor: AppColors.card,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                const Text('30% complete',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textSecondary, size: 14),
        ],
      ),
    );
  }
}

// ── Lesson Card ──────────────────────────────────────────────
class _LessonCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final int xp;
  final VoidCallback onTap;

  const _LessonCard({required this.title, required this.subtitle, required this.icon, required this.xp, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primary, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,    style: const TextStyle(color: AppColors.textPrimary,   fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.xpColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('+$xp XP',
                  style: const TextStyle(color: AppColors.xpColor, fontWeight: FontWeight.w700, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}