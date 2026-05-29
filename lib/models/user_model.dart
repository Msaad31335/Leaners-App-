class UserModel {
  final String id;
  final String name;
  final String email;
  final int streakCount;
  final int bestStreak;
  final int xp;
  final int level;
  final List<String> selectedSkills;
  final String lastActiveDate;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.streakCount    = 0,
    this.bestStreak     = 0,
    this.xp             = 0,
    this.level          = 1,
    this.selectedSkills = const [],
    this.lastActiveDate = '',
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id:             map['id']?.toString() ?? '',
      name:           map['name']?.toString() ?? '',
      email:          map['email']?.toString() ?? '',
      streakCount:    (map['streak_current'] as num?)?.toInt() ?? 0,
      bestStreak:     (map['streak_best'] as num?)?.toInt() ?? 0,
      xp:             (map['xp'] as num?)?.toInt() ?? 0,
      level:          (map['level'] as num?)?.toInt() ?? 1,
      selectedSkills: List<String>.from(map['selected_skills'] ?? []),
      lastActiveDate: map['last_active_date']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id':               id,
      'name':             name,
      'email':            email,
      'streak_current':   streakCount,
      'streak_best':      bestStreak,
      'xp':               xp,
      'level':            level,
      'selected_skills':  selectedSkills,
      'last_active_date': lastActiveDate,
    };
  }
}