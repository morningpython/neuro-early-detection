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
  });
}
