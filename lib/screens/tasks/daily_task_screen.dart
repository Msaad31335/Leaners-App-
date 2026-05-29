import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/ai_service.dart';

// ─── LESSON STEPS ─────────────────────────────────────
enum LessonStep {
  loading,
  theory1,      // First theory block
  midQuiz,      // Mid lesson quiz (2 questions)
  theory2,      // Second theory block
  codeExample,  // Code example
  finalQuiz,    // Final quiz (3 questions)
  complete,     // Completion screen
  error,
}

// ─── MAIN SCREEN ──────────────────────────────────────
class DailyTaskScreen extends StatefulWidget {
  final String skillId;
  final String skillName;
  final int topicIndex;

  const DailyTaskScreen({
    super.key,
    required this.skillId,
    required this.skillName,
    this.topicIndex = 0,
  });

  @override
  State<DailyTaskScreen> createState() => _DailyTaskScreenState();
}

class _DailyTaskScreenState extends State<DailyTaskScreen> {
  final AIService _aiService = AIService();
  LessonContent? _lesson;
  LessonStep _step = LessonStep.loading;
  String _errorMessage = '';

  // Quiz state
  int _quizIndex = 0;
  int? _selectedAnswer;
  bool _answered = false;
  bool _isCorrect = false;
  int _totalXP = 0;
  int _correctAnswers = 0;

  // Mid quiz tracking
  List<AIQuestion> _currentQuizList = [];
  bool _inMidQuiz = true;

  @override
  void initState() {
    super.initState();
    _loadLesson();
  }

  Future<void> _loadLesson() async {
    setState(() => _step = LessonStep.loading);

    try {
      final topics = _aiService.getTopicsForSkill(widget.skillId);
      final topicIndex = widget.topicIndex % topics.length;
      final topic = topics[topicIndex];

      final lesson = await _aiService.generateLesson(
        skill: widget.skillName,
        topic: topic,
      );

      setState(() {
        _lesson = lesson;
        _step = LessonStep.theory1;
      });
    } catch (e) {
      setState(() {
        _step = LessonStep.error;
        _errorMessage = e.toString();
      });
    }
  }

  void _goToMidQuiz() {
    setState(() {
      _step = LessonStep.midQuiz;
      _currentQuizList = _lesson!.midQuiz;
      _quizIndex = 0;
      _selectedAnswer = null;
      _answered = false;
      _inMidQuiz = true;
    });
  }

  void _goToTheory2() {
    setState(() {
      _step = LessonStep.theory2;
    });
  }

  void _goToCodeExample() {
    setState(() {
      _step = LessonStep.codeExample;
    });
  }

  void _goToFinalQuiz() {
    setState(() {
      _step = LessonStep.finalQuiz;
      _currentQuizList = _lesson!.finalQuiz;
      _quizIndex = 0;
      _selectedAnswer = null;
      _answered = false;
      _inMidQuiz = false;
    });
  }

  void _selectAnswer(int index) {
    if (_answered) return;
    final correct = _currentQuizList[_quizIndex].correctIndex;
    final xp = _currentQuizList[_quizIndex].xp;

    setState(() {
      _selectedAnswer = index;
      _answered = true;
      _isCorrect = index == correct;
      if (_isCorrect) {
        _totalXP += xp;
        _correctAnswers++;
      }
    });
  }

  void _nextQuizQuestion() {
    if (_quizIndex < _currentQuizList.length - 1) {
      setState(() {
        _quizIndex++;
        _selectedAnswer = null;
        _answered = false;
        _isCorrect = false;
      });
    } else {
      // Quiz finished
      if (_inMidQuiz) {
        _goToTheory2();
      } else {
        _finishLesson();
      }
    }
  }

  Future<void> _finishLesson() async {
    setState(() => _step = LessonStep.complete);
    await context.read<AuthProvider>().addXP(_totalXP);
    await context.read<AuthProvider>().updateStreak();
  }

  // ─── PROGRESS ─────────────────────────────────────
  double get _overallProgress {
    switch (_step) {
      case LessonStep.loading: return 0.0;
      case LessonStep.theory1: return 0.1;
      case LessonStep.midQuiz: return 0.3 + (_quizIndex / (_lesson?.midQuiz.length ?? 1)) * 0.2;
      case LessonStep.theory2: return 0.55;
      case LessonStep.codeExample: return 0.7;
      case LessonStep.finalQuiz: return 0.75 + (_quizIndex / (_lesson?.finalQuiz.length ?? 1)) * 0.2;
      case LessonStep.complete: return 1.0;
      case LessonStep.error: return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _step != LessonStep.loading && _step != LessonStep.complete && _step != LessonStep.error
          ? _buildAppBar()
          : null,
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _overallProgress,
              backgroundColor: AppColors.card,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _lesson?.topic ?? widget.skillName,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.xpColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$_totalXP XP',
            style: const TextStyle(color: AppColors.xpColor, fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    switch (_step) {
      case LessonStep.loading:
        return _buildLoadingScreen();
      case LessonStep.theory1:
        return _buildTheory1();
      case LessonStep.midQuiz:
        return _buildQuizScreen(isMid: true);
      case LessonStep.theory2:
        return _buildTheory2();
      case LessonStep.codeExample:
        return _buildCodeExample();
      case LessonStep.finalQuiz:
        return _buildQuizScreen(isMid: false);
      case LessonStep.complete:
        return _buildCompleteScreen();
      case LessonStep.error:
        return _buildErrorScreen();
    }
  }

  // ─── LOADING ──────────────────────────────────────
  Widget _buildLoadingScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.purple, size: 44),
            ),
            const SizedBox(height: 28),
            const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
            const SizedBox(height: 20),
            Text(
              'AI is preparing your lesson...',
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Generating theory, examples\nand personalized quizzes for you',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ─── THEORY 1 ─────────────────────────────────────
  Widget _buildTheory1() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: FadeInUp(
          duration: const Duration(milliseconds: 400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Topic header
              _buildTopicHeader(),
              const SizedBox(height: 20),

              // Part 1 label
              _buildSectionLabel('📖 Introduction', Colors.blue),
              const SizedBox(height: 12),

              // Theory content
              _buildContentCard(_lesson!.theoryPart1),
              const SizedBox(height: 32),

              // Quick check label
              _buildSectionLabel('✅ Quick Check', AppColors.primary),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: const Text(
                  'Let\'s test what you just learned with a quick quiz!',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                ),
              ),
              const SizedBox(height: 32),

              _buildNextButton('Start Quick Quiz 🧠', _goToMidQuiz),
            ],
          ),
        ),
      ),
    );
  }

  // ─── THEORY 2 ─────────────────────────────────────
  Widget _buildTheory2() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: FadeInUp(
          duration: const Duration(milliseconds: 400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionLabel('📚 Deeper Understanding', Colors.orange),
              const SizedBox(height: 12),
              _buildContentCard(_lesson!.theoryPart2),
              const SizedBox(height: 32),
              _buildNextButton('See Code Example 💻', _goToCodeExample),
            ],
          ),
        ),
      ),
    );
  }

  // ─── CODE EXAMPLE ─────────────────────────────────
  Widget _buildCodeExample() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: FadeInUp(
          duration: const Duration(milliseconds: 400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionLabel('💻 Code Example', Colors.green),
              const SizedBox(height: 12),

              // Code block
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12, height: 12,
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 12, height: 12,
                          decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 12, height: 12,
                          decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${widget.skillName.toLowerCase()}_example',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _lesson!.codeExample,
                      style: const TextStyle(
                        color: Color(0xFF9CDCFE),
                        fontFamily: 'monospace',
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lightbulb_rounded, color: Colors.green, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Study this example carefully. The final quiz will test your understanding!',
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _buildNextButton('Take Final Quiz 🎯', _goToFinalQuiz),
            ],
          ),
        ),
      ),
    );
  }

  // ─── QUIZ SCREEN ──────────────────────────────────
  Widget _buildQuizScreen({required bool isMid}) {
    final question = _currentQuizList[_quizIndex];
    final total = _currentQuizList.length;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quiz header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isMid ? Colors.blue.withOpacity(0.15) : Colors.purple.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isMid ? '⚡ Quick Check' : '🎯 Final Quiz',
                    style: TextStyle(
                      color: isMid ? Colors.blue : Colors.purple,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${_quizIndex + 1} / $total',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Question
            FadeInDown(
              key: ValueKey(_quizIndex),
              duration: const Duration(milliseconds: 300),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  question.question,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Options
            Expanded(
              child: ListView.builder(
                itemCount: question.options.length,
                itemBuilder: (context, index) {
                  Color borderColor = Colors.transparent;
                  Color bgColor = AppColors.surface;
                  Color textColor = AppColors.textPrimary;

                  if (_answered) {
                    if (index == question.correctIndex) {
                      borderColor = AppColors.success;
                      bgColor = AppColors.success.withOpacity(0.15);
                      textColor = AppColors.success;
                    } else if (index == _selectedAnswer && !_isCorrect) {
                      borderColor = AppColors.error;
                      bgColor = AppColors.error.withOpacity(0.15);
                      textColor = AppColors.error;
                    }
                  }

                  return GestureDetector(
                    onTap: () => _selectAnswer(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor, width: 2),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: borderColor == Colors.transparent
                                  ? AppColors.card
                                  : borderColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                ['A', 'B', 'C', 'D'][index],
                                style: TextStyle(
                                  color: borderColor == Colors.transparent
                                      ? AppColors.textSecondary
                                      : borderColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              question.options[index],
                              style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                          ),
                          if (_answered && index == question.correctIndex)
                            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22),
                          if (_answered && index == _selectedAnswer && !_isCorrect)
                            const Icon(Icons.cancel_rounded, color: AppColors.error, size: 22),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Explanation + Next
            if (_answered) ...[
              FadeInUp(
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _isCorrect
                        ? AppColors.success.withOpacity(0.15)
                        : AppColors.error.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        _isCorrect ? Icons.check_circle_rounded : Icons.info_rounded,
                        color: _isCorrect ? AppColors.success : AppColors.error,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isCorrect ? 'Correct! +${question.xp} XP' : 'Not quite right',
                              style: TextStyle(
                                color: _isCorrect ? AppColors.success : AppColors.error,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              question.explanation,
                              style: TextStyle(
                                color: _isCorrect ? AppColors.success : AppColors.error,
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
              const SizedBox(height: 12),
              _buildNextButton(
                _quizIndex < _currentQuizList.length - 1
                    ? 'Next Question →'
                    : isMid
                        ? 'Continue Lesson 📚'
                        : 'See Results 🎉',
                _nextQuizQuestion,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── COMPLETE SCREEN ──────────────────────────────
  Widget _buildCompleteScreen() {
    final totalQuestions = (_lesson?.midQuiz.length ?? 0) + (_lesson?.finalQuiz.length ?? 0);
    final percentage = totalQuestions > 0
        ? (_correctAnswers / totalQuestions * 100).toInt()
        : 0;

    String emoji = percentage >= 80 ? '🎉' : percentage >= 60 ? '👍' : '💪';
    String message = percentage >= 80 ? 'Excellent!' : percentage >= 60 ? 'Good Job!' : 'Keep Practicing!';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: FadeInUp(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 80)),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Lesson Complete: ${_lesson?.topic ?? ''}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Stats
              Row(
                children: [
                  _ResultStat(label: 'Score', value: '$_correctAnswers/$totalQuestions', icon: '🎯'),
                  const SizedBox(width: 12),
                  _ResultStat(label: 'XP Earned', value: '+$_totalXP', icon: '⭐'),
                  const SizedBox(width: 12),
                  _ResultStat(label: 'Accuracy', value: '$percentage%', icon: '📊'),
                ],
              ),
              const SizedBox(height: 20),

              // AI badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.purple, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Lesson & Quiz generated by AI',
                      style: TextStyle(color: Colors.purple, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Back to home button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Try next topic
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DailyTaskScreen(
                        skillId: widget.skillId,
                        skillName: widget.skillName,
                        topicIndex: widget.topicIndex + 1,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Next Topic →',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── ERROR SCREEN ─────────────────────────────────
  Widget _buildErrorScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('😕', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            const Text(
              'Could not load lesson',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadLesson,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Try Again', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back', style: TextStyle(color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── REUSABLE WIDGETS ─────────────────────────────
  Widget _buildTopicHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.2), AppColors.primary.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.skillName,
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.purple, size: 12),
                    SizedBox(width: 4),
                    Text('AI Lesson', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.w700, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _lesson?.topic ?? '',
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          const Text(
            'Theory → Quick Quiz → More Theory → Code → Final Quiz',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13),
      ),
    );
  }

  Widget _buildContentCard(String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        content,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          height: 1.7,
        ),
      ),
    );
  }

  Widget _buildNextButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}

// ─── RESULT STAT WIDGET ───────────────────────────────
class _ResultStat extends StatelessWidget {
  final String label, value, icon;
  const _ResultStat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800)),
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}