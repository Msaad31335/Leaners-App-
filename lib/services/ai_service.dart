import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_config.dart';

// ─── MODELS ───────────────────────────────────────────

class LessonContent {
  final String topic;
  final String skill;
  final String theoryPart1;   // First explanation block
  final String theoryPart2;   // Second explanation block
  final String codeExample;   // Code example (if any)
  final List<AIQuestion> midQuiz;    // 2 questions in middle
  final List<AIQuestion> finalQuiz;  // 3 questions at end

  LessonContent({
    required this.topic,
    required this.skill,
    required this.theoryPart1,
    required this.theoryPart2,
    required this.codeExample,
    required this.midQuiz,
    required this.finalQuiz,
  });
}

class AIQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final int xp;

  AIQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.xp,
  });

  factory AIQuestion.fromJson(Map<String, dynamic> j) => AIQuestion(
    question: j['question'] ?? '',
    options: List<String>.from(j['options'] ?? []),
    correctIndex: j['correct_index'] ?? 0,
    explanation: j['explanation'] ?? '',
    xp: j['xp'] ?? 10,
  );
}

// ─── SERVICE ──────────────────────────────────────────

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  final Map<String, LessonContent> _cache = {};

  // Topics for each skill
  static const Map<String, List<String>> skillTopics = {
    'python': [
      'Introduction to Python',
      'Variables and Data Types',
      'Strings in Python',
      'Lists and Tuples',
      'Dictionaries',
      'If Else Conditions',
      'For and While Loops',
      'Functions in Python',
      'File Handling',
      'Object Oriented Programming',
    ],
    'html': [
      'Introduction to HTML',
      'HTML Tags and Structure',
      'Headings and Paragraphs',
      'Links and Images',
      'HTML Lists',
      'HTML Tables',
      'HTML Forms',
      'Semantic HTML',
      'HTML5 Features',
      'HTML Best Practices',
    ],
    'javascript': [
      'Introduction to JavaScript',
      'Variables let const var',
      'Functions and Arrow Functions',
      'Arrays and Methods',
      'Objects and JSON',
      'DOM Manipulation',
      'Events',
      'Promises and Async Await',
      'ES6 Features',
      'Error Handling',
    ],
    'java': [
      'Introduction to Java',
      'Variables and Data Types',
      'Control Flow',
      'Arrays in Java',
      'Object Oriented Programming',
      'Classes and Objects',
      'Inheritance',
      'Interfaces',
      'Exception Handling',
      'Collections Framework',
    ],
    'dsa': [
      'Introduction to Data Structures',
      'Arrays',
      'Linked Lists',
      'Stacks',
      'Queues',
      'Trees',
      'Binary Search Trees',
      'Graphs',
      'Sorting Algorithms',
      'Searching Algorithms',
    ],
    'git': [
      'Introduction to Git',
      'Git Installation and Setup',
      'Git Init and Clone',
      'Git Add and Commit',
      'Git Branches',
      'Git Merge',
      'Git Push and Pull',
      'GitHub Basics',
      'Pull Requests',
      'Git Best Practices',
    ],
    'database': [
      'Introduction to Databases',
      'SQL Basics',
      'SELECT Statement',
      'WHERE Clause',
      'JOIN Operations',
      'INSERT UPDATE DELETE',
      'Primary and Foreign Keys',
      'Indexes',
      'Normalization',
      'NoSQL Databases',
    ],
  };

  // GET TOPICS FOR A SKILL
  List<String> getTopicsForSkill(String skillId) {
    return skillTopics[skillId.toLowerCase()] ??
        skillTopics['python']!;
  }

  // GENERATE FULL LESSON (theory + mid quiz + final quiz)
  Future<LessonContent> generateLesson({
    required String skill,
    required String topic,
  }) async {
    final cacheKey = '${skill}_$topic';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final lesson = await _callOpenAIForLesson(skill: skill, topic: topic);
      _cache[cacheKey] = lesson;
      return lesson;
    } catch (e) {
      // Return fallback if API fails
      return _getFallbackLesson(skill: skill, topic: topic);
    }
  }

  Future<LessonContent> _callOpenAIForLesson({
    required String skill,
    required String topic,
  }) async {
    final prompt = '''
Create a complete lesson about "$topic" for learning "$skill" programming.

Return ONLY this exact JSON format (no markdown, no extra text):

{
  "theory_part1": "First explanation paragraph about $topic (3-4 sentences, beginner friendly)",
  "theory_part2": "Second deeper explanation paragraph (3-4 sentences, with more detail)",
  "code_example": "A simple code example showing $topic (use actual code, keep it short)",
  "mid_quiz": [
    {
      "question": "A question about basic $topic concept?",
      "options": ["Option A", "Option B", "Option C", "Option D"],
      "correct_index": 0,
      "explanation": "Why this is correct in one sentence",
      "xp": 10
    },
    {
      "question": "Another question about $topic?",
      "options": ["Option A", "Option B", "Option C", "Option D"],
      "correct_index": 1,
      "explanation": "Why this is correct in one sentence",
      "xp": 10
    }
  ],
  "final_quiz": [
    {
      "question": "A medium difficulty question about $topic?",
      "options": ["Option A", "Option B", "Option C", "Option D"],
      "correct_index": 2,
      "explanation": "Why this is correct in one sentence",
      "xp": 15
    },
    {
      "question": "A harder question about $topic application?",
      "options": ["Option A", "Option B", "Option C", "Option D"],
      "correct_index": 0,
      "explanation": "Why this is correct in one sentence",
      "xp": 15
    },
    {
      "question": "A practical question about $topic?",
      "options": ["Option A", "Option B", "Option C", "Option D"],
      "correct_index": 3,
      "explanation": "Why this is correct in one sentence",
      "xp": 20
    }
  ]
}

Rules:
- Return ONLY valid JSON, nothing else
- All questions must be about $topic in $skill
- correct_index must be 0, 1, 2, or 3
- Make questions different from each other
- Keep explanations short and clear
''';

    final response = await http.post(
      Uri.parse(ApiConfig.openAiBaseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ApiConfig.openAiKey}',
      },
      body: jsonEncode({
        'model': ApiConfig.openAiModel,
        'max_tokens': 1500,
        'temperature': 0.7,
        'messages': [
          {
            'role': 'system',
            'content': 'You are a CS education expert. Return ONLY valid JSON. No markdown, no code blocks, no extra text.',
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String content = data['choices'][0]['message']['content'] as String;

      // Clean any markdown if present
      content = content.trim();
      if (content.startsWith('```')) {
        content = content
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
      }

      final Map<String, dynamic> json = jsonDecode(content);

      return LessonContent(
        topic: topic,
        skill: skill,
        theoryPart1: json['theory_part1'] ?? '',
        theoryPart2: json['theory_part2'] ?? '',
        codeExample: json['code_example'] ?? '',
        midQuiz: (json['mid_quiz'] as List)
            .map((q) => AIQuestion.fromJson(q))
            .toList(),
        finalQuiz: (json['final_quiz'] as List)
            .map((q) => AIQuestion.fromJson(q))
            .toList(),
      );
    } else if (response.statusCode == 401) {
      throw Exception('Invalid OpenAI API key. Check api_config.dart');
    } else if (response.statusCode == 429) {
      throw Exception('Rate limit reached. Try again in a moment.');
    } else {
      throw Exception('API error ${response.statusCode}');
    }
  }

  // FALLBACK if API fails
  LessonContent _getFallbackLesson({
    required String skill,
    required String topic,
  }) {
    return LessonContent(
      topic: topic,
      skill: skill,
      theoryPart1:
          '$topic is a fundamental concept in $skill programming. '
          'Understanding this concept is essential for writing good code. '
          'It helps you solve problems more efficiently and write cleaner programs.',
      theoryPart2:
          'When working with $topic in $skill, there are several important things to keep in mind. '
          'Practice is key to mastering this concept. '
          'The more you use it, the more natural it becomes. '
          'Many real-world programs rely heavily on this concept.',
      codeExample:
          '# Example of $topic in $skill\n'
          '# This is a simple demonstration\n'
          'print("Learning $topic in $skill")',
      midQuiz: [
        AIQuestion(
          question: 'What is $topic in $skill?',
          options: [
            'A fundamental concept',
            'A type of error',
            'A database',
            'An operating system',
          ],
          correctIndex: 0,
          explanation: '$topic is a fundamental concept in $skill programming.',
          xp: 10,
        ),
        AIQuestion(
          question: 'Why is $topic important in $skill?',
          options: [
            'It is not important',
            'Only for advanced users',
            'It helps write better code',
            'Only for web development',
          ],
          correctIndex: 2,
          explanation: '$topic helps write more efficient and cleaner code.',
          xp: 10,
        ),
      ],
      finalQuiz: [
        AIQuestion(
          question: 'How do you use $topic in $skill?',
          options: [
            'By ignoring it',
            'By practicing regularly',
            'Only in large projects',
            'Only with frameworks',
          ],
          correctIndex: 1,
          explanation: 'Regular practice is the best way to master $topic.',
          xp: 15,
        ),
        AIQuestion(
          question: 'Which best describes $topic?',
          options: [
            'A core programming concept',
            'An optional feature',
            'Only for professionals',
            'A hardware component',
          ],
          correctIndex: 0,
          explanation: '$topic is a core concept every programmer should know.',
          xp: 15,
        ),
        AIQuestion(
          question: 'When should you use $topic in $skill?',
          options: [
            'Never',
            'Only in advanced programs',
            'When solving related problems',
            'Only in team projects',
          ],
          correctIndex: 2,
          explanation: 'Use $topic whenever it helps solve the problem at hand.',
          xp: 20,
        ),
      ],
    );
  }

  void clearCache() => _cache.clear();
}