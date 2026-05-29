class LessonModel {
  final String id;
  final String skillId;
  final String title;
  final String content;
  final String type;
  final String difficulty;
  final String? question;
  final List<String> options;
  final String? correctAnswer;
  final String? explanation;
  final int xpReward;
  final int orderIndex;
  final int dayNumber;
  final bool isActive;

  LessonModel({
    required this.id,
    required this.skillId,
    required this.title,
    required this.content,
    required this.type,
    required this.difficulty,
    this.question,
    this.options = const [],
    this.correctAnswer,
    this.explanation,
    this.xpReward = 10,
    this.orderIndex = 0,
    this.dayNumber = 1,
    this.isActive = true,
  });

  factory LessonModel.fromMap(Map<String, dynamic> map) {
    return LessonModel(
      id:            map['id'] as String,
      skillId:       map['skill_id'] as String,
      title:         map['title'] as String,
      content:       map['content'] as String? ?? '',
      type:          map['type'] as String? ?? 'quiz',
      difficulty:    map['difficulty'] as String? ?? 'easy',
      question:      map['question'] as String?,
      options:       map['options'] != null
                       ? List<String>.from(map['options'])
                       : [],
      correctAnswer: map['correct_answer'] as String?,
      explanation:   map['explanation'] as String?,
      xpReward:      map['xp_reward'] as int? ?? 10,
      orderIndex:    map['order_index'] as int? ?? 0,
      dayNumber:     map['day_number'] as int? ?? 1,
      isActive:      map['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id':             id,
      'skill_id':       skillId,
      'title':          title,
      'content':        content,
      'type':           type,
      'difficulty':     difficulty,
      'question':       question,
      'options':        options,
      'correct_answer': correctAnswer,
      'explanation':    explanation,
      'xp_reward':      xpReward,
      'order_index':    orderIndex,
      'day_number':     dayNumber,
      'is_active':      isActive,
    };
  }

  bool get isEasy   => difficulty == 'easy';
  bool get isMedium => difficulty == 'medium';
  bool get isHard   => difficulty == 'hard';
  bool get isQuiz   => type == 'quiz';
}