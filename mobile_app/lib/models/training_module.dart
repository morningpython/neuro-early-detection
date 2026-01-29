/// Training Module Model
/// STORY-023: CHW Training Module
///
/// 지역보건요원(CHW) 교육 모듈 데이터 모델입니다.
library;

import 'package:flutter/material.dart';

/// 교육 진행 상태
enum LessonStatus {
  locked('잠금', Icons.lock),
  available('수강 가능', Icons.play_circle_outline),
  inProgress('진행 중', Icons.play_circle),
  completed('완료', Icons.check_circle);

  const LessonStatus(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// 퀴즈 문제 유형
enum QuestionType {
  multipleChoice, // 객관식
  trueFalse,      // 참/거짓
  matching,       // 매칭
}

/// 퀴즈 문제
class QuizQuestion {
  final String id;
  final String question;
  final String questionSw; // 스와힐리어
  final QuestionType type;
  final List<String> options;
  final List<String> optionsSw;
  final int correctAnswer;
  final String? explanation;
  final String? explanationSw;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.questionSw,
    required this.type,
    required this.options,
    required this.optionsSw,
    required this.correctAnswer,
    this.explanation,
    this.explanationSw,
  });

  String getQuestion(String locale) => locale == 'sw' ? questionSw : question;
  List<String> getOptions(String locale) => locale == 'sw' ? optionsSw : options;
  String? getExplanation(String locale) => locale == 'sw' ? explanationSw : explanation;
}

/// 교육 레슨
class TrainingLesson {
  final String id;
  final String title;
  final String titleSw;
  final String description;
  final String descriptionSw;
  final int durationMinutes;
  final String iconName;
  final List<String> contentItems;
  final List<String> contentItemsSw;
  final List<QuizQuestion> quiz;
  final int requiredScore; // 퍼센트
  
  const TrainingLesson({
    required this.id,
    required this.title,
    required this.titleSw,
    required this.description,
    required this.descriptionSw,
    required this.durationMinutes,
    required this.iconName,
    required this.contentItems,
    required this.contentItemsSw,
    required this.quiz,
    this.requiredScore = 70,
  });

  String getTitle(String locale) => locale == 'sw' ? titleSw : title;
  String getDescription(String locale) => locale == 'sw' ? descriptionSw : description;
  List<String> getContentItems(String locale) => locale == 'sw' ? contentItemsSw : contentItems;
}

/// 교육 모듈
class TrainingModule {
  final String id;
  final String title;
  final String titleSw;
  final String description;
  final String descriptionSw;
  final List<TrainingLesson> lessons;
  final Color themeColor;

  const TrainingModule({
    required this.id,
    required this.title,
    required this.titleSw,
    required this.description,
    required this.descriptionSw,
    required this.lessons,
    required this.themeColor,
  });

  String getTitle(String locale) => locale == 'sw' ? titleSw : title;
  String getDescription(String locale) => locale == 'sw' ? descriptionSw : description;

  int get totalDuration => lessons.fold(0, (sum, lesson) => sum + lesson.durationMinutes);
}

/// CHW 교육 진행 상황
class TrainingProgress {
  final String oduleId;
  final String lessonId;
  final LessonStatus status;
  final int? quizScore;
  final DateTime? completedAt;
  final int attempts;

  const TrainingProgress({
    required this.oduleId,
    required this.lessonId,
    required this.status,
    this.quizScore,
    this.completedAt,
    this.attempts = 0,
  });

  TrainingProgress copyWith({
    LessonStatus? status,
    int? quizScore,
    DateTime? completedAt,
    int? attempts,
  }) {
    return TrainingProgress(
      oduleId: oduleId,
      lessonId: lessonId,
      status: status ?? this.status,
      quizScore: quizScore ?? this.quizScore,
      completedAt: completedAt ?? this.completedAt,
      attempts: attempts ?? this.attempts,
    );
  }

  bool get isPassed => quizScore != null && quizScore! >= 70;
}

/// 기본 교육 콘텐츠
class TrainingContent {
  static List<TrainingModule> getModules() {
    return [
      _parkinsonBasicsModule,
      _screeningProcedureModule,
      _communicationModule,
    ];
  }

  static const _parkinsonBasicsModule = TrainingModule(
    id: 'module_basics',
    title: "Understanding Parkinson's Disease",
    titleSw: "Kuelewa Ugonjwa wa Parkinson",
    description: "Learn the fundamentals of Parkinson's disease, its symptoms, and early signs.",
    descriptionSw: "Jifunze misingi ya ugonjwa wa Parkinson, dalili zake, na ishara za mapema.",
    themeColor: Color(0xFF4CAF50),
    lessons: [
      TrainingLesson(
        id: 'basics_01',
        title: "What is Parkinson's Disease?",
        titleSw: "Parkinson ni Nini?",
        description: "Overview of Parkinson's disease and how it affects the brain.",
        descriptionSw: "Muhtasari wa ugonjwa wa Parkinson na jinsi unavyoathiri ubongo.",
        durationMinutes: 15,
        iconName: 'brain',
        contentItems: [
          "Parkinson's disease is a progressive neurological disorder",
          "It affects movement control due to loss of dopamine-producing neurons",
          "Affects about 1% of people over age 60 worldwide",
          "Early detection leads to better management outcomes",
          "The disease progresses slowly over many years",
        ],
        contentItemsSw: [
          "Ugonjwa wa Parkinson ni ugonjwa wa neva unaoendelea",
          "Unaathiri udhibiti wa mwendo kutokana na kupoteza neuroni zinazozalisha dopamine",
          "Unaathiri takriban 1% ya watu wenye umri zaidi ya miaka 60 duniani kote",
          "Ugunduzi wa mapema husababisha matokeo bora ya usimamizi",
          "Ugonjwa unaendelea polepole kwa miaka mingi",
        ],
        quiz: [
          QuizQuestion(
            id: 'q1',
            question: "Parkinson's disease primarily affects which part of the body?",
            questionSw: "Ugonjwa wa Parkinson huathiri sana sehemu gani ya mwili?",
            type: QuestionType.multipleChoice,
            options: ['Heart', 'Brain', 'Lungs', 'Liver'],
            optionsSw: ['Moyo', 'Ubongo', 'Mapafu', 'Ini'],
            correctAnswer: 1,
            explanation: "Parkinson's affects the brain, specifically the dopamine-producing neurons.",
            explanationSw: "Parkinson's huathiri ubongo, hasa neuroni zinazozalisha dopamine.",
          ),
          QuizQuestion(
            id: 'q2',
            question: "True or False: Parkinson's disease only affects elderly people.",
            questionSw: "Kweli au Uongo: Ugonjwa wa Parkinson huathiri wazee tu.",
            type: QuestionType.trueFalse,
            options: ['True', 'False'],
            optionsSw: ['Kweli', 'Uongo'],
            correctAnswer: 1,
            explanation: "While more common in older adults, Parkinson's can affect younger people too.",
            explanationSw: "Ingawa ni kawaida zaidi kwa watu wazima, Parkinson's inaweza kuathiri vijana pia.",
          ),
        ],
      ),
      TrainingLesson(
        id: 'basics_02',
        title: 'Recognizing Early Symptoms',
        titleSw: 'Kutambua Dalili za Mapema',
        description: 'Learn to identify the early warning signs of Parkinson\'s.',
        descriptionSw: 'Jifunze kutambua ishara za onyo za mapema za Parkinson\'s.',
        durationMinutes: 20,
        iconName: 'visibility',
        contentItems: [
          "Tremor: Shaking of hands, fingers, or chin at rest",
          "Bradykinesia: Slowness of movement",
          "Rigidity: Stiffness in arms, legs, or trunk",
          "Postural instability: Balance problems",
          "Voice changes: Softer or monotone speech",
          "Small handwriting (micrographia)",
          "Loss of smell (hyposmia)",
        ],
        contentItemsSw: [
          "Kutetemeka: Kutetemeka kwa mikono, vidole, au kidevu wakati wa kupumzika",
          "Bradykinesia: Kuchelewa kwa mwendo",
          "Ugumu: Ugumu katika mikono, miguu, au shina",
          "Kutokuwa na utulivu wa mkao: Matatizo ya usawa",
          "Mabadiliko ya sauti: Hotuba laini au ya monotone",
          "Maandishi madogo (micrographia)",
          "Kupoteza uwezo wa kunusa (hyposmia)",
        ],
        quiz: [
          QuizQuestion(
            id: 'q3',
            question: "Which is NOT a common early symptom of Parkinson's?",
            questionSw: "Ni ipi ambayo SI dalili ya kawaida ya mapema ya Parkinson?",
            type: QuestionType.multipleChoice,
            options: ['Tremor', 'Fever', 'Slow movement', 'Soft voice'],
            optionsSw: ['Kutetemeka', 'Homa', 'Mwendo wa polepole', 'Sauti laini'],
            correctAnswer: 1,
            explanation: "Fever is not a symptom of Parkinson's disease.",
            explanationSw: "Homa si dalili ya ugonjwa wa Parkinson.",
          ),
        ],
      ),
    ],
  );

  static const _screeningProcedureModule = TrainingModule(
    id: 'module_screening',
    title: 'Voice Screening Procedure',
    titleSw: 'Utaratibu wa Uchunguzi wa Sauti',
    description: 'Learn how to properly conduct voice screening using the app.',
    descriptionSw: 'Jifunze jinsi ya kufanya uchunguzi wa sauti vizuri kwa kutumia programu.',
    themeColor: Color(0xFF2196F3),
    lessons: [
      TrainingLesson(
        id: 'screening_01',
        title: 'Preparing for Screening',
        titleSw: 'Kujiandaa kwa Uchunguzi',
        description: 'Steps to prepare the environment and patient for screening.',
        descriptionSw: 'Hatua za kuandaa mazingira na mgonjwa kwa uchunguzi.',
        durationMinutes: 10,
        iconName: 'checklist',
        contentItems: [
          "Find a quiet room with minimal background noise",
          "Ensure the patient is comfortable and relaxed",
          "Explain the screening process to the patient",
          "Check that the device battery is sufficient",
          "Position the phone 15-20 cm from the patient's mouth",
          "Ensure the microphone is not blocked",
        ],
        contentItemsSw: [
          "Tafuta chumba kimya chenye kelele kidogo ya nyuma",
          "Hakikisha mgonjwa ana starehe na utulivu",
          "Eleza mchakato wa uchunguzi kwa mgonjwa",
          "Angalia kwamba betri ya kifaa inatosha",
          "Weka simu sm 15-20 kutoka kinywani mwa mgonjwa",
          "Hakikisha kipaza sauti hakijazuiliwa",
        ],
        quiz: [
          QuizQuestion(
            id: 'q4',
            question: "What is the recommended distance for the phone during voice recording?",
            questionSw: "Umbali unaopendekezwa wa simu wakati wa kurekodi sauti ni upi?",
            type: QuestionType.multipleChoice,
            options: ['5-10 cm', '15-20 cm', '30-40 cm', '50+ cm'],
            optionsSw: ['sm 5-10', 'sm 15-20', 'sm 30-40', 'sm 50+'],
            correctAnswer: 1,
          ),
        ],
      ),
      TrainingLesson(
        id: 'screening_02',
        title: 'Conducting the Voice Test',
        titleSw: 'Kufanya Mtihani wa Sauti',
        description: 'How to guide the patient through the voice recording.',
        descriptionSw: 'Jinsi ya kuongoza mgonjwa kupitia kurekodi sauti.',
        durationMinutes: 15,
        iconName: 'mic',
        contentItems: [
          "Ask the patient to say 'Aaaaah' for at least 5 seconds",
          "The voice should be at a comfortable, natural volume",
          "Ensure steady breath support throughout",
          "Record multiple samples if the first is unclear",
          "Wait for the analysis to complete",
          "Review results with the patient",
        ],
        contentItemsSw: [
          "Mwambie mgonjwa aseme 'Aaaaah' kwa angalau sekunde 5",
          "Sauti inapaswa kuwa katika kiwango cha kawaida, cha asili",
          "Hakikisha msaada wa pumzi unaendelea",
          "Rekodi sampuli nyingi ikiwa ya kwanza haieleweki",
          "Subiri uchanganuzi ukamilike",
          "Pitia matokeo na mgonjwa",
        ],
        quiz: [
          QuizQuestion(
            id: 'q5',
            question: "How long should the patient sustain the 'Aah' sound?",
            questionSw: "Mgonjwa anapaswa kushikilia sauti ya 'Aah' kwa muda gani?",
            type: QuestionType.multipleChoice,
            options: ['1-2 seconds', '3-4 seconds', 'At least 5 seconds', '10+ seconds'],
            optionsSw: ['Sekunde 1-2', 'Sekunde 3-4', 'Angalau sekunde 5', 'Sekunde 10+'],
            correctAnswer: 2,
          ),
        ],
      ),
    ],
  );

  static const _communicationModule = TrainingModule(
    id: 'module_communication',
    title: 'Patient Communication',
    titleSw: 'Mawasiliano na Mgonjwa',
    description: 'Effective communication strategies when delivering screening results.',
    descriptionSw: 'Mikakati madhubuti ya mawasiliano wakati wa kutoa matokeo ya uchunguzi.',
    themeColor: Color(0xFFFF9800),
    lessons: [
      TrainingLesson(
        id: 'comm_01',
        title: 'Delivering Results with Care',
        titleSw: 'Kutoa Matokeo kwa Uangalifu',
        description: 'How to communicate screening results sensitively.',
        descriptionSw: 'Jinsi ya kuwasilisha matokeo ya uchunguzi kwa uangalifu.',
        durationMinutes: 20,
        iconName: 'chat',
        contentItems: [
          "Always maintain a calm and reassuring tone",
          "Explain that this is a screening, not a diagnosis",
          "Use simple, clear language",
          "Allow time for questions",
          "Emphasize the importance of follow-up care",
          "Provide written information when possible",
          "Respect patient confidentiality",
        ],
        contentItemsSw: [
          "Daima kudumisha sauti ya utulivu na kufariji",
          "Eleza kuwa hii ni uchunguzi, si utambuzi",
          "Tumia lugha rahisi, wazi",
          "Ruhusu muda kwa maswali",
          "Sisitiza umuhimu wa ufuatiliaji",
          "Toa maelezo yaliyoandikwa ikiwezekana",
          "Heshimu usiri wa mgonjwa",
        ],
        quiz: [
          QuizQuestion(
            id: 'q6',
            question: "When delivering results, you should:",
            questionSw: "Unapotoa matokeo, unapaswa:",
            type: QuestionType.multipleChoice,
            options: [
              'Rush through the explanation',
              'Use complex medical terms',
              'Allow time for questions',
              'Avoid eye contact',
            ],
            optionsSw: [
              'Harakisha maelezo',
              'Tumia maneno magumu ya kimatibabu',
              'Ruhusu muda kwa maswali',
              'Epuka kuangalia machoni',
            ],
            correctAnswer: 2,
          ),
        ],
      ),
      TrainingLesson(
        id: 'comm_02',
        title: 'Referral and Follow-up',
        titleSw: 'Rufaa na Ufuatiliaji',
        description: 'Guiding patients through the referral process.',
        descriptionSw: 'Kuongoza wagonjwa kupitia mchakato wa rufaa.',
        durationMinutes: 15,
        iconName: 'directions',
        contentItems: [
          "Explain why a referral is recommended",
          "Provide clear information about the referral facility",
          "Help schedule appointments when possible",
          "Explain what to expect at the referral visit",
          "Follow up with patients after referral",
          "Document all referrals in the system",
        ],
        contentItemsSw: [
          "Eleza kwa nini rufaa inapendekezwa",
          "Toa habari wazi kuhusu kituo cha rufaa",
          "Saidia kupanga miadi ikiwezekana",
          "Eleza nini cha kutarajia katika ziara ya rufaa",
          "Fuatilia wagonjwa baada ya rufaa",
          "Andika rufaa zote kwenye mfumo",
        ],
        quiz: [
          QuizQuestion(
            id: 'q7',
            question: "After making a referral, you should:",
            questionSw: "Baada ya kufanya rufaa, unapaswa:",
            type: QuestionType.multipleChoice,
            options: [
              'Consider your job done',
              'Follow up with the patient',
              'Delete the screening record',
              'Avoid further contact',
            ],
            optionsSw: [
              'Fikiria kazi yako imekwisha',
              'Fuatilia mgonjwa',
              'Futa rekodi ya uchunguzi',
              'Epuka mawasiliano zaidi',
            ],
            correctAnswer: 1,
          ),
        ],
      ),
    ],
  );
}
