import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> weeklyLeaders = [
    {'rank': 1, 'name': 'Ahmed Khan', 'xp': 2400, 'streak': 14, 'level': 5},
    {'rank': 2, 'name': 'Sara Ali', 'xp': 2100, 'streak': 12, 'level': 4},
    {'rank': 3, 'name': 'Bilal Raza', 'xp': 1850, 'streak': 10, 'level': 4},
    {'rank': 4, 'name': 'Fatima Noor', 'xp': 1600, 'streak': 8, 'level': 3},
    {'rank': 5, 'name': 'Usman Tariq', 'xp': 1400, 'streak': 7, 'level': 3},
    {'rank': 6, 'name': 'Ayesha Malik', 'xp': 1200, 'streak': 6, 'level': 3},
    {'rank': 7, 'name': 'Zaid Hussain', 'xp': 1050, 'streak': 5, 'level': 2},
    {'rank': 8, 'name': 'Hina Baig', 'xp': 900, 'streak': 4, 'level': 2},
    {'rank': 9, 'name': 'Omar Sheikh', 'xp': 750, 'streak': 3, 'level': 2},
    {'rank': 10, 'name': 'Nadia Qureshi', 'xp': 600, 'streak': 2, 'level': 1},
  ];

  final List<Map<String, dynamic>> allTimeLeaders = [
    {'rank': 1, 'name': 'Ahmed Khan', 'xp': 12400, 'streak': 45, 'level': 12},
    {'rank': 2, 'name': 'Fatima Noor', 'xp': 10800, 'streak': 38, 'level': 11},
    {'rank': 3, 'name': 'Sara Ali', 'xp': 9500, 'streak': 32, 'level': 10},
    {'rank': 4, 'name': 'Bilal Raza', 'xp': 8200, 'streak': 28, 'level': 9},
    {'rank': 5, 'name': 'Usman Tariq', 'xp': 7100, 'streak': 24, 'level': 8},
    {'rank': 6, 'name': 'Ayesha Malik', 'xp': 6400, 'streak': 20, 'level': 7},
    {'rank': 7, 'name': 'Zaid Hussain', 'xp': 5500, 'streak': 18, 'level': 6},
    {'rank': 8, 'name': 'Hina Baig', 'xp': 4800, 'streak': 15, 'level': 5},
    {'rank': 9, 'name': 'Omar Sheikh', 'xp': 3900, 'streak': 12, 'level': 4},
    {'rank': 10, 'name': 'Nadia Qureshi', 'xp': 3100, 'streak': 9, 'level': 3},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 20),
              child: FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Leaderboard',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.xpColor,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${user?.xp ?? 0} XP',
                            style: const TextStyle(
                              color: AppColors.xpColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Top 3 Podium
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 100),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildPodium(),
              ),
            ),

            const SizedBox(height: 24),

            // Tab Bar
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 200),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  tabs: const [
                    Tab(text: 'This Week'),
                    Tab(text: 'All Time'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // My Rank Card
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 250),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            '#11',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'You',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const Text(
                              'Your current rank',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${user?.xp ?? 0} XP',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Level ${user?.level ?? 1}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Leaders List
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLeaderList(weeklyLeaders),
                  _buildLeaderList(allTimeLeaders),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodium() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2nd Place
        Expanded(
          child: _PodiumCard(
            rank: 2,
            name: weeklyLeaders[1]['name'],
            xp: weeklyLeaders[1]['xp'],
            height: 90,
            color: const Color(0xFF9CA3AF),
            rankColor: const Color(0xFF9CA3AF),
          ),
        ),
        const SizedBox(width: 8),
        // 1st Place
        Expanded(
          child: _PodiumCard(
            rank: 1,
            name: weeklyLeaders[0]['name'],
            xp: weeklyLeaders[0]['xp'],
            height: 120,
            color: const Color(0xFFFFB800),
            rankColor: const Color(0xFFFFB800),
          ),
        ),
        const SizedBox(width: 8),
        // 3rd Place
        Expanded(
          child: _PodiumCard(
            rank: 3,
            name: weeklyLeaders[2]['name'],
            xp: weeklyLeaders[2]['xp'],
            height: 70,
            color: const Color(0xFFCD7F32),
            rankColor: const Color(0xFFCD7F32),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderList(List<Map<String, dynamic>> leaders) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: leaders.length,
      itemBuilder: (context, index) {
        final leader = leaders[index];
        final rank = leader['rank'] as int;

        Color rankColor = AppColors.textSecondary;
        if (rank == 1) rankColor = const Color(0xFFFFB800);
        if (rank == 2) rankColor = const Color(0xFF9CA3AF);
        if (rank == 3) rankColor = const Color(0xFFCD7F32);

        return FadeInUp(
          duration: const Duration(milliseconds: 300),
          delay: Duration(milliseconds: index * 50),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: rank <= 3
                  ? rankColor.withOpacity(0.08)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: rank <= 3
                    ? rankColor.withOpacity(0.3)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                // Rank
                SizedBox(
                  width: 32,
                  child: rank <= 3
                      ? Icon(
                          Icons.emoji_events_rounded,
                          color: rankColor,
                          size: 24,
                        )
                      : Text(
                          '#$rank',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                ),
                const SizedBox(width: 12),

                // Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      (leader['name'] as String)[0],
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name + Level
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        leader['name'],
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Level ${leader['level']}  •  ${leader['streak']} day streak',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                // XP
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${leader['xp']}',
                      style: TextStyle(
                        color: rank <= 3 ? rankColor : AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const Text(
                      'XP',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PodiumCard extends StatelessWidget {
  final int rank;
  final String name;
  final int xp;
  final double height;
  final Color color;
  final Color rankColor;

  const _PodiumCard({
    required this.rank,
    required this.name,
    required this.xp,
    required this.height,
    required this.color,
    required this.rankColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              name[0],
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name.split(' ')[0],
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          '$xp XP',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            border: Border.all(
              color: color.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}