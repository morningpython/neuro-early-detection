/// Training Screen
/// STORY-023: CHW Training Module
///
/// 지역보건요원(CHW) 교육 화면입니다.
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/training_module.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  final List<TrainingModule> _modules = TrainingContent.getModules();
  Map<String, LessonStatus> _progress = {};

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, LessonStatus> progress = {};
    
    for (final module in _modules) {
      for (final lesson in module.lessons) {
        final key = '${module.id}_${lesson.id}';
        final statusIndex = prefs.getInt(key) ?? 0;
        progress[key] = LessonStatus.values[statusIndex.clamp(0, LessonStatus.values.length - 1)];
      }
    }
    
    // 첫 번째 레슨은 항상 사용 가능
    if (progress.isNotEmpty) {
      final firstKey = '${_modules.first.id}_${_modules.first.lessons.first.id}';
      if (progress[firstKey] == LessonStatus.locked) {
        progress[firstKey] = LessonStatus.available;
      }
    }
    
    setState(() => _progress = progress);
  }

  Future<void> _saveProgress(String moduleId, String lessonId, LessonStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${moduleId}_$lessonId';
    await prefs.setInt(key, status.index);
    setState(() => _progress[key] = status);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.training),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _modules.length,
        itemBuilder: (context, index) {
          final module = _modules[index];
          return _ModuleCard(
            module: module,
            locale: locale,
            progress: _progress,
            onLessonTap: (lesson) => _openLesson(module, lesson),
          );
        },
      ),
    );
  }

  void _openLesson(TrainingModule module, TrainingLesson lesson) {
    final key = '${module.id}_${lesson.id}';
    final status = _progress[key] ?? LessonStatus.locked;
    
    if (status == LessonStatus.locked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이전 레슨을 먼저 완료해주세요.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 진행 중으로 상태 업데이트
    if (status == LessonStatus.available) {
      _saveProgress(module.id, lesson.id, LessonStatus.inProgress);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonScreen(
          module: module,
          lesson: lesson,
          onComplete: (score) => _completeLesson(module, lesson, score),
        ),
      ),
    );
  }

  void _completeLesson(TrainingModule module, TrainingLesson lesson, int score) {
    if (score >= lesson.requiredScore) {
      _saveProgress(module.id, lesson.id, LessonStatus.completed);
      
      // 다음 레슨 잠금 해제
      final lessonIndex = module.lessons.indexOf(lesson);
      if (lessonIndex < module.lessons.length - 1) {
        final nextLesson = module.lessons[lessonIndex + 1];
        _saveProgress(module.id, nextLesson.id, LessonStatus.available);
      } else {
        // 다음 모듈의 첫 레슨 잠금 해제
        final moduleIndex = _modules.indexOf(module);
        if (moduleIndex < _modules.length - 1) {
          final nextModule = _modules[moduleIndex + 1];
          _saveProgress(nextModule.id, nextModule.lessons.first.id, LessonStatus.available);
        }
      }
    }
  }
}

class _ModuleCard extends StatelessWidget {
  final TrainingModule module;
  final String locale;
  final Map<String, LessonStatus> progress;
  final void Function(TrainingLesson) onLessonTap;

  const _ModuleCard({
    required this.module,
    required this.locale,
    required this.progress,
    required this.onLessonTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completedCount = module.lessons.where((l) {
      final key = '${module.id}_${l.id}';
      return progress[key] == LessonStatus.completed;
    }).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 모듈 헤더
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: module.themeColor.withAlpha(25),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: module.themeColor.withAlpha(50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.school,
                    color: module.themeColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        module.getTitle(locale),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        module.getDescription(locale),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 진행률
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: module.lessons.isEmpty ? 0 : completedCount / module.lessons.length,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(module.themeColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$completedCount/${module.lessons.length}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: module.themeColor,
                  ),
                ),
              ],
            ),
          ),

          // 레슨 목록
          ...module.lessons.map((lesson) {
            final key = '${module.id}_${lesson.id}';
            final status = progress[key] ?? LessonStatus.locked;
            
            return _LessonTile(
              lesson: lesson,
              locale: locale,
              status: status,
              themeColor: module.themeColor,
              onTap: () => onLessonTap(lesson),
            );
          }),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  final TrainingLesson lesson;
  final String locale;
  final LessonStatus status;
  final Color themeColor;
  final VoidCallback onTap;

  const _LessonTile({
    required this.lesson,
    required this.locale,
    required this.status,
    required this.themeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = status == LessonStatus.locked;
    
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isLocked ? Colors.grey.shade200 : themeColor.withAlpha(25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          status.icon,
          color: isLocked ? Colors.grey : themeColor,
          size: 20,
        ),
      ),
      title: Text(
        lesson.getTitle(locale),
        style: TextStyle(
          color: isLocked ? Colors.grey : null,
          fontWeight: status == LessonStatus.completed ? FontWeight.w600 : null,
        ),
      ),
      subtitle: Row(
        children: [
          Icon(Icons.timer_outlined, size: 14, color: Colors.grey.shade500),
          const SizedBox(width: 4),
          Text(
            '${lesson.durationMinutes} min',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
          if (status == LessonStatus.completed) ...[
            const SizedBox(width: 12),
            Icon(Icons.check, size: 14, color: Colors.green.shade600),
            const SizedBox(width: 4),
            Text(
              locale == 'sw' ? 'Imekamilika' : 'Completed',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green.shade600,
              ),
            ),
          ],
        ],
      ),
      trailing: isLocked
          ? const Icon(Icons.lock_outline, size: 20, color: Colors.grey)
          : const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

/// 레슨 상세 화면
class LessonScreen extends StatefulWidget {
  final TrainingModule module;
  final TrainingLesson lesson;
  final void Function(int score) onComplete;

  const LessonScreen({
    super.key,
    required this.module,
    required this.lesson,
    required this.onComplete,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int _currentPage = 0;
  bool _showingQuiz = false;
  int _currentQuestion = 0;
  int _correctAnswers = 0;
  int? _selectedAnswer;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final contentItems = widget.lesson.getContentItems(locale);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.getTitle(locale)),
        backgroundColor: widget.module.themeColor.withAlpha(25),
      ),
      body: _showingQuiz ? _buildQuiz(locale) : _buildContent(contentItems, locale),
      bottomNavigationBar: _buildBottomBar(contentItems.length, locale),
    );
  }

  Widget _buildContent(List<String> contentItems, String locale) {
    return PageView.builder(
      itemCount: contentItems.length,
      onPageChanged: (index) => setState(() => _currentPage = index),
      itemBuilder: (context, index) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 진행 표시
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.module.themeColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${index + 1} / ${contentItems.length}',
                      style: TextStyle(
                        color: widget.module.themeColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // 콘텐츠
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: widget.module.themeColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        contentItems[index],
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 스와이프 힌트
              if (index < contentItems.length - 1)
                Center(
                  child: Text(
                    locale == 'sw' ? 'Telezesha kuendelea →' : 'Swipe to continue →',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuiz(String locale) {
    if (_currentQuestion >= widget.lesson.quiz.length) {
      return _buildQuizResults(locale);
    }

    final question = widget.lesson.quiz[_currentQuestion];
    final options = question.getOptions(locale);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 진행률
          LinearProgressIndicator(
            value: (_currentQuestion + 1) / widget.lesson.quiz.length,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(widget.module.themeColor),
          ),
          const SizedBox(height: 8),
          Text(
            '${locale == 'sw' ? 'Swali' : 'Question'} ${_currentQuestion + 1} / ${widget.lesson.quiz.length}',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          // 질문
          Text(
            question.getQuestion(locale),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),

          // 옵션
          ...options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = _selectedAnswer == index;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => setState(() => _selectedAnswer = index),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? widget.module.themeColor : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: isSelected ? widget.module.themeColor.withAlpha(12) : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? widget.module.themeColor : Colors.grey.shade400,
                          ),
                          color: isSelected ? widget.module.themeColor : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, size: 18, color: Colors.white)
                            : Center(
                                child: Text(
                                  String.fromCharCode(65 + index),
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(option, style: const TextStyle(fontSize: 16))),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 24),

          // 다음 버튼
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _selectedAnswer == null ? null : _submitAnswer,
              style: FilledButton.styleFrom(
                backgroundColor: widget.module.themeColor,
                padding: const EdgeInsets.all(16),
              ),
              child: Text(locale == 'sw' ? 'Wasilisha' : 'Submit'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizResults(String locale) {
    final score = ((_correctAnswers / widget.lesson.quiz.length) * 100).round();
    final passed = score >= widget.lesson.requiredScore;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              passed ? Icons.celebration : Icons.refresh,
              size: 80,
              color: passed ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 24),
            Text(
              passed
                  ? (locale == 'sw' ? 'Hongera! Umefaulu!' : 'Congratulations! You passed!')
                  : (locale == 'sw' ? 'Jaribu Tena' : 'Try Again'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${locale == 'sw' ? 'Alama' : 'Score'}: $score%',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: passed ? Colors.green : Colors.orange,
              ),
            ),
            Text(
              '$_correctAnswers / ${widget.lesson.quiz.length} ${locale == 'sw' ? 'sahihi' : 'correct'}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            if (passed)
              FilledButton.icon(
                onPressed: () {
                  widget.onComplete(score);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check),
                label: Text(locale == 'sw' ? 'Endelea' : 'Continue'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              )
            else
              FilledButton.icon(
                onPressed: () {
                  setState(() {
                    _currentQuestion = 0;
                    _correctAnswers = 0;
                    _selectedAnswer = null;
                  });
                },
                icon: const Icon(Icons.refresh),
                label: Text(locale == 'sw' ? 'Jaribu Tena' : 'Try Again'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _submitAnswer() {
    final question = widget.lesson.quiz[_currentQuestion];
    if (_selectedAnswer == question.correctAnswer) {
      _correctAnswers++;
    }

    setState(() {
      _currentQuestion++;
      _selectedAnswer = null;
    });
  }

  Widget _buildBottomBar(int totalPages, String locale) {
    if (_showingQuiz) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 페이지 인디케이터
            Expanded(
              child: Row(
                children: List.generate(
                  totalPages,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentPage
                          ? widget.module.themeColor
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
            ),
            
            // 퀴즈 시작 버튼
            if (_currentPage == totalPages - 1)
              FilledButton.icon(
                onPressed: () => setState(() => _showingQuiz = true),
                icon: const Icon(Icons.quiz),
                label: Text(locale == 'sw' ? 'Anza Jaribio' : 'Start Quiz'),
                style: FilledButton.styleFrom(
                  backgroundColor: widget.module.themeColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
