class ProgressModel {
  final String id;
  final String userId;
  final String lessonId;
  final String skillId;
  final bool completed;
  final int score;
  final int xpEarned;
  final int attempts;
  final String? completedAt;
  final String createdAt;

  ProgressModel({
    required this.id,
    required this.userId,
    required this.lessonId,
    required this.skillId,
    this.completed = false,
    this.score = 0,
    this.xpEarned = 0,
    this.attempts = 0,
    this.completedAt,
    required this.createdAt,
  });

  factory ProgressModel.fromMap(Map<String, dynamic> map) {
    return ProgressModel(
      id:          map['id'] as String,
      userId:      map['user_id'] as String,
      lessonId:    map['lesson_id'] as String,
      skillId:     map['skill_id'] as String,
      completed:   map['completed'] as bool? ?? false,
      score:       map['score'] as int? ?? 0,
      xpEarned:    map['xp_earned'] as int? ?? 0,
      attempts:    map['attempts'] as int? ?? 0,
      completedAt: map['completed_at'] as String?,
      createdAt:   map['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id':           id,
      'user_id':      userId,
      'lesson_id':    lessonId,
      'skill_id':     skillId,
      'completed':    completed,
      'score':        score,
      'xp_earned':    xpEarned,
      'attempts':     attempts,
      'completed_at': completedAt,
    };
  }

  ProgressModel copyWith({
    bool? completed,
    int? score,
    int? xpEarned,
    int? attempts,
    String? completedAt,
  }) {
    return ProgressModel(
      id:          id,
      userId:      userId,
      lessonId:    lessonId,
      skillId:     skillId,
      completed:   completed ?? this.completed,
      score:       score ?? this.score,
      xpEarned:    xpEarned ?? this.xpEarned,
      attempts:    attempts ?? this.attempts,
      completedAt: completedAt ?? this.completedAt,
      createdAt:   createdAt,
    );
  }
}