import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_access/models/training_module.dart';

void main() {
  group('LessonStatus', () {
    test('should have correct labels', () {
      expect(LessonStatus.locked.label, '잠금');
      expect(LessonStatus.available.label, '수강 가능');
      expect(LessonStatus.inProgress.label, '진행 중');
      expect(LessonStatus.completed.label, '완료');
    });

    test('should have correct icons', () {
      expect(LessonStatus.locked.icon, Icons.lock);
      expect(LessonStatus.available.icon, Icons.play_circle_outline);
      expect(LessonStatus.inProgress.icon, Icons.play_circle);
      expect(LessonStatus.completed.icon, Icons.check_circle);
    });
  });

  group('QuestionType', () {
    test('should have all types', () {
      expect(QuestionType.values.length, 3);
      expect(QuestionType.values, contains(QuestionType.multipleChoice));
      expect(QuestionType.values, contains(QuestionType.trueFalse));
      expect(QuestionType.values, contains(QuestionType.matching));
    });
  });

  group('QuizQuestion', () {
    test('should create with all fields', () {
      final question = QuizQuestion(
        id: 'q-001',
        question: 'What is Parkinson\'s?',
        questionSw: 'Parkinson ni nini?',
        type: QuestionType.multipleChoice,
        options: ['A', 'B', 'C', 'D'],
        optionsSw: ['A', 'B', 'C', 'D'],
        correctAnswer: 0,
        explanation: 'A is correct',
        explanationSw: 'A ni sahihi',
      );

      expect(question.id, 'q-001');
      expect(question.question, 'What is Parkinson\'s?');
      expect(question.correctAnswer, 0);
    });

    test('getQuestion should return locale-specific text', () {
      final question = QuizQuestion(
        id: 'q-001',
        question: 'English question',
        questionSw: 'Swahili question',
        type: QuestionType.trueFalse,
        options: ['True', 'False'],
        optionsSw: ['Kweli', 'Uongo'],
        correctAnswer: 0,
      );

      expect(question.getQuestion('en'), 'English question');
      expect(question.getQuestion('sw'), 'Swahili question');
    });

    test('getOptions should return locale-specific options', () {
      final question = QuizQuestion(
        id: 'q-001',
        question: 'Q',
        questionSw: 'Q',
        type: QuestionType.trueFalse,
        options: ['True', 'False'],
        optionsSw: ['Kweli', 'Uongo'],
        correctAnswer: 0,
      );

      expect(question.getOptions('en'), ['True', 'False']);
      expect(question.getOptions('sw'), ['Kweli', 'Uongo']);
    });
  });

  group('TrainingLesson', () {
    test('should create with all fields', () {
      final lesson = TrainingLesson(
        id: 'lesson-001',
        title: 'Introduction',
        titleSw: 'Utangulizi',
        description: 'Learn basics',
        descriptionSw: 'Jifunze misingi',
        durationMinutes: 30,
        iconName: 'school',
        contentItems: ['Item 1', 'Item 2'],
        contentItemsSw: ['Kipengele 1', 'Kipengele 2'],
        quiz: [],
        requiredScore: 70,
      );

      expect(lesson.id, 'lesson-001');
      expect(lesson.durationMinutes, 30);
      expect(lesson.requiredScore, 70);
    });

    test('getTitle should return locale-specific title', () {
      final lesson = TrainingLesson(
        id: 'lesson-001',
        title: 'English Title',
        titleSw: 'Swahili Title',
        description: '',
        descriptionSw: '',
        durationMinutes: 20,
        iconName: 'book',
        contentItems: [],
        contentItemsSw: [],
        quiz: [],
      );

      expect(lesson.getTitle('en'), 'English Title');
      expect(lesson.getTitle('sw'), 'Swahili Title');
    });

    test('getContentItems should return locale-specific content', () {
      final lesson = TrainingLesson(
        id: 'lesson-001',
        title: 'T',
        titleSw: 'T',
        description: 'D',
        descriptionSw: 'D',
        durationMinutes: 20,
        iconName: 'book',
        contentItems: ['En1', 'En2'],
        contentItemsSw: ['Sw1', 'Sw2'],
        quiz: [],
      );

      expect(lesson.getContentItems('en'), ['En1', 'En2']);
      expect(lesson.getContentItems('sw'), ['Sw1', 'Sw2']);
    });
  });

  group('TrainingModule', () {
    test('should create with lessons', () {
      final lessons = [
        TrainingLesson(
          id: 'l1',
          title: 'Lesson 1',
          titleSw: 'Somo 1',
          description: '',
          descriptionSw: '',
          durationMinutes: 20,
          iconName: 'book',
          contentItems: [],
          contentItemsSw: [],
          quiz: [],
        ),
        TrainingLesson(
          id: 'l2',
          title: 'Lesson 2',
          titleSw: 'Somo 2',
          description: '',
          descriptionSw: '',
          durationMinutes: 30,
          iconName: 'book',
          contentItems: [],
          contentItemsSw: [],
          quiz: [],
        ),
      ];

      final module = TrainingModule(
        id: 'module-001',
        title: 'Module 1',
        titleSw: 'Moduli 1',
        description: 'Desc',
        descriptionSw: 'Maelezo',
        lessons: lessons,
        themeColor: Colors.blue,
      );

      expect(module.id, 'module-001');
      expect(module.lessons.length, 2);
    });

    test('totalDuration should sum all lesson durations', () {
      final lessons = [
        TrainingLesson(
          id: 'l1',
          title: 'L1',
          titleSw: 'L1',
          description: '',
          descriptionSw: '',
          durationMinutes: 20,
          iconName: 'book',
          contentItems: [],
          contentItemsSw: [],
          quiz: [],
        ),
        TrainingLesson(
          id: 'l2',
          title: 'L2',
          titleSw: 'L2',
          description: '',
          descriptionSw: '',
          durationMinutes: 30,
          iconName: 'book',
          contentItems: [],
          contentItemsSw: [],
          quiz: [],
        ),
        TrainingLesson(
          id: 'l3',
          title: 'L3',
          titleSw: 'L3',
          description: '',
          descriptionSw: '',
          durationMinutes: 25,
          iconName: 'book',
          contentItems: [],
          contentItemsSw: [],
          quiz: [],
        ),
      ];

      final module = TrainingModule(
        id: 'module-001',
        title: 'Module',
        titleSw: 'Moduli',
        description: '',
        descriptionSw: '',
        lessons: lessons,
        themeColor: Colors.green,
      );

      expect(module.totalDuration, 75);
    });

    test('getTitle should return locale-specific title', () {
      final module = TrainingModule(
        id: 'module-001',
        title: 'English Module',
        titleSw: 'Swahili Module',
        description: '',
        descriptionSw: '',
        lessons: [],
        themeColor: Colors.red,
      );

      expect(module.getTitle('en'), 'English Module');
      expect(module.getTitle('sw'), 'Swahili Module');
    });
  });

  group('TrainingProgress', () {
    test('should create with all fields', () {
      final progress = TrainingProgress(
        oduleId: 'module-001',
        lessonId: 'lesson-001',
        status: LessonStatus.completed,
        quizScore: 85,
        completedAt: DateTime(2024, 1, 15),
        attempts: 2,
      );

      expect(progress.oduleId, 'module-001');
      expect(progress.lessonId, 'lesson-001');
      expect(progress.status, LessonStatus.completed);
      expect(progress.quizScore, 85);
      expect(progress.attempts, 2);
    });

    test('isPassed should check score against threshold', () {
      final passed = TrainingProgress(
        oduleId: 'm1',
        lessonId: 'l1',
        status: LessonStatus.completed,
        quizScore: 75,
      );

      final failed = TrainingProgress(
        oduleId: 'm1',
        lessonId: 'l1',
        status: LessonStatus.completed,
        quizScore: 65,
      );

      final noScore = TrainingProgress(
        oduleId: 'm1',
        lessonId: 'l1',
        status: LessonStatus.inProgress,
      );

      expect(passed.isPassed, true);
      expect(failed.isPassed, false);
      expect(noScore.isPassed, false);
    });

    test('copyWith should update specified fields', () {
      final original = TrainingProgress(
        oduleId: 'module-001',
        lessonId: 'lesson-001',
        status: LessonStatus.inProgress,
        attempts: 1,
      );

      final updated = original.copyWith(
        status: LessonStatus.completed,
        quizScore: 90,
        completedAt: DateTime(2024, 1, 15),
      );

      expect(updated.oduleId, 'module-001'); // unchanged
      expect(updated.status, LessonStatus.completed); // updated
      expect(updated.quizScore, 90); // added
      expect(updated.attempts, 1); // unchanged
    });

    test('copyWith should allow updating attempts', () {
      final original = TrainingProgress(
        oduleId: 'module-001',
        lessonId: 'lesson-001',
        status: LessonStatus.inProgress,
        attempts: 1,
      );

      final updated = original.copyWith(attempts: 3);

      expect(updated.attempts, 3);
      expect(updated.status, LessonStatus.inProgress);
    });

    test('default attempts should be 0', () {
      final progress = TrainingProgress(
        oduleId: 'm1',
        lessonId: 'l1',
        status: LessonStatus.available,
      );

      expect(progress.attempts, 0);
    });

    test('isPassed edge case at exactly 70', () {
      final exactlyPassed = TrainingProgress(
        oduleId: 'm1',
        lessonId: 'l1',
        status: LessonStatus.completed,
        quizScore: 70,
      );

      expect(exactlyPassed.isPassed, true);
    });

    test('isPassed edge case at 69', () {
      final justFailed = TrainingProgress(
        oduleId: 'm1',
        lessonId: 'l1',
        status: LessonStatus.completed,
        quizScore: 69,
      );

      expect(justFailed.isPassed, false);
    });
  });

  group('TrainingContent', () {
    test('getModules should return non-empty list', () {
      final modules = TrainingContent.getModules();

      expect(modules, isNotEmpty);
      expect(modules.length, greaterThanOrEqualTo(1));
    });

    test('all modules should have valid structure', () {
      final modules = TrainingContent.getModules();

      for (final module in modules) {
        expect(module.id, isNotEmpty);
        expect(module.title, isNotEmpty);
        expect(module.titleSw, isNotEmpty);
        expect(module.lessons, isNotNull);
      }
    });

    test('all lessons should have valid quiz questions', () {
      final modules = TrainingContent.getModules();

      for (final module in modules) {
        for (final lesson in module.lessons) {
          expect(lesson.durationMinutes, greaterThan(0));
          for (final quiz in lesson.quiz) {
            expect(quiz.options, isNotEmpty);
            expect(quiz.correctAnswer, lessThan(quiz.options.length));
          }
        }
      }
    });

    test('should have exactly 3 modules', () {
      final modules = TrainingContent.getModules();
      expect(modules.length, 3);
    });

    test('parkinson basics module should have 2 lessons', () {
      final modules = TrainingContent.getModules();
      final basicsModule = modules.firstWhere((m) => m.id == 'module_basics');
      
      expect(basicsModule.lessons.length, 2);
      expect(basicsModule.lessons[0].id, 'basics_01');
      expect(basicsModule.lessons[1].id, 'basics_02');
    });

    test('screening module should have lessons', () {
      final modules = TrainingContent.getModules();
      final screeningModule = modules.firstWhere((m) => m.id == 'module_screening');
      
      expect(screeningModule.lessons, isNotEmpty);
      expect(screeningModule.title, 'Voice Screening Procedure');
    });

    test('communication module should have lessons', () {
      final modules = TrainingContent.getModules();
      final commModule = modules.firstWhere((m) => m.id == 'module_communication');
      
      expect(commModule.lessons, isNotEmpty);
      expect(commModule.title, 'Patient Communication');
    });

    test('all quiz questions should have explanations', () {
      final modules = TrainingContent.getModules();
      
      int questionsWithExplanations = 0;
      int totalQuestions = 0;
      
      for (final module in modules) {
        for (final lesson in module.lessons) {
          for (final quiz in lesson.quiz) {
            totalQuestions++;
            if (quiz.explanation != null) {
              questionsWithExplanations++;
            }
          }
        }
      }
      
      expect(totalQuestions, greaterThan(0));
      // At least half of questions should have explanations
      expect(questionsWithExplanations, greaterThanOrEqualTo(totalQuestions ~/ 2));
    });

    test('module colors should be distinct', () {
      final modules = TrainingContent.getModules();
      final colors = modules.map((m) => m.themeColor.value).toSet();
      
      expect(colors.length, modules.length);
    });

    test('total training duration should be reasonable', () {
      final modules = TrainingContent.getModules();
      
      int totalMinutes = 0;
      for (final module in modules) {
        totalMinutes += module.totalDuration;
      }
      
      // Total training should be between 30 minutes and 3 hours
      expect(totalMinutes, greaterThanOrEqualTo(30));
      expect(totalMinutes, lessThanOrEqualTo(180));
    });

    test('all content items should be non-empty strings', () {
      final modules = TrainingContent.getModules();
      
      for (final module in modules) {
        for (final lesson in module.lessons) {
          for (final item in lesson.contentItems) {
            expect(item, isNotEmpty);
          }
          for (final itemSw in lesson.contentItemsSw) {
            expect(itemSw, isNotEmpty);
          }
        }
      }
    });

    test('locale methods should work for all content', () {
      final modules = TrainingContent.getModules();
      
      for (final module in modules) {
        // Test module locale methods
        expect(module.getTitle('en'), module.title);
        expect(module.getTitle('sw'), module.titleSw);
        expect(module.getDescription('en'), module.description);
        expect(module.getDescription('sw'), module.descriptionSw);
        
        for (final lesson in module.lessons) {
          // Test lesson locale methods
          expect(lesson.getTitle('en'), lesson.title);
          expect(lesson.getTitle('sw'), lesson.titleSw);
          expect(lesson.getDescription('en'), lesson.description);
          expect(lesson.getDescription('sw'), lesson.descriptionSw);
          expect(lesson.getContentItems('en'), lesson.contentItems);
          expect(lesson.getContentItems('sw'), lesson.contentItemsSw);
          
          for (final quiz in lesson.quiz) {
            // Test quiz locale methods
            expect(quiz.getQuestion('en'), quiz.question);
            expect(quiz.getQuestion('sw'), quiz.questionSw);
            expect(quiz.getOptions('en'), quiz.options);
            expect(quiz.getOptions('sw'), quiz.optionsSw);
            
            if (quiz.explanation != null) {
              expect(quiz.getExplanation('en'), quiz.explanation);
              expect(quiz.getExplanation('sw'), quiz.explanationSw);
            }
          }
        }
      }
    });
  });

  group('QuizQuestion - getExplanation', () {
    test('should return explanation in English', () {
      final question = QuizQuestion(
        id: 'q1',
        question: 'Q',
        questionSw: 'Q',
        type: QuestionType.trueFalse,
        options: ['T', 'F'],
        optionsSw: ['K', 'U'],
        correctAnswer: 0,
        explanation: 'English explanation',
        explanationSw: 'Swahili explanation',
      );

      expect(question.getExplanation('en'), 'English explanation');
    });

    test('should return explanation in Swahili', () {
      final question = QuizQuestion(
        id: 'q1',
        question: 'Q',
        questionSw: 'Q',
        type: QuestionType.trueFalse,
        options: ['T', 'F'],
        optionsSw: ['K', 'U'],
        correctAnswer: 0,
        explanation: 'English explanation',
        explanationSw: 'Swahili explanation',
      );

      expect(question.getExplanation('sw'), 'Swahili explanation');
    });

    test('should return null when explanation is not provided', () {
      final question = QuizQuestion(
        id: 'q1',
        question: 'Q',
        questionSw: 'Q',
        type: QuestionType.trueFalse,
        options: ['T', 'F'],
        optionsSw: ['K', 'U'],
        correctAnswer: 0,
      );

      expect(question.getExplanation('en'), isNull);
      expect(question.getExplanation('sw'), isNull);
    });
  });

  group('TrainingLesson - getDescription', () {
    test('should return description in English', () {
      final lesson = TrainingLesson(
        id: 'l1',
        title: 'T',
        titleSw: 'T',
        description: 'English description',
        descriptionSw: 'Swahili description',
        durationMinutes: 10,
        iconName: 'book',
        contentItems: [],
        contentItemsSw: [],
        quiz: [],
      );

      expect(lesson.getDescription('en'), 'English description');
    });

    test('should return description in Swahili', () {
      final lesson = TrainingLesson(
        id: 'l1',
        title: 'T',
        titleSw: 'T',
        description: 'English description',
        descriptionSw: 'Swahili description',
        durationMinutes: 10,
        iconName: 'book',
        contentItems: [],
        contentItemsSw: [],
        quiz: [],
      );

      expect(lesson.getDescription('sw'), 'Swahili description');
    });
  });

  group('TrainingModule - getDescription', () {
    test('should return description in English', () {
      final module = TrainingModule(
        id: 'm1',
        title: 'T',
        titleSw: 'T',
        description: 'English module desc',
        descriptionSw: 'Swahili module desc',
        lessons: [],
        themeColor: Colors.blue,
      );

      expect(module.getDescription('en'), 'English module desc');
    });

    test('should return description in Swahili', () {
      final module = TrainingModule(
        id: 'm1',
        title: 'T',
        titleSw: 'T',
        description: 'English module desc',
        descriptionSw: 'Swahili module desc',
        lessons: [],
        themeColor: Colors.blue,
      );

      expect(module.getDescription('sw'), 'Swahili module desc');
    });

    test('totalDuration with empty lessons', () {
      final module = TrainingModule(
        id: 'm1',
        title: 'T',
        titleSw: 'T',
        description: 'D',
        descriptionSw: 'D',
        lessons: [],
        themeColor: Colors.blue,
      );

      expect(module.totalDuration, 0);
    });
  });

  group('LessonStatus - enum values', () {
    test('should have correct number of values', () {
      expect(LessonStatus.values.length, 4);
    });

    test('indices should be sequential', () {
      expect(LessonStatus.locked.index, 0);
      expect(LessonStatus.available.index, 1);
      expect(LessonStatus.inProgress.index, 2);
      expect(LessonStatus.completed.index, 3);
    });
  });
}
