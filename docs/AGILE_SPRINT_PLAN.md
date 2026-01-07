# Agile Sprint Plan
# NeuroAccess Development Sprints

**Project**: NeuroAccess - AI-Powered Parkinson's Screening for Underserved Communities  
**Version**: 1.0  
**Date**: 2026년 1월 7일  
**Sprint Duration**: 2 weeks per sprint  
**Team**: 1 developer (Junho Lee) + UMich faculty advisor  

---

## Document Control

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-01-07 | Junho Lee | Initial Sprint Plan (Sprints 1-3) |

---

## Table of Contents

1. [Sprint Overview](#sprint-overview)
2. [Epic Definitions](#epic-definitions)
3. [Sprint 1: Foundation & Voice Recording UI](#sprint-1-foundation--voice-recording-ui)
4. [Sprint 2: ML Model Integration & Analysis](#sprint-2-ml-model-integration--analysis)
5. [Sprint 3: Results Display & CHW Workflow](#sprint-3-results-display--chw-workflow)
6. [Story Point Reference](#story-point-reference)
7. [Definition of Done](#definition-of-done)

---

## Sprint Overview

### Timeline (January - February 2026)

| Sprint | Dates | Focus | Deliverable |
|--------|-------|-------|-------------|
| **Sprint 1** | Jan 13 - Jan 26 | Project setup + Voice recording UI | Functioning voice recorder with Figma-based UI |
| **Sprint 2** | Jan 27 - Feb 9 | ML model integration | Working inference pipeline with baseline model |
| **Sprint 3** | Feb 10 - Feb 23 | Results display + Workflow | Complete CHW screening workflow (MVP) |

### Velocity Planning

**Target Velocity**: 20-25 story points per sprint (solo developer)

**Assumptions**:
- 8 hours/day development time
- 10 working days per sprint
- No major blockers

---

## Epic Definitions

### Epic 1: Project Foundation (EPIC-FOUND)
**Goal**: Establish development environment, project structure, and basic infrastructure  
**Business Value**: Enables all future development  
**Estimated Duration**: Sprint 1

### Epic 2: Voice Recording & Analysis (EPIC-VOICE)
**Goal**: Implement voice capture, quality validation, and feature extraction  
**Business Value**: Core screening capability  
**Estimated Duration**: Sprints 1-2

### Epic 3: ML Model Integration (EPIC-ML)
**Goal**: Integrate TensorFlow Lite model for on-device inference  
**Business Value**: AI-powered risk assessment  
**Estimated Duration**: Sprints 2-3

### Epic 4: Results & Referral System (EPIC-RESULT)
**Goal**: Display screening results and provide referral guidance  
**Business Value**: Actionable insights for CHWs  
**Estimated Duration**: Sprint 3

### Epic 5: CHW Training Module (EPIC-TRAIN)
**Goal**: Interactive training and certification for CHWs  
**Business Value**: Ensures proper tool usage  
**Estimated Duration**: Sprints 4-5 (future)

### Epic 6: Multilingual Support (EPIC-I18N)
**Goal**: Support 6+ languages with culturally adapted UI  
**Business Value**: Accessibility for diverse communities  
**Estimated Duration**: Sprints 5-7 (future)

### Epic 7: Data Privacy & Security (EPIC-SEC)
**Goal**: Implement encryption, compliance, and privacy features  
**Business Value**: Regulatory compliance and user trust  
**Estimated Duration**: Sprints 3-4

---

## Sprint 1: Foundation & Voice Recording UI

**Sprint Goal**: "Establish project foundation and deliver a functional voice recording interface with Figma-based UI design"

**Duration**: Jan 13 - Jan 26, 2026 (2 weeks)  
**Total Story Points**: 23 points

---

### Stories in Sprint 1

---

#### **STORY-001**: Project Repository Setup

**Epic**: EPIC-FOUND

**As a** developer,  
**I want to** set up the Flutter project structure with proper configuration,  
**So that** I have a solid foundation for mobile app development.

**Description**:
Initialize Flutter project with proper folder structure, dependencies, and development tools. Set up version control, linting, and CI/CD pipeline basics.

**Story Points**: 3

**Acceptance Criteria**:
- [ ] Flutter project created with Android support
- [ ] Folder structure follows best practices (`lib/`, `models/`, `services/`, `ui/`, `utils/`)
- [ ] `pubspec.yaml` includes essential dependencies (provider, sqflite, path, flutter_sound)
- [ ] Git repository initialized with `.gitignore` configured
- [ ] README.md with setup instructions
- [ ] Code linting configured (analysis_options.yaml)
- [ ] Project runs successfully on Android emulator

**Technical Notes**:
- Flutter SDK 3.16+
- Dart 3.0+
- Android minSdkVersion: 26 (Android 8.0)

---

#### **STORY-002**: Figma UI Design - Voice Recording Screen

**Epic**: EPIC-VOICE

**As a** UX designer (self),  
**I want to** create Figma mockups for the voice recording interface,  
**So that** I have a clear visual guide for implementation.

**Description**:
Design low-fidelity and high-fidelity Figma prototypes for the voice recording screen, including button layouts, waveform visualization, and recording instructions.

**Story Points**: 5

**Acceptance Criteria**:
- [ ] Figma project created with mobile frame (Android 6.5" screen)
- [ ] Low-fidelity wireframes for voice recording workflow (3 screens)
- [ ] High-fidelity mockup with colors, typography, icons
- [ ] Design includes:
  - Start/Stop recording button (large, prominent)
  - Countdown timer (30 seconds)
  - Waveform visualization placeholder
  - Recording quality indicator (visual feedback)
  - Task instructions (culturally neutral icons)
- [ ] Responsive design for 4.5" - 6.7" screens
- [ ] Accessibility: High contrast colors (WCAG AA)
- [ ] Figma link shared for review

**Design Principles**:
- Minimalist (no clutter)
- Large touch targets (≥44px)
- Visual > text (icon-based)
- Color-coded status (green=ready, red=recording, gray=processing)

---

#### **STORY-003**: Basic App Shell with Navigation

**Epic**: EPIC-FOUND

**As a** CHW,  
**I want to** see a simple home screen with navigation,  
**So that** I can access different features of the app.

**Description**:
Implement basic app shell with bottom navigation, home screen placeholder, and routing structure based on Figma designs.

**Story Points**: 3

**Acceptance Criteria**:
- [ ] MaterialApp configured with theme (colors from Figma)
- [ ] Home screen (Dashboard) with placeholder content
- [ ] Bottom navigation bar with 3 tabs:
  - Home/Dashboard
  - Screening (disabled for now)
  - Settings (placeholder)
- [ ] Routing configured using Flutter Navigator 2.0
- [ ] Splash screen on app launch
- [ ] App bar with title "NeuroAccess"
- [ ] UI matches Figma low-fidelity design

**Technical Notes**:
- Use `go_router` package for navigation
- Implement BLoC pattern for state management setup

---

#### **STORY-004**: Voice Recording Service Implementation

**Epic**: EPIC-VOICE

**As a** CHW,  
**I want to** record a patient's voice using the smartphone microphone,  
**So that** I can capture audio samples for analysis.

**Description**:
Implement audio recording service using flutter_sound package. Support 16kHz, 16-bit PCM, mono format. Handle permissions and errors gracefully.

**Story Points**: 5

**Acceptance Criteria**:
- [ ] `AudioRecordingService` class created in `lib/services/`
- [ ] Microphone permission requested at runtime (Android)
- [ ] Recording starts/stops on user action
- [ ] Audio format: 16kHz, 16-bit PCM, mono (.wav file)
- [ ] Recording duration: 30 seconds (hardcoded for MVP)
- [ ] Save recording to local storage (`/files/audio/`)
- [ ] Error handling:
  - Permission denied → show dialog
  - Recording failure → retry option
  - Storage full → alert user
- [ ] Unit tests for recording service (start, stop, save)
- [ ] Manual test on physical Android device

**Technical Notes**:
- Use `flutter_sound` package
- File naming: `recording_[UUID]_[timestamp].wav`
- Temporary storage (will be deleted after analysis in future sprints)

---

#### **STORY-005**: Voice Recording UI Implementation

**Epic**: EPIC-VOICE

**As a** CHW,  
**I want to** see a visually clear recording interface,  
**So that** I know when recording is active and how much time remains.

**Description**:
Build the voice recording screen UI based on Figma high-fidelity mockup. Include start/stop button, countdown timer, and visual feedback.

**Story Points**: 5

**Acceptance Criteria**:
- [ ] Voice recording screen matches Figma design ≥90%
- [ ] Large circular "Record" button (≥80px diameter)
- [ ] Button changes color:
  - Green + "Tap to Start" (idle)
  - Red + "Recording..." (active)
  - Gray + "Processing..." (after recording)
- [ ] Countdown timer displays seconds remaining (30 → 0)
- [ ] Simple waveform visualization (animated bars)
- [ ] Recording instructions at top:
  - "Hold phone 6 inches from mouth"
  - "Say 'Ahhh' for 10 seconds" (icon-based)
- [ ] "Back" button to cancel recording
- [ ] Responsive layout (tested on 5", 6", 6.5" screens)
- [ ] Smooth animations (fade in/out, button press feedback)

**Technical Notes**:
- Use `flutter_svg` for icons
- Animation: `AnimatedContainer` for button state changes
- Timer: `Stream` with periodic updates

---

#### **STORY-006**: Audio Quality Validation (Basic)

**Epic**: EPIC-VOICE

**As a** CHW,  
**I want to** be notified if the recorded audio quality is poor,  
**So that** I can re-record before proceeding.

**Description**:
Implement basic audio quality checks: minimum duration, no silence, no clipping. Provide user-friendly error messages.

**Story Points**: 2

**Acceptance Criteria**:
- [ ] `AudioQualityValidator` class created
- [ ] Quality checks:
  - Minimum duration: 10 seconds of actual sound
  - Silence detection: Fail if >80% of recording is silence
  - Clipping detection: Fail if >10% of samples at max amplitude
- [ ] Validation runs automatically after recording stops
- [ ] User feedback:
  - ✅ Pass → Proceed to next step
  - ❌ Fail → Show specific error message:
    - "Too quiet - please speak louder"
    - "Recording too short - hold for 30 seconds"
    - "Audio distorted - move phone further from mouth"
  - Retry button (up to 3 attempts)
- [ ] Unit tests for each validation rule
- [ ] Manual testing with good/bad audio samples

**Technical Notes**:
- Use `wav` package for audio file parsing
- Amplitude threshold for silence: <5% of max
- Store validation result with recording metadata

---

### Sprint 1 Summary

**Total Story Points**: 23

| Story ID | Story Title | Points | Status |
|----------|-------------|--------|--------|
| STORY-001 | Project Repository Setup | 3 | 🔲 To Do |
| STORY-002 | Figma UI Design - Voice Recording | 5 | 🔲 To Do |
| STORY-003 | Basic App Shell with Navigation | 3 | 🔲 To Do |
| STORY-004 | Voice Recording Service | 5 | 🔲 To Do |
| STORY-005 | Voice Recording UI Implementation | 5 | 🔲 To Do |
| STORY-006 | Audio Quality Validation | 2 | 🔲 To Do |

**Sprint 1 Deliverables**:
- ✅ Flutter project fully configured
- ✅ Figma designs for voice recording UI
- ✅ Functional voice recorder with quality validation
- ✅ UI matches Figma design
- ✅ Runnable on Android device

**Demo Scenario**:
1. Open app → See home screen
2. Navigate to "Screening" tab
3. Tap "Start Recording" button
4. Record 30-second voice sample
5. See quality validation result (pass/fail)
6. Retry if failed

---

## Sprint 2: ML Model Integration & Analysis

**Sprint Goal**: "Integrate TensorFlow Lite model and implement end-to-end inference pipeline from audio to risk score"

**Duration**: Jan 27 - Feb 9, 2026 (2 weeks)  
**Total Story Points**: 24 points

---

### Stories in Sprint 2

---

#### **STORY-007**: ML Model Training - Baseline

**Epic**: EPIC-ML

**As a** data scientist (self),  
**I want to** train a baseline Parkinson's detection model on UCI dataset,  
**So that** I have a working model for initial testing.

**Description**:
Train a feedforward neural network on UCI Parkinson's dataset. Extract MFCC features, train model, achieve ≥85% accuracy, and export to TensorFlow format.

**Story Points**: 8

**Acceptance Criteria**:
- [ ] UCI Parkinson's dataset downloaded and preprocessed
- [ ] Feature extraction pipeline:
  - MFCC (13 coefficients + delta + delta-delta = 39 features)
  - Jitter, Shimmer, HNR (16 prosodic features)
  - Total: 55 features per voice sample
- [ ] Neural network architecture:
  - Input layer: 55 features
  - Hidden layers: 2-3 layers (32-64 neurons each)
  - Output layer: 1 neuron (sigmoid activation)
  - Optimizer: Adam
  - Loss: Binary cross-entropy
- [ ] Training:
  - Train/validation/test split: 70/15/15
  - Epochs: 100 with early stopping
  - Batch size: 32
- [ ] Performance metrics:
  - Accuracy: ≥85%
  - Sensitivity: ≥85%
  - Specificity: ≥80%
  - AUC-ROC: ≥0.90
- [ ] Model saved in `.h5` format (TensorFlow)
- [ ] Jupyter notebook documenting training process
- [ ] Model evaluation report (confusion matrix, ROC curve)

**Technical Notes**:
- Python 3.11, TensorFlow 2.15
- Use `librosa` for MFCC extraction
- Save training history (loss, accuracy curves)
- Model file: `parkinson_model_v1.0.h5`

---

#### **STORY-008**: TensorFlow Lite Model Conversion

**Epic**: EPIC-ML

**As a** developer,  
**I want to** convert the trained TensorFlow model to TensorFlow Lite format,  
**So that** it can run efficiently on mobile devices.

**Description**:
Convert `.h5` model to `.tflite` format with INT8 quantization. Validate that converted model maintains ≥80% of original accuracy.

**Story Points**: 3

**Acceptance Criteria**:
- [ ] TFLite conversion script (`convert_to_tflite.py`)
- [ ] Conversion process:
  - Load `.h5` model
  - Apply INT8 quantization
  - Optimize for mobile inference (edge TPU compatible)
- [ ] Converted model size: ≤5MB
- [ ] Accuracy validation:
  - Test on same test set
  - Accuracy drop ≤5% from original model
  - Sensitivity ≥80%, Specificity ≥75%
- [ ] Model file: `parkinson_model_v1.0.tflite`
- [ ] Metadata added:
  - Input shape: [1, 55]
  - Output shape: [1, 1]
  - Input type: FLOAT32 (or INT8)
- [ ] Conversion report documenting:
  - Original vs TFLite accuracy
  - Model size comparison
  - Inference speed estimate

**Technical Notes**:
- Use TensorFlow Lite Converter API
- Test inference on Android emulator (optional)
- Save model to `assets/models/` in Flutter project

---

#### **STORY-009**: Audio Feature Extraction Service

**Epic**: EPIC-VOICE

**As a** developer,  
**I want to** extract MFCC and prosodic features from recorded audio,  
**So that** I can feed them into the ML model for inference.

**Description**:
Implement feature extraction service in Flutter/Dart or Python bridge. Extract same 55 features used in model training.

**Story Points**: 5

**Acceptance Criteria**:
- [ ] `FeatureExtractionService` class created
- [ ] Feature extraction:
  - Input: WAV file path
  - Output: 55-dimensional feature vector (List<double>)
  - MFCC: 39 features (13 + delta + delta-delta)
  - Prosodic: 16 features (jitter, shimmer, HNR, F0 stats)
- [ ] Processing time: ≤5 seconds on target device
- [ ] Error handling:
  - Invalid audio file → return error
  - Feature extraction failure → retry or skip
- [ ] Unit tests:
  - Test with sample audio files
  - Verify feature vector length = 55
  - Verify feature values in expected range
- [ ] Integration with Python (if needed):
  - Use `flutter_python` plugin OR
  - Pre-compute features server-side (not preferred) OR
  - Pure Dart implementation (complex but preferred)

**Technical Notes**:
- **Option A** (preferred): Port Python feature extraction to Dart
  - Use `fft` package for Fourier transforms
  - Manual MFCC implementation
- **Option B**: Python bridge (heavier, requires Python runtime on device)
  - Use Chaquopy (Android Python integration)

**Decision**: Start with Option A (Dart-native), fallback to Option B if too complex

---

#### **STORY-010**: TensorFlow Lite Inference Service

**Epic**: EPIC-ML

**As a** developer,  
**I want to** run TFLite model inference on extracted features,  
**So that** I can generate a Parkinson's disease risk score.

**Description**:
Implement TFLite inference service in Flutter. Load model, run inference on feature vector, return risk probability.

**Story Points**: 5

**Acceptance Criteria**:
- [ ] `MLInferenceService` class created
- [ ] Load `.tflite` model from assets on app startup
- [ ] Inference method:
  - Input: 55-dimensional feature vector
  - Output: Risk probability (0.0 - 1.0)
- [ ] Processing time: ≤3 seconds
- [ ] Memory usage: ≤100MB during inference
- [ ] Error handling:
  - Model load failure → fallback to dummy prediction + alert
  - Inference failure → retry once, then error message
- [ ] Unit tests:
  - Test with known input vectors
  - Verify output is between 0 and 1
  - Test model loading on app start
- [ ] Manual testing on Android device
- [ ] Performance profiling (CPU, memory usage)

**Technical Notes**:
- Use `tflite_flutter` package
- Model path: `assets/models/parkinson_model_v1.0.tflite`
- Consider caching model in memory (singleton pattern)

---

#### **STORY-011**: Risk Stratification Logic

**Epic**: EPIC-ML

**As a** CHW,  
**I want to** see a clear risk category (Low/Medium/High) instead of a probability,  
**So that** I understand the severity and know what action to take.

**Description**:
Implement risk stratification logic to convert continuous probability (0-1) to categorical risk levels with associated actions.

**Story Points**: 2

**Acceptance Criteria**:
- [ ] `RiskStratificationService` class created
- [ ] Stratification rules:
  - **Low Risk**: 0.0 - 0.33 → Green
    - Action: "No immediate concern. Routine health monitoring."
  - **Medium Risk**: 0.34 - 0.66 → Yellow
    - Action: "Possible early signs. Re-screen in 6 months."
  - **High Risk**: 0.67 - 1.0 → Red
    - Action: "Recommend neurologist consultation immediately."
- [ ] Output includes:
  - Risk category (enum: Low/Medium/High)
  - Risk percentage (formatted: "72%")
  - Color code (hex color)
  - Recommended action (localized string)
  - Urgency level (routine/monitor/urgent)
- [ ] Unit tests for all threshold boundaries
- [ ] Edge case handling (exactly 0.33, 0.66, etc.)

**Technical Notes**:
- Thresholds may be adjusted based on clinical validation
- Store thresholds in config file for easy adjustment
- Consider adding confidence intervals (future sprint)

---

#### **STORY-012**: End-to-End Inference Pipeline Integration

**Epic**: EPIC-ML

**As a** CHW,  
**I want to** record audio and see an AI-generated risk assessment,  
**So that** I can screen patients for Parkinson's disease.

**Description**:
Integrate all components: voice recording → feature extraction → ML inference → risk stratification. Create seamless user flow.

**Story Points**: 1

**Acceptance Criteria**:
- [ ] Complete workflow implemented:
  1. CHW records 30-second voice sample
  2. Audio quality validation (from Sprint 1)
  3. Feature extraction (55 features)
  4. ML inference (risk probability)
  5. Risk stratification (Low/Med/High)
  6. Display result (placeholder UI)
- [ ] Loading states:
  - "Analyzing audio..." (during feature extraction)
  - "Running AI analysis..." (during inference)
  - Progress indicator (spinner or percentage)
- [ ] Total processing time: ≤10 seconds (audio to result)
- [ ] Error handling at each step with user-friendly messages
- [ ] Integration test:
  - Record real voice sample
  - Verify entire pipeline executes
  - Verify result displayed
- [ ] Manual testing on physical Android device

**Technical Notes**:
- Use `provider` for state management
- Implement `ScreeningBloc` to orchestrate workflow
- Log each step for debugging

---

### Sprint 2 Summary

**Total Story Points**: 24

| Story ID | Story Title | Points | Status |
|----------|-------------|--------|--------|
| STORY-007 | ML Model Training - Baseline | 8 | 🔲 To Do |
| STORY-008 | TensorFlow Lite Conversion | 3 | 🔲 To Do |
| STORY-009 | Audio Feature Extraction | 5 | 🔲 To Do |
| STORY-010 | TFLite Inference Service | 5 | 🔲 To Do |
| STORY-011 | Risk Stratification Logic | 2 | 🔲 To Do |
| STORY-012 | End-to-End Pipeline Integration | 1 | 🔲 To Do |

**Sprint 2 Deliverables**:
- ✅ Trained TFLite model (≥85% accuracy)
- ✅ Feature extraction service (MFCC + prosodic)
- ✅ ML inference service (on-device)
- ✅ Complete inference pipeline (audio → risk score)
- ✅ End-to-end manual test successful

**Demo Scenario**:
1. Open app → Start new screening
2. Record 30-second voice sample
3. See "Analyzing..." loading state
4. Receive risk assessment: "72% - High Risk"
5. See recommended action: "Consult neurologist"

---

## Sprint 3: Results Display & CHW Workflow

**Sprint Goal**: "Build complete CHW screening workflow with professional results display and basic data storage"

**Duration**: Feb 10 - Feb 23, 2026 (2 weeks)  
**Total Story Points**: 22 points

---

### Stories in Sprint 3

---

#### **STORY-013**: Figma UI Design - Results Screen

**Epic**: EPIC-RESULT

**As a** UX designer (self),  
**I want to** create a professional results display design,  
**So that** CHWs can easily interpret and communicate screening results.

**Description**:
Design Figma mockups for results screen with color-coded risk indicator, clear action items, and patient-friendly visualizations.

**Story Points**: 3

**Acceptance Criteria**:
- [ ] Figma mockup for results screen (high-fidelity)
- [ ] Design includes:
  - **Hero element**: Large circular risk indicator
    - Color-coded (Green/Yellow/Red)
    - Risk percentage in center (e.g., "72%")
    - Risk label below (Low/Medium/High)
  - **Risk meter**: Horizontal bar showing risk level
  - **Recommended action card**:
    - Icon (checkmark/warning/alert)
    - Bold action text
    - Brief explanation (2-3 sentences)
  - **Secondary information** (collapsible):
    - Confidence score
    - Feature quality indicators
    - Timestamp
  - **Action buttons**:
    - "Refer to Hospital" (Primary CTA if High risk)
    - "Save & Finish" (Secondary)
    - "Record Again" (Tertiary)
- [ ] Accessibility:
  - High contrast for color-blind users
  - Text labels in addition to colors
  - Large font sizes (≥16pt body)
- [ ] Responsive design (4.5" - 6.7" screens)
- [ ] Design reviewed by advisor (optional)

**Design Inspiration**:
- Health app UIs (Apple Health, Google Fit)
- Traffic light metaphor (universal understanding)
- Minimal text, maximum visual communication

---

#### **STORY-014**: Results Display UI Implementation

**Epic**: EPIC-RESULT

**As a** CHW,  
**I want to** see screening results in a clear, visual format,  
**So that** I can quickly understand the patient's risk level.

**Description**:
Implement results screen UI based on Figma design. Show color-coded risk indicator, recommended actions, and secondary details.

**Story Points**: 5

**Acceptance Criteria**:
- [ ] Results screen matches Figma design ≥90%
- [ ] Risk indicator animation:
  - Fade in from center
  - Color transition (white → final color)
  - Scale animation (0.8 → 1.0)
- [ ] Dynamic content based on risk level:
  - **Low (Green)**:
    - Icon: Checkmark circle
    - Message: "No immediate concern"
    - Button: "Save & Finish" (green)
  - **Medium (Yellow)**:
    - Icon: Warning triangle
    - Message: "Possible early signs detected"
    - Button: "Schedule Follow-up" (yellow)
  - **High (Red)**:
    - Icon: Alert circle
    - Message: "Recommend neurologist consultation"
    - Button: "Refer to Hospital" (red, prominent)
- [ ] Expandable details section:
  - Tap "View Details" → expands
  - Shows: Confidence score, audio quality, timestamp
- [ ] Action buttons functional:
  - "Refer to Hospital" → Navigate to referral screen (placeholder)
  - "Save & Finish" → Save to database + return to home
  - "Record Again" → Clear results + return to recording
- [ ] Smooth animations (300ms duration)
- [ ] UI tested on 3+ screen sizes

**Technical Notes**:
- Use `flutter_animate` for animations
- Store risk result in state management (Provider/BLoC)
- Haptic feedback on result display (vibration for High risk)

---

#### **STORY-015**: SQLite Database Setup

**Epic**: EPIC-FOUND

**As a** developer,  
**I want to** set up a local SQLite database,  
**So that** I can persist screening records on the device.

**Description**:
Implement SQLite database with schema for screening records. Create database helper class with CRUD operations.

**Story Points**: 3

**Acceptance Criteria**:
- [ ] `DatabaseHelper` class created (singleton pattern)
- [ ] Database schema (from SRS):
  ```sql
  CREATE TABLE screenings (
    id TEXT PRIMARY KEY,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    patient_age INTEGER,
    patient_gender TEXT,
    language_detected TEXT,
    voice_file_path TEXT,
    risk_score REAL,
    risk_category TEXT,
    confidence_score REAL,
    chw_id TEXT,
    notes TEXT,
    deleted_at DATETIME NULL
  );
  ```
- [ ] CRUD methods:
  - `insertScreening(Screening screening)`
  - `getScreening(String id)`
  - `getAllScreenings()`
  - `getRecentScreenings(int limit)`
  - `updateScreening(Screening screening)`
  - `deleteScreening(String id)` (soft delete)
- [ ] Database versioning (for future migrations)
- [ ] Unit tests for each CRUD operation
- [ ] Database file location: `/data/data/com.neuroAccess.app/databases/`

**Technical Notes**:
- Use `sqflite` package
- Database name: `neuroAccess.db`
- Version 1.0
- Enable foreign keys

---

#### **STORY-016**: Screening Data Model & Persistence

**Epic**: EPIC-FOUND

**As a** CHW,  
**I want to** save screening results automatically,  
**So that** I can review past screenings later.

**Description**:
Create Screening model class and implement auto-save functionality. Ensure data persists across app restarts.

**Story Points**: 2

**Acceptance Criteria**:
- [ ] `Screening` model class created:
  ```dart
  class Screening {
    String id;
    DateTime createdAt;
    int patientAge;
    String patientGender;
    String languageDetected;
    String voiceFilePath;
    double riskScore;
    String riskCategory;
    double confidenceScore;
    String chwId;
    String? notes;
  }
  ```
- [ ] `toMap()` and `fromMap()` methods for SQLite conversion
- [ ] `ScreeningRepository` class (data access layer):
  - `saveScreening(Screening screening)`
  - `getRecentScreenings(int limit)`
  - `getScreeningById(String id)`
- [ ] Auto-save after results displayed:
  - Triggered when user taps "Save & Finish"
  - Success notification: "Screening saved"
- [ ] Data validation:
  - Required fields check
  - Age range validation (18-120)
  - Gender validation (M/F/O)
- [ ] Unit tests for model and repository
- [ ] Integration test: Save → Retrieve → Verify

**Technical Notes**:
- Use UUID for unique IDs (`uuid` package)
- CHW ID hardcoded for now (will be from login in future)
- Consider adding `copyWith()` method for immutability

---

#### **STORY-017**: CHW Dashboard - Recent Screenings List

**Epic**: EPIC-RESULT

**As a** CHW,  
**I want to** see a list of recent screenings on my dashboard,  
**So that** I can track my work and review past results.

**Description**:
Update home screen to display recent screenings list with summary cards. Enable tap to view details.

**Story Points**: 3

**Acceptance Criteria**:
- [ ] Dashboard shows:
  - **Header**: "Recent Screenings" + count
  - **List**: Last 10 screenings (scrollable)
  - **Empty state**: "No screenings yet. Tap + to start."
- [ ] Screening summary card includes:
  - Risk indicator icon (colored circle)
  - Patient demographics: "65-year-old Male"
  - Date/time: "2 hours ago" (relative time)
  - Risk category badge: "High Risk" (colored)
- [ ] Card interactions:
  - Tap → Navigate to screening details view
  - Swipe left → Delete option (with confirmation)
- [ ] List updates in real-time after new screening saved
- [ ] Pagination (if >10 screenings, show "Load More")
- [ ] Pull-to-refresh functionality
- [ ] UI matches Figma design (create if needed)

**Technical Notes**:
- Use `ListView.builder` for performance
- Use `timeago` package for relative timestamps
- Cache recent screenings in memory (refresh on app start)

---

#### **STORY-018**: Figma UI Design - Complete Workflow

**Epic**: EPIC-RESULT

**As a** UX designer (self),  
**I want to** design the complete CHW screening workflow,  
**So that** I have a cohesive user experience across all screens.

**Description**:
Create Figma designs for missing screens and ensure visual consistency across the entire app.

**Story Points**: 3

**Acceptance Criteria**:
- [ ] Figma designs for:
  - **Splash screen**: App logo + tagline
  - **Onboarding** (optional): 3-screen tutorial
  - **Patient info input**: Age, gender, consent
  - **Screening success**: Confirmation animation
  - **Dashboard**: Updated with recent screenings list
  - **Settings**: Language selection, CHW profile (placeholder)
- [ ] Design system established:
  - Color palette (Primary, Secondary, Success, Warning, Error)
  - Typography (font family, sizes, weights)
  - Icon set (Material Icons or custom)
  - Spacing system (8px grid)
  - Component library (buttons, cards, inputs)
- [ ] User flow diagram:
  - Home → Start Screening → Patient Info → Recording → Analysis → Results → Save → Home
- [ ] Animations documented:
  - Screen transitions
  - Button states
  - Loading indicators
- [ ] Accessibility annotations (contrast ratios, touch target sizes)
- [ ] Figma prototype with clickable hotspots (optional)

**Deliverable**:
- Figma link with all screens and design system

---

#### **STORY-019**: Patient Demographics Input Screen

**Epic**: EPIC-RESULT

**As a** CHW,  
**I want to** collect basic patient information before screening,  
**So that** I can associate results with demographics for tracking.

**Description**:
Implement patient info input screen with age, gender, and consent fields. Integrate into screening workflow before recording.

**Story Points**: 3

**Acceptance Criteria**:
- [ ] Patient info screen created (matches Figma)
- [ ] Input fields:
  - **Age**: Number input (18-120 range)
    - Large numeric keypad
    - Default: Empty (required)
  - **Gender**: Radio buttons
    - Male / Female / Other
    - Default: None (required)
  - **Consent**: Checkbox
    - "Patient consents to voice recording for screening purposes"
    - Default: Unchecked (required)
- [ ] Validation:
  - Age required and in range
  - Gender required
  - Consent required (cannot proceed without)
  - Show error messages inline
- [ ] "Next" button:
  - Disabled until all fields valid
  - Enabled → Navigate to recording screen
- [ ] "Back" button → Return to dashboard
- [ ] Data stored in `Screening` object (passed through workflow)
- [ ] UI tested on multiple screen sizes

**Technical Notes**:
- Use `Form` widget with `TextFormField` and validators
- Pass data via constructor or state management
- Consider accessibility: Labels, hints, error announcements

---

### Sprint 3 Summary

**Total Story Points**: 22

| Story ID | Story Title | Points | Status |
|----------|-------------|--------|--------|
| STORY-013 | Figma UI - Results Screen | 3 | 🔲 To Do |
| STORY-014 | Results Display UI | 5 | 🔲 To Do |
| STORY-015 | SQLite Database Setup | 3 | 🔲 To Do |
| STORY-016 | Screening Data Persistence | 2 | 🔲 To Do |
| STORY-017 | Dashboard - Recent Screenings | 3 | 🔲 To Do |
| STORY-018 | Figma UI - Complete Workflow | 3 | 🔲 To Do |
| STORY-019 | Patient Demographics Input | 3 | 🔲 To Do |

**Sprint 3 Deliverables**:
- ✅ Complete Figma designs for all screens
- ✅ Professional results display with animations
- ✅ SQLite database with screening persistence
- ✅ Dashboard with recent screenings list
- ✅ Patient info input integrated into workflow
- ✅ **MVP Complete**: End-to-end CHW screening workflow

**Demo Scenario** (Complete User Flow):
1. Open app → See dashboard with "Start Screening" button
2. Tap "Start Screening"
3. Enter patient info (age: 65, gender: Male, consent: Yes)
4. Record 30-second voice sample
5. See "Analyzing..." loading state (8 seconds)
6. View results: "72% - High Risk"
7. Tap "Refer to Hospital" (placeholder action)
8. Tap "Save & Finish"
9. Return to dashboard → See new screening in recent list
10. Tap screening card → View details

---

## Story Point Reference

### Fibonacci Scale

| Points | Complexity | Effort | Examples |
|--------|------------|--------|----------|
| **1** | Trivial | 1-2 hours | Config change, minor UI tweak |
| **2** | Simple | 2-4 hours | Simple service class, basic validation |
| **3** | Moderate | 4-8 hours | Database setup, UI screen implementation |
| **5** | Complex | 1-2 days | ML service integration, complex UI with animations |
| **8** | Very Complex | 2-4 days | ML model training, major feature integration |
| **13** | Epic-level | 1 week+ | Should be broken down into smaller stories |

### Velocity Calculation

**Sprint 1 Velocity**: 23 points (planned)  
**Sprint 2 Velocity**: 24 points (planned)  
**Sprint 3 Velocity**: 22 points (planned)

**Average**: ~23 points per sprint (solo developer, 2-week sprints)

---

## Definition of Done

### Story-Level DoD

A user story is considered "Done" when:

- [ ] **Code Complete**: All code written and committed to Git
- [ ] **Code Review**: Self-reviewed (or peer-reviewed if available)
- [ ] **Unit Tests**: All unit tests written and passing (≥80% coverage for critical paths)
- [ ] **Integration Tests**: Manual integration testing completed
- [ ] **UI Matches Design**: Figma design implemented ≥90% accurately
- [ ] **Documentation**: Code comments for complex logic
- [ ] **Acceptance Criteria**: All AC items checked off
- [ ] **No Critical Bugs**: No P0 or P1 bugs remaining
- [ ] **Device Tested**: Tested on physical Android device (not just emulator)

### Sprint-Level DoD

A sprint is considered "Done" when:

- [ ] **All Stories Done**: All committed stories meet Story-Level DoD
- [ ] **Sprint Goal Achieved**: Sprint goal statement is fulfilled
- [ ] **Demo Ready**: Working demo can be presented
- [ ] **Code Merged**: All code merged to `main` branch
- [ ] **Deployable**: App builds successfully and runs on target devices
- [ ] **Retrospective Complete**: Sprint retrospective conducted (self-reflection)
- [ ] **Next Sprint Planned**: Stories for next sprint prioritized

### Release-Level DoD (MVP - End of Sprint 3)

The MVP release is considered "Done" when:

- [ ] **All MVP Features**: Complete screening workflow functional
- [ ] **Performance**: Meets performance criteria (≤10min screening, ≤10% battery)
- [ ] **Stability**: No crashes in 50 consecutive screenings
- [ ] **UI/UX**: All screens match Figma designs
- [ ] **Data Persistence**: Screenings save and retrieve correctly
- [ ] **User Testing**: At least 3 test users (CHWs or proxies) complete workflow
- [ ] **Documentation**: README with setup and user guide
- [ ] **Code Quality**: Linting passes, no major code smells
- [ ] **Git Tagged**: Release tagged as `v0.1.0-mvp`

---

## Sprint Ceremonies (Solo Developer Adaptation)

### Sprint Planning (2 hours)
- **When**: Monday morning, Sprint start
- **Activities**:
  - Review product backlog
  - Select stories for sprint
  - Break down stories if needed
  - Estimate story points
  - Commit to sprint goal

### Daily Standup (Self-reflection, 15 min)
- **When**: Every morning
- **Format** (written log):
  - Yesterday: What I completed
  - Today: What I plan to work on
  - Blockers: Any impediments
- **Tool**: Notion, Google Doc, or GitHub Discussions

### Sprint Review/Demo (1 hour)
- **When**: Friday afternoon, Sprint end
- **Activities**:
  - Record demo video (Loom or screen recording)
  - Share with advisor (if available)
  - Document what was completed

### Sprint Retrospective (30 min)
- **When**: Friday afternoon, after review
- **Format** (written):
  - What went well?
  - What could be improved?
  - Action items for next sprint
- **Tool**: Personal journal or Trello board

---

## Risks & Mitigation

### Sprint 1-3 Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| **TFLite model accuracy drop** | Medium | High | Extensive validation, fallback to FP32 if needed |
| **Feature extraction too slow** | Medium | Medium | Profile code, optimize algorithms, consider native code |
| **Figma designs take too long** | Low | Medium | Use templates, limit iterations, simple > perfect |
| **Solo developer burnout** | Medium | High | Work 6 hours/day max, take weekends off, adjust scope if needed |
| **Android device compatibility** | Medium | Medium | Test on 3+ devices, use Android Studio emulators |
| **Database migration issues** | Low | Low | Version database schema, test migrations |

---

## Tools & Infrastructure

### Development Tools
- **IDE**: Visual Studio Code + Flutter/Dart extensions
- **Version Control**: Git + GitHub
- **Design**: Figma
- **Project Management**: GitHub Projects or Notion
- **CI/CD**: GitHub Actions (future)

### Testing Tools
- **Unit Testing**: `flutter_test`
- **Widget Testing**: `flutter_test` + `mockito`
- **Integration Testing**: Manual (future: `integration_test` package)
- **Device Testing**: Physical Android device + emulators

### ML Tools
- **Training**: Python, TensorFlow, Jupyter Notebook
- **Data**: UCI Parkinson's Dataset
- **Visualization**: Matplotlib, Seaborn
- **Model Conversion**: TensorFlow Lite Converter

---

## Backlog (Future Sprints)

### Potential Sprint 4-5 Stories (Preview)

- **STORY-020**: Multilingual Support - Swahili UI (Epic: EPIC-I18N)
- **STORY-021**: Referral Management - SMS Notification (Epic: EPIC-RESULT)
- **STORY-022**: Data Encryption - AES-256 (Epic: EPIC-SEC)
- **STORY-023**: CHW Training Module - Video Tutorial (Epic: EPIC-TRAIN)
- **STORY-024**: Audio Quality - Advanced Validation (Epic: EPIC-VOICE)
- **STORY-025**: Settings Screen - Language Selector (Epic: EPIC-I18N)
- **STORY-026**: Model Update - Hindi Language Support (Epic: EPIC-ML)

---

## Success Metrics

### Sprint 1 Success Metrics
- [ ] Voice recording works on ≥3 Android devices
- [ ] Figma designs completed and reviewed
- [ ] Code quality: Linter passes, no warnings

### Sprint 2 Success Metrics
- [ ] ML model accuracy ≥85% on test set
- [ ] TFLite model size ≤5MB
- [ ] End-to-end inference completes in ≤10 seconds

### Sprint 3 Success Metrics
- [ ] Complete workflow: Patient info → Recording → Results → Save
- [ ] Results display matches Figma design ≥90%
- [ ] ≥5 screenings saved to database successfully
- [ ] **MVP Demo Ready** for advisor presentation

---

## Next Steps (After Sprint 3)

### Immediate (Sprint 4)
- User testing with 3-5 pilot CHWs or proxies
- Multilingual support (Swahili translation)
- Data encryption implementation

### Short-term (Sprints 5-7)
- CHW training module
- Referral management with SMS
- Additional languages (Hindi, Amharic)

### Long-term (Sprint 8+)
- Field testing in Kenya
- Clinical validation study
- Open-source release

---

**Document Status**: ACTIVE - Sprints 1-3 Planned

**Next Update**: After Sprint 1 completion (Jan 26, 2026)

**Related Documents**:
- `DEVELOPMENT_PLAN_SRS.md` (Requirements Specification)
- `README.md` (Project Overview)
- GitHub Projects Board (Sprint Tracking)

---

**END OF SPRINT PLAN (Sprints 1-3)**

