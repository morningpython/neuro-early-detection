# Software Requirements Specification (SRS)
# NeuroAccess Development Plan

**Project**: NeuroAccess - AI-Powered Parkinson's Screening for Underserved Communities  
**Version**: 1.0  
**Date**: 2026년 1월 7일  
**Author**: Junho Lee, University of Michigan  
**Status**: Initial Requirements Definition

---

## Document Control

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-01-07 | Junho Lee | Initial SRS document |

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Overall Description](#2-overall-description)
3. [Functional Requirements](#3-functional-requirements)
4. [Non-Functional Requirements](#4-non-functional-requirements)
5. [System Architecture](#5-system-architecture)
6. [Data Requirements](#6-data-requirements)
7. [Interface Requirements](#7-interface-requirements)
8. [Quality Attributes](#8-quality-attributes)
9. [Constraints](#9-constraints)
10. [Acceptance Criteria](#10-acceptance-criteria)

---

## 1. Introduction

### 1.1 Purpose

This Software Requirements Specification (SRS) document provides a complete description of all functions and specifications for the NeuroAccess mobile application. NeuroAccess is an offline-first, AI-powered Parkinson's disease screening tool designed for deployment in low-resource healthcare settings through Community Health Workers (CHWs).

**Intended Audience**:
- Development team (mobile app, ML model, backend)
- UMich faculty advisors
- Partner organizations (KNH, UMich Kenya office)
- IRB reviewers
- Community health workers (end users)

### 1.2 Scope

**Product Name**: NeuroAccess

**Product Description**: A smartphone-based, multilingual screening tool that uses voice biomarker analysis to detect early signs of Parkinson's disease in underserved communities where neurological expertise is unavailable.

**Benefits**:
- Zero-cost screening accessible to low-income populations
- Early detection enabling timely intervention
- Community health worker empowerment
- Reduced healthcare disparities in neurological care

**Goals**:
1. Enable offline Parkinson's screening with ≥85% sensitivity
2. Support 6+ languages (English, Swahili, Hindi, Amharic, Hausa, Yoruba)
3. Complete screening in <10 minutes
4. Operate on devices costing <$100 USD
5. Maintain complete data privacy (no cloud uploads)
6. Train CHWs with <2 days of instruction

### 1.3 Definitions, Acronyms, and Abbreviations

| Term | Definition |
|------|------------|
| CHW | Community Health Worker - trained local health worker without medical degree |
| Edge AI | AI processing performed locally on device, not in cloud |
| MFCC | Mel-Frequency Cepstral Coefficients - audio feature extraction method |
| PD | Parkinson's Disease |
| UPDRS | Unified Parkinson's Disease Rating Scale - clinical assessment standard |
| IRB | Institutional Review Board - research ethics committee |
| KNH | Kenyatta National Hospital, Nairobi, Kenya |
| TFLite | TensorFlow Lite - machine learning framework for mobile devices |
| PWA | Progressive Web App - web application with offline capabilities |
| 2G | Second-generation cellular network (low bandwidth) |
| HPK | Hierarchical Partition Key (Azure Cosmos DB feature) |

### 1.4 References

1. UCI Machine Learning Repository - Parkinson's Dataset
2. WHO Guidelines on Task-Shifting (2008)
3. TensorFlow Lite Documentation
4. CIOMS International Ethical Guidelines for Health Research (2016)
5. Azure Cosmos DB Best Practices for AI Applications
6. Partners in Health CHW Training Manual

### 1.5 Overview

The remainder of this document provides:
- Overall product description and context
- Detailed functional requirements organized by feature
- Non-functional requirements (performance, security, usability)
- System architecture and design constraints
- Data requirements and management
- User interface specifications
- Quality attributes and acceptance criteria

---

## 2. Overall Description

### 2.1 Product Perspective

NeuroAccess is a **standalone mobile application** designed to operate independently without continuous internet connectivity. It fills a critical gap in the global healthcare ecosystem:

**Current State (Problem)**:
- 70% of Parkinson's patients live in low-resource settings
- Neurologist ratio in Sub-Saharan Africa: 0.03 per 1 million people
- Average diagnostic delay: 2-3 years from symptom onset
- 99% of PD research focused on high-income populations
- Existing tools require: expensive equipment, neurological expertise, internet connectivity

**NeuroAccess Solution**:
- Smartphone-only screening (no additional hardware)
- Designed for CHW operation (no medical degree required)
- Offline-first architecture (works without internet)
- Culturally adapted for diverse communities
- Complete data privacy (processing on-device)

**System Context**:

```
┌─────────────────────────────────────────────────────────────┐
│                    NeuroAccess Ecosystem                     │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐          ┌──────────────┐                │
│  │   CHW Device │◄────────►│Patient/Client│                │
│  │  (Android)   │          │ (Voice Input)│                │
│  └──────┬───────┘          └──────────────┘                │
│         │                                                    │
│         │ On-Device Processing (Edge AI)                    │
│         ▼                                                    │
│  ┌──────────────────────────────────────┐                  │
│  │   TensorFlow Lite Model (5MB)        │                  │
│  │   • MFCC Feature Extraction          │                  │
│  │   • Neural Network Inference         │                  │
│  │   • Risk Score Calculation           │                  │
│  └──────┬───────────────────────────────┘                  │
│         │                                                    │
│         ▼                                                    │
│  ┌──────────────┐          ┌──────────────┐                │
│  │  Local SQLite│          │   SMS (2G)   │                │
│  │   Database   │          │   Optional   │                │
│  └──────────────┘          └──────────────┘                │
│                                    │                         │
│                                    ▼                         │
│                           ┌─────────────────┐               │
│                           │ Referral System │               │
│                           │  (KNH Clinic)   │               │
│                           └─────────────────┘               │
└─────────────────────────────────────────────────────────────┘
```

**External Interfaces**:
1. **User Interface**: Touch-based mobile app (CHW and patient)
2. **Hardware**: Smartphone microphone for voice recording
3. **Optional Network**: SMS for result notification (2G compatible)
4. **Optional Backend**: Aggregate analytics only (no patient data)

### 2.2 Product Functions

High-level functional capabilities:

1. **Voice Recording & Analysis**
   - Capture 30-second voice samples
   - Extract language-agnostic acoustic features
   - Perform on-device ML inference
   - Generate risk score (Low/Medium/High)

2. **Multilingual Support**
   - Automatic language detection
   - UI translation (6+ languages)
   - Voice instruction in local languages
   - Language-agnostic biomarker extraction

3. **Offline Operation**
   - Complete functionality without internet
   - Local data storage (encrypted)
   - SMS-based result sharing (optional)
   - Background processing

4. **CHW Workflow**
   - Patient registration (minimal data)
   - Guided voice recording process
   - Quality check automation
   - Result interpretation guide
   - Referral decision support

5. **Data Privacy**
   - On-device encryption (AES-256)
   - No cloud upload
   - Automatic data retention management
   - GDPR/HIPAA compliance

6. **Quality Assurance**
   - Audio quality validation
   - CHW certification system
   - Recording best practices tutorial
   - Error detection and guidance

### 2.3 User Characteristics

**Primary User: Community Health Worker (CHW)**

| Characteristic | Description |
|----------------|-------------|
| **Education** | High school or equivalent; no medical degree |
| **Technology Skills** | Basic smartphone usage (calls, SMS); limited app experience |
| **Languages** | Local language + basic English (varies by region) |
| **Age Range** | 20-55 years |
| **Gender** | Predominantly female in many regions |
| **Training Time** | Must be operable with ≤2 days training |
| **Work Environment** | Community clinics, home visits, outdoor settings |
| **Internet Access** | Intermittent or none |

**Secondary User: Patient/Client**

| Characteristic | Description |
|----------------|-------------|
| **Age** | Primarily 50+ years (PD risk group) |
| **Literacy** | May be illiterate or low literacy |
| **Technology** | No smartphone ownership required |
| **Languages** | Local language only (no English) |
| **Health Literacy** | Limited understanding of Parkinson's disease |

**Tertiary User: Clinical Validator (Neurologist)**

| Characteristic | Description |
|----------------|-------------|
| **Role** | Validate AI predictions, clinical oversight |
| **Location** | Referral hospital (e.g., KNH) |
| **Need** | Access to screening results for referred patients |

### 2.4 Constraints

#### 2.4.1 Regulatory Constraints
- **IRB Approval Required**: UMich + partner institution (KNH)
- **GDPR Compliance**: For potential European expansion
- **HIPAA Considerations**: Health data protection standards
- **Not FDA Approved**: Tool is for screening/research, not diagnosis
- **Informed Consent**: Must obtain for all participants

#### 2.4.2 Hardware Constraints
- **Device Cost**: Must run on smartphones ≤$100 USD
- **OS Support**: Android 8.0+ (API Level 26+)
- **RAM**: Minimum 2GB RAM
- **Storage**: App size ≤5MB; data storage ≤50MB per 100 screenings
- **Battery**: ≤10% battery per screening
- **Microphone**: Standard smartphone mic (no external hardware)

#### 2.4.3 Network Constraints
- **Offline-First**: Must work with zero internet connectivity
- **2G Compatible**: SMS features must work on 2G networks
- **Bandwidth**: Model updates (if any) ≤10MB download
- **Latency**: Local processing only (no cloud latency)

#### 2.4.4 Environmental Constraints
- **Noise**: Must handle moderate ambient noise
- **Temperature**: Tropical climate (high heat/humidity)
- **Power**: May have intermittent electricity for charging
- **Connectivity**: Rural areas with no cell towers

#### 2.4.5 Cultural Constraints
- **Language Diversity**: 6+ languages required
- **Literacy**: UI must be usable by illiterate CHWs (icons, voice)
- **Trust**: Community acceptance through cultural adaptation
- **Gender**: Female CHWs preferred in some cultures

#### 2.4.6 Economic Constraints
- **Zero User Cost**: Must be free for patients and CHWs
- **Sustainability**: Low operational costs post-deployment
- **Maintenance**: Minimal technical support needed

### 2.5 Assumptions and Dependencies

#### Assumptions
1. CHWs have access to Android smartphones (organizational or personal)
2. Patients can produce voice samples (speak or vocalize)
3. Voice biomarkers for PD are consistent across languages
4. CHWs have basic smartphone literacy
5. Communities will accept technology-based screening
6. Partner hospitals can receive referrals from CHWs
7. Pilot study will have clinical validation from neurologists

#### Dependencies
1. **External Datasets**:
   - UCI Parkinson's Dataset (baseline training)
   - Italian PD Corpus (cross-lingual validation)
   - NEW multilingual data collection (Kenya, India)

2. **Technology Dependencies**:
   - TensorFlow Lite framework
   - Flutter SDK (mobile development)
   - Android SDK
   - librosa (audio processing - Python)

3. **Partnership Dependencies**:
   - UMich faculty advisor (project guidance)
   - KNH collaboration (clinical validation)
   - UMich Kenya office (logistics)
   - IRB approval (both institutions)

4. **Funding Dependencies**:
   - UMich Global Health Summer Internship ($2,000)
   - UROP Grant ($1,500)
   - Personal/crowdfunding ($500)

---

## 3. Functional Requirements

### 3.1 Voice Recording Module

**FR-VR-001: Voice Sample Capture**
- **Priority**: CRITICAL
- **Description**: System shall capture 30-second voice recordings using smartphone microphone
- **Inputs**: 
  - User action: Tap "Start Recording" button
  - Patient voice: Sustained phonation ("Ahhh") + sentence reading
- **Processing**:
  - Record audio at 16kHz, 16-bit PCM, mono
  - Display real-time waveform visualization
  - Show countdown timer (30 seconds)
- **Outputs**:
  - WAV file (480KB typical size)
  - Quality score (pass/fail)
- **Acceptance Criteria**:
  - Recording starts within 500ms of button tap
  - No audio clipping or distortion
  - Works on devices with minimum 2GB RAM

**FR-VR-002: Audio Quality Validation**
- **Priority**: HIGH
- **Description**: System shall automatically validate audio quality before processing
- **Quality Checks**:
  - Signal-to-noise ratio (SNR) >10dB
  - No significant clipping (amplitude >95% threshold)
  - Minimum duration: 10 seconds of actual voice
  - Frequency range check (80Hz - 8kHz)
- **Outputs**:
  - PASS: Proceed to analysis
  - FAIL: Display specific error (too quiet, too loud, too short)
  - Retry option (up to 3 attempts)
- **Acceptance Criteria**:
  - Detects poor quality with ≥90% accuracy
  - Provides actionable feedback to CHW

**FR-VR-003: Multi-Task Voice Protocol**
- **Priority**: HIGH
- **Description**: System shall guide user through standardized voice tasks
- **Tasks**:
  1. Sustained "Ahhh" (10 seconds)
  2. Read sentence in local language (10 seconds)
  3. Count 1-10 in local language (10 seconds)
- **Guidance**:
  - Visual instructions (icons + text)
  - Audio playback example (optional)
  - Progress indicator
- **Acceptance Criteria**:
  - CHW completes protocol in <5 minutes
  - 95% task completion rate in pilot study

**FR-VR-004: Language-Specific Prompts**
- **Priority**: MEDIUM
- **Description**: System shall provide voice recording instructions in 6+ languages
- **Languages**: English, Swahili, Hindi, Amharic, Hausa, Yoruba
- **Content**:
  - Text instructions
  - Example sentences (culturally appropriate)
  - Voice coach tips
- **Acceptance Criteria**:
  - All UI text translated
  - Native speaker validation for accuracy

---

### 3.2 Audio Feature Extraction Module

**FR-FE-001: MFCC Extraction**
- **Priority**: CRITICAL
- **Description**: System shall extract Mel-Frequency Cepstral Coefficients from voice recordings
- **Processing**:
  - Window size: 25ms
  - Hop length: 10ms
  - Number of coefficients: 13 MFCCs
  - Include delta and delta-delta features
- **Outputs**:
  - MFCC matrix (shape: [time_frames, 39])
  - Processed on-device (TFLite)
- **Performance**:
  - Processing time ≤5 seconds on target devices
  - Memory usage ≤100MB during processing

**FR-FE-002: Prosodic Features**
- **Priority**: HIGH
- **Description**: System shall extract prosodic and voice quality features
- **Features**:
  - Jitter (vocal fold vibration irregularity)
  - Shimmer (amplitude variation)
  - Harmonic-to-Noise Ratio (HNR)
  - Fundamental frequency (F0) statistics (mean, std, range)
- **Outputs**:
  - Feature vector (16 dimensions)
- **Acceptance Criteria**:
  - Feature extraction consistent across devices (±5% variance)
  - Language-agnostic (same features for all languages)

**FR-FE-003: Language Detection**
- **Priority**: MEDIUM
- **Description**: System shall automatically detect language of voice sample
- **Method**: 
  - Phonetic pattern recognition
  - Language probability distribution
- **Supported Languages**: English, Swahili, Hindi, Amharic, Hausa, Yoruba
- **Outputs**:
  - Detected language (code)
  - Confidence score (0-100%)
- **Acceptance Criteria**:
  - ≥90% accuracy in language detection
  - Falls back to manual selection if confidence <80%

---

### 3.3 Machine Learning Inference Module

**FR-ML-001: On-Device Inference**
- **Priority**: CRITICAL
- **Description**: System shall perform Parkinson's risk assessment using on-device ML model
- **Model Specifications**:
  - Framework: TensorFlow Lite
  - Model size: ≤5MB
  - Format: Quantized INT8
  - Architecture: Feedforward neural network (3-5 layers)
- **Inputs**:
  - MFCC features (39 dimensions × time frames)
  - Prosodic features (16 dimensions)
- **Outputs**:
  - PD probability (0.0 - 1.0)
  - Risk category (Low/Medium/High)
  - Confidence score
- **Performance**:
  - Inference time ≤3 seconds
  - CPU usage ≤50%
  - No internet required

**FR-ML-002: Risk Stratification**
- **Priority**: HIGH
- **Description**: System shall categorize screening results into actionable risk levels
- **Categories**:
  - **Low Risk** (0.0 - 0.33): No immediate action
  - **Medium Risk** (0.34 - 0.66): Monitor, re-screen in 6 months
  - **High Risk** (0.67 - 1.0): Immediate referral to neurologist
- **Output**:
  - Color-coded result (Green/Yellow/Red)
  - Text explanation (CHW-friendly language)
  - Recommended action
- **Acceptance Criteria**:
  - Sensitivity ≥85% (detect true PD cases)
  - Specificity ≥80% (avoid false positives)

**FR-ML-003: Model Performance Validation**
- **Priority**: HIGH
- **Description**: System shall track and report model performance metrics
- **Metrics**:
  - Accuracy, Sensitivity, Specificity
  - Positive/Negative Predictive Value
  - AUC-ROC score
- **Validation**:
  - Compare against neurologist diagnosis (gold standard)
  - Track performance by language
  - Track performance by geographic region
- **Reporting**:
  - Aggregated statistics (no individual patient data)
  - Export for research analysis

**FR-ML-004: Model Update Mechanism**
- **Priority**: LOW (Phase 2)
- **Description**: System shall support offline model updates
- **Process**:
  - Download new model (WiFi only, user-initiated)
  - Validate model checksum
  - Backup old model
  - Hot-swap without app restart
- **Security**:
  - Signed model packages
  - Version verification
- **Acceptance Criteria**:
  - Update completion in <2 minutes
  - Automatic rollback if new model fails

---

### 3.4 Data Storage Module

**FR-DS-001: Local Patient Records**
- **Priority**: CRITICAL
- **Description**: System shall store patient screening records locally on device
- **Data Schema** (SQLite):
  ```sql
  CREATE TABLE screenings (
    id TEXT PRIMARY KEY,
    timestamp DATETIME,
    patient_age INT,
    patient_gender TEXT,
    voice_file_path TEXT,
    risk_score REAL,
    risk_category TEXT,
    chw_id TEXT,
    language_detected TEXT,
    notes TEXT
  );
  ```
- **Privacy**:
  - AES-256 encryption at rest
  - No personally identifiable information (PII)
  - Patient consent recorded
- **Acceptance Criteria**:
  - Database read/write <100ms
  - Supports ≥1000 records per device
  - Auto-cleanup of old records (>1 year)

**FR-DS-002: Data Encryption**
- **Priority**: CRITICAL
- **Description**: System shall encrypt all health data stored on device
- **Method**:
  - AES-256-GCM encryption
  - Key derived from device hardware ID + app secret
  - Separate encryption for audio files
- **Scope**:
  - All screening records
  - Voice recordings
  - Patient demographics
- **Acceptance Criteria**:
  - Encryption/decryption overhead <500ms
  - No unencrypted data in temp files
  - Passes security audit

**FR-DS-003: Data Retention Policy**
- **Priority**: MEDIUM
- **Description**: System shall automatically manage data retention
- **Policy**:
  - Voice recordings: Delete after 7 days (post-analysis)
  - Screening results: Retain for 1 year
  - Aggregate statistics: Retain indefinitely (anonymized)
- **User Control**:
  - CHW can manually delete records
  - Export option before auto-deletion
- **Acceptance Criteria**:
  - Auto-deletion runs daily
  - User confirmation required for manual deletion

**FR-DS-004: Offline Sync (Optional)**
- **Priority**: LOW (Phase 2)
- **Description**: System shall synchronize anonymized aggregate data when internet available
- **Sync Data**:
  - Model performance metrics only
  - No patient records
  - No voice recordings
- **Trigger**:
  - Manual sync (WiFi only)
  - User consent required
- **Security**:
  - TLS 1.3 encryption in transit
  - Data anonymization before sync

---

### 3.5 User Interface Module

**FR-UI-001: CHW Dashboard**
- **Priority**: HIGH
- **Description**: System shall provide a simple, intuitive CHW home screen
- **Components**:
  - "Start New Screening" button (prominent)
  - Recent screenings list (last 10)
  - Pending referrals count
  - CHW stats (total screenings, accuracy)
- **Design Principles**:
  - Large touch targets (≥44px)
  - High contrast colors
  - Minimal text (icons preferred)
- **Acceptance Criteria**:
  - CHW can start screening in ≤2 taps
  - Dashboard loads in <1 second

**FR-UI-002: Screening Workflow**
- **Priority**: CRITICAL
- **Description**: System shall guide CHW through step-by-step screening process
- **Steps**:
  1. Patient consent
  2. Basic demographics (age, gender)
  3. Voice recording (3 tasks)
  4. Audio quality check
  5. Analysis (loading screen)
  6. Result display
  7. Action decision (refer/monitor/clear)
- **Navigation**:
  - Linear flow (no complex navigation)
  - Clear "Next" and "Back" buttons
  - Progress indicator (step 2 of 7)
- **Acceptance Criteria**:
  - Complete workflow in <10 minutes
  - No workflow errors in user testing

**FR-UI-003: Result Visualization**
- **Priority**: HIGH
- **Description**: System shall display screening results in CHW-friendly format
- **Visual Elements**:
  - Large color-coded icon (Green/Yellow/Red)
  - Risk percentage (e.g., "72% High Risk")
  - Plain language explanation
  - Recommended action (bold text)
- **Information Hierarchy**:
  - Primary: Risk category (largest)
  - Secondary: Recommended action
  - Tertiary: Technical details (collapsible)
- **Acceptance Criteria**:
  - CHW can interpret result in <30 seconds
  - 90% comprehension rate in user testing

**FR-UI-004: Multilingual UI**
- **Priority**: HIGH
- **Description**: System shall support complete UI translation
- **Languages**: English, Swahili, Hindi, Amharic, Hausa, Yoruba (Phase 1)
- **Translation Scope**:
  - All buttons, labels, instructions
  - Error messages
  - Help text
  - Result explanations
- **Language Selection**:
  - Automatic detection from device settings
  - Manual override in settings
- **Acceptance Criteria**:
  - All strings externalized (i18n)
  - Native speaker review for accuracy
  - Right-to-left (RTL) support (future: Arabic)

**FR-UI-005: Offline Indicator**
- **Priority**: MEDIUM
- **Description**: System shall clearly indicate offline/online status
- **Indicator**:
  - Persistent icon in status bar
  - Green: Online (optional sync available)
  - Gray: Offline (normal operation)
- **Behavior**:
  - No functionality loss when offline
  - Optional sync prompt when online
- **Acceptance Criteria**:
  - Status updated within 5 seconds of connectivity change
  - No user confusion about offline capabilities

---

### 3.6 Referral Management Module

**FR-RM-001: Referral Decision Support**
- **Priority**: HIGH
- **Description**: System shall provide clear guidance on when to refer patients
- **Criteria**:
  - Auto-suggest referral for High Risk (≥67%)
  - Optional referral for Medium Risk (34-66%)
  - No referral for Low Risk (<34%)
- **Guidance**:
  - Display referral hospital contact (e.g., KNH Neurology)
  - Suggested urgency (immediate, within 1 week, routine)
  - Pre-filled referral form
- **Acceptance Criteria**:
  - CHW correctly identifies referral need in ≥95% of cases
  - Referral form completed in <3 minutes

**FR-RM-002: SMS Referral Notification**
- **Priority**: MEDIUM
- **Description**: System shall send SMS notification to patient or family (with consent)
- **Content**:
  - Screening result (simplified)
  - Referral hospital name and contact
  - Appointment recommendation
  - Message in patient's language
- **Consent**:
  - Patient opt-in required
  - Phone number collection
- **Limitations**:
  - 160 characters (single SMS)
  - 2G network compatible
- **Acceptance Criteria**:
  - SMS sent within 1 minute of result
  - Delivery confirmation logged
  - <5% SMS failure rate

**FR-RM-003: Referral Tracking**
- **Priority**: LOW (Phase 2)
- **Description**: System shall track referral completion status
- **Data Collected**:
  - Referral issued date
  - Hospital visited (yes/no)
  - Clinical diagnosis outcome (if shared back)
- **Purpose**:
  - Validate AI predictions
  - Measure referral pathway effectiveness
- **Privacy**:
  - Optional feature (CHW discretion)
  - Anonymized for research
- **Acceptance Criteria**:
  - ≥50% referral completion tracking rate
  - No identifiable patient data in analytics

---

### 3.7 CHW Training Module

**FR-TR-001: Interactive Tutorial**
- **Priority**: HIGH
- **Description**: System shall provide built-in CHW training content
- **Content**:
  - What is Parkinson's disease? (2-minute video)
  - How voice screening works (3-minute video)
  - Step-by-step app tutorial (interactive)
  - Recording best practices (visual guide)
- **Format**:
  - Offline video playback
  - Interactive simulations
  - Quizzes for comprehension check
- **Languages**: All supported UI languages
- **Acceptance Criteria**:
  - CHW can complete training in ≤2 hours
  - ≥80% quiz pass rate

**FR-TR-002: Certification Test**
- **Priority**: MEDIUM
- **Description**: System shall assess CHW competency before live use
- **Test Format**:
  - 5 practice screenings with simulated patients
  - Must achieve ≥4/5 successful completions
  - Includes common error scenarios
- **Certification**:
  - Certificate stored locally
  - Expires after 1 year (re-certification required)
- **Acceptance Criteria**:
  - ≥90% CHWs pass on first attempt (after training)
  - Certified CHWs show <5% workflow errors

**FR-TR-003: Help & Reference**
- **Priority**: MEDIUM
- **Description**: System shall provide on-demand help content
- **Content**:
  - Searchable FAQ
  - Troubleshooting guide
  - Video demonstrations
  - Contact information for technical support
- **Accessibility**:
  - Accessible from any screen (help icon)
  - Context-sensitive help (relevant to current screen)
- **Acceptance Criteria**:
  - CHW finds answer within 2 minutes for common issues
  - ≥80% self-service resolution rate

---

### 3.8 Analytics & Reporting Module

**FR-AR-001: CHW Performance Dashboard**
- **Priority**: LOW (Phase 2)
- **Description**: System shall provide CHW with screening statistics
- **Metrics**:
  - Total screenings conducted
  - Risk distribution (Low/Medium/High counts)
  - Average screenings per week
  - Audio quality pass rate
- **Visualization**:
  - Simple bar charts
  - Trend over time
- **Privacy**:
  - Aggregated data only
  - No individual patient identification
- **Acceptance Criteria**:
  - Dashboard updates in real-time
  - Motivates CHW performance improvement

**FR-AR-002: Research Data Export**
- **Priority**: LOW (Phase 2)
- **Description**: System shall export anonymized data for research
- **Export Format**: CSV file
- **Data Included**:
  - Age, gender, language
  - Risk score, category
  - MFCC features (anonymized)
  - Timestamp (date only, no time)
- **Exclusions**:
  - No names, phone numbers, addresses
  - No voice recordings
- **Security**:
  - Password-protected file
  - Local storage only (no auto-upload)
- **Acceptance Criteria**:
  - Export completes in <10 seconds for 100 records
  - Data anonymization verified by audit

---

## 4. Non-Functional Requirements

### 4.1 Performance Requirements

**NFR-PERF-001: Response Time**
- Voice recording start: <500ms from button tap
- Feature extraction: ≤5 seconds
- ML inference: ≤3 seconds
- Total screening time: <10 minutes (end-to-end)
- UI responsiveness: <100ms for button taps

**NFR-PERF-002: Throughput**
- Support 50 screenings per day per CHW
- Database query performance: <100ms
- Support 1000+ historical records per device

**NFR-PERF-003: Resource Usage**
- RAM: ≤200MB during active screening
- Storage: ≤50MB for 100 screenings (after audio cleanup)
- Battery: ≤10% per screening
- CPU: ≤50% average utilization

**NFR-PERF-004: Scalability**
- Support 1000+ active CHWs concurrently
- Database size: ≤500MB maximum
- Model updates: Support phased rollout (10% → 50% → 100%)

---

### 4.2 Security Requirements

**NFR-SEC-001: Data Encryption**
- All health data encrypted at rest (AES-256)
- Secure key derivation (device hardware + app secret)
- No unencrypted data in logs or temp files

**NFR-SEC-002: Authentication**
- CHW login with PIN (6 digits) or biometric
- Session timeout after 30 minutes of inactivity
- Account lockout after 5 failed attempts

**NFR-SEC-003: Authorization**
- CHWs can only access their own screening records
- No data sharing between CHW accounts on same device
- Admin role for research team (view aggregate data only)

**NFR-SEC-004: Privacy**
- No patient data leaves device (offline-first)
- Optional SMS requires explicit consent
- Compliance with GDPR, HIPAA principles
- Data minimization (collect only essential fields)

**NFR-SEC-005: Audit Logging**
- Log all data access events (who, when, what action)
- Tamper-evident log storage
- Log retention: 1 year

---

### 4.3 Reliability Requirements

**NFR-REL-001: Availability**
- Offline availability: 100% (no internet dependency)
- App uptime: ≥99.9% (excluding device failures)
- Graceful degradation if optional features fail (e.g., SMS)

**NFR-REL-002: Fault Tolerance**
- Auto-save screening progress every 30 seconds
- Crash recovery: Resume from last saved state
- Error handling: User-friendly error messages (no technical jargon)

**NFR-REL-003: Data Integrity**
- Database transactions (ACID compliance)
- Checksum validation for voice recordings
- Backup mechanism for critical data

**NFR-REL-004: Mean Time Between Failures (MTBF)**
- Target: ≥1000 screenings between crashes
- Monitoring: Crash analytics (opt-in, anonymized)

---

### 4.4 Usability Requirements

**NFR-USA-001: Learnability**
- CHW can complete first screening independently after ≤2 days training
- 90% of CHWs pass certification test on first attempt
- User manual: ≤20 pages, visual-heavy

**NFR-USA-002: Efficiency**
- Experienced CHW completes screening in ≤7 minutes
- ≤3 taps to start new screening from home screen
- Minimal data entry (only age, gender)

**NFR-USA-003: Memorability**
- CHW can resume use after 1 month without re-training
- Key workflows obvious from UI (no hidden features)

**NFR-USA-004: Error Prevention**
- Confirmation dialogs for destructive actions (delete record)
- Input validation (age range, required fields)
- Clear error messages with recovery steps

**NFR-USA-005: Accessibility**
- Font size: Minimum 16pt for body text
- Touch targets: Minimum 44×44 pixels
- Color contrast: WCAG AA compliance
- Screen reader compatibility (future: Phase 2)

---

### 4.5 Portability Requirements

**NFR-PORT-001: Platform Support**
- Primary: Android 8.0+ (API Level 26+)
- Future: iOS 13+ (Phase 2)
- Device types: Smartphones only (no tablets)

**NFR-PORT-002: Device Compatibility**
- Screen sizes: 4.5" - 6.7" diagonal
- Resolutions: 720p (HD) to 1080p (FHD)
- Processors: ARM, ARM64, x86 (emulator)

**NFR-PORT-003: Localization**
- Languages: 6+ (Phase 1), expandable to 50+
- Date/time formats: Locale-aware
- Number formats: Locale-aware

---

### 4.6 Maintainability Requirements

**NFR-MAIN-001: Modularity**
- Clean separation: UI, business logic, ML model, data layer
- Model updates without app reinstall
- Plugin architecture for new languages

**NFR-MAIN-002: Documentation**
- Code documentation: Inline comments for complex algorithms
- API documentation: Auto-generated from code
- User documentation: 6+ languages
- Deployment guide: Step-by-step for CHW supervisors

**NFR-MAIN-003: Testing**
- Unit test coverage: ≥80%
- Integration tests for critical workflows
- Manual QA before each release
- Field testing in Kenya (pilot study)

**NFR-MAIN-004: Version Control**
- Git repository with semantic versioning
- Release notes for each version
- Backwards compatibility for data formats

---

### 4.7 Compliance Requirements

**NFR-COMP-001: Research Ethics**
- IRB approval: UMich + KNH
- Informed consent: Digital signature capture
- Data sovereignty: Patient data stays in country of origin
- Community benefit plan: Documented and executed

**NFR-COMP-002: Health Data Regulations**
- GDPR principles (even if not EU deployment)
- HIPAA principles (health data protection)
- Kenya Data Protection Act 2019 compliance

**NFR-COMP-003: Medical Device Regulations**
- NOT a medical device (screening tool only)
- Disclaimer: "Not for diagnosis - consult neurologist"
- Clear labeling: "Research tool" during pilot phase

---

## 5. System Architecture

### 5.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    NeuroAccess Mobile App                    │
│                       (Flutter + Dart)                        │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              Presentation Layer (UI)                  │  │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌──────────┐   │  │
│  │  │Dashboard│ │Screening│ │ Results │ │ Training │   │  │
│  │  │ Screen  │ │ Workflow│ │ Display │ │  Module  │   │  │
│  │  └─────────┘ └─────────┘ └─────────┘ └──────────┘   │  │
│  └───────────────────────────────────────────────────────┘  │
│                            │                                 │
│  ┌───────────────────────────────────────────────────────┐  │
│  │             Business Logic Layer (BLoC)               │  │
│  │  ┌──────────┐ ┌───────────┐ ┌─────────┐             │  │
│  │  │Screening │ │ Recording │ │Referral │             │  │
│  │  │ Manager  │ │  Manager  │ │ Manager │             │  │
│  │  └──────────┘ └───────────┘ └─────────┘             │  │
│  └───────────────────────────────────────────────────────┘  │
│                            │                                 │
│  ┌───────────────────────────────────────────────────────┐  │
│  │               Service Layer                           │  │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌──────────┐   │  │
│  │  │  Audio  │ │   ML    │ │ Storage │ │   SMS    │   │  │
│  │  │ Service │ │ Service │ │ Service │ │ Service  │   │  │
│  │  └─────────┘ └─────────┘ └─────────┘ └──────────┘   │  │
│  └───────────────────────────────────────────────────────┘  │
│                            │                                 │
│  ┌───────────────────────────────────────────────────────┐  │
│  │               Data Layer                              │  │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐             │  │
│  │  │ SQLite   │ │ TFLite   │ │  File    │             │  │
│  │  │   DB     │ │  Model   │ │ Storage  │             │  │
│  │  └──────────┘ └──────────┘ └──────────┘             │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

### 5.2 Component Descriptions

**Presentation Layer (Flutter UI)**
- Dashboard Screen: CHW home with recent screenings
- Screening Workflow: Step-by-step guided process
- Results Display: Visual risk presentation
- Training Module: Built-in tutorials and certification

**Business Logic Layer (BLoC Pattern)**
- Screening Manager: Orchestrates screening workflow
- Recording Manager: Handles audio capture and validation
- Referral Manager: Decision support and SMS

**Service Layer**
- Audio Service: Recording, playback, feature extraction
- ML Service: TensorFlow Lite inference
- Storage Service: SQLite CRUD operations, encryption
- SMS Service: 2G-compatible messaging

**Data Layer**
- SQLite DB: Screening records, CHW data
- TFLite Model: Quantized neural network (5MB)
- File Storage: Voice recordings (temporary), logs

### 5.3 Data Flow Diagram

**Screening Workflow Data Flow:**

```
┌──────────┐
│ Patient  │
│  Voice   │
└────┬─────┘
     │
     ▼
┌──────────────┐
│ Microphone   │──┐
│  (Hardware)  │  │ 16kHz, 16-bit PCM
└──────────────┘  │
                  ▼
        ┌──────────────────┐
        │  Audio Service   │
        │ (Quality Check)  │
        └─────────┬────────┘
                  │ Pass
                  ▼
        ┌──────────────────┐
        │  Feature Extract │
        │  (MFCC, Jitter)  │
        └─────────┬────────┘
                  │ Features (55D vector)
                  ▼
        ┌──────────────────┐
        │  ML Service      │
        │ (TFLite Model)   │
        └─────────┬────────┘
                  │ Risk Score (0-1)
                  ▼
        ┌──────────────────┐
        │ Risk Stratify    │
        │ (Low/Med/High)   │
        └─────────┬────────┘
                  │
         ┌────────┴────────┐
         │                 │
         ▼                 ▼
 ┌──────────────┐  ┌──────────────┐
 │ Storage      │  │ UI Display   │
 │ (SQLite)     │  │ (Results)    │
 └──────────────┘  └──────┬───────┘
                          │
                          ▼
                  ┌──────────────┐
                  │  Referral?   │
                  │  (If High)   │
                  └──────┬───────┘
                         │
                         ▼
                  ┌──────────────┐
                  │ SMS Service  │
                  │ (Optional)   │
                  └──────────────┘
```

---

## 6. Data Requirements

### 6.1 Database Schema

**Screenings Table**
```sql
CREATE TABLE screenings (
    id TEXT PRIMARY KEY,                    -- UUID
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    patient_age INTEGER CHECK (age >= 18 AND age <= 120),
    patient_gender TEXT CHECK (gender IN ('M', 'F', 'O')),
    language_detected TEXT,                 -- ISO 639-1 code
    voice_file_path TEXT,                   -- Local file path
    mfcc_features BLOB,                     -- Serialized feature vector
    risk_score REAL CHECK (risk_score >= 0 AND risk_score <= 1),
    risk_category TEXT CHECK (risk_category IN ('Low', 'Medium', 'High')),
    confidence_score REAL,
    chw_id TEXT,                            -- CHW identifier
    location_code TEXT,                     -- Community/clinic code (no GPS)
    referral_issued BOOLEAN DEFAULT 0,
    referral_hospital TEXT,
    notes TEXT,
    consent_given BOOLEAN DEFAULT 1,
    deleted_at DATETIME NULL                -- Soft delete
);

CREATE INDEX idx_created_at ON screenings(created_at);
CREATE INDEX idx_chw_id ON screenings(chw_id);
CREATE INDEX idx_risk_category ON screenings(risk_category);
```

**CHW Accounts Table**
```sql
CREATE TABLE chw_accounts (
    chw_id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    pin_hash TEXT NOT NULL,                 -- Hashed PIN
    certification_date DATETIME,
    certification_expires DATETIME,
    total_screenings INTEGER DEFAULT 0,
    last_active DATETIME,
    language_preference TEXT DEFAULT 'en'
);
```

**Audit Log Table**
```sql
CREATE TABLE audit_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    chw_id TEXT,
    action TEXT,                            -- 'CREATE', 'READ', 'UPDATE', 'DELETE'
    table_name TEXT,
    record_id TEXT,
    details TEXT
);
```

### 6.2 File Storage Structure

```
/storage/emulated/0/Android/data/com.neuroAccess.app/files/
├── audio/
│   ├── recording_[uuid].wav               (deleted after 7 days)
│   └── ...
├── models/
│   ├── parkinson_model_v1.0.tflite       (5MB)
│   ├── parkinson_model_v1.1.tflite       (backup)
│   └── model_checksum.txt
├── database/
│   └── neuroAccess.db                     (encrypted SQLite)
├── exports/
│   └── research_export_[date].csv         (manual exports)
└── logs/
    └── app_log_[date].txt                 (debugging, auto-cleanup)
```

### 6.3 Data Retention Policy

| Data Type | Retention Period | Deletion Method |
|-----------|------------------|-----------------|
| Voice recordings | 7 days | Automatic (after analysis complete) |
| Screening results | 1 year | Automatic (soft delete) |
| Aggregate statistics | Indefinite | N/A (anonymized) |
| Audit logs | 1 year | Automatic |
| CHW account data | Active + 2 years | Manual (GDPR request) |

---

## 7. Interface Requirements

### 7.1 User Interfaces

**UI-001: Material Design Compliance**
- Follow Google Material Design 3 guidelines
- Use Material Components for Flutter
- Consistent color scheme (branded)
- Accessibility: WCAG AA contrast ratios

**UI-002: Screen Specifications**

1. **Dashboard Screen**
   - "Start Screening" button (FAB, bottom-right)
   - Recent screenings card list (last 10)
   - Statistics summary (total screenings, pending referrals)
   - Settings icon (top-right)

2. **Screening Workflow Screens** (7 steps)
   - Step 1: Consent confirmation
   - Step 2: Demographics input (age, gender)
   - Step 3: Voice task 1 (Sustained "Ahhh")
   - Step 4: Voice task 2 (Sentence reading)
   - Step 5: Voice task 3 (Counting)
   - Step 6: Processing (loading animation)
   - Step 7: Results display

3. **Results Screen**
   - Risk indicator (large icon, color-coded)
   - Risk percentage
   - Recommended action (card)
   - "Refer to Hospital" button (if High risk)
   - "Save & Finish" button

4. **Training Screen**
   - Tutorial video player
   - Interactive simulation
   - Certification quiz
   - Certificate display (upon passing)

5. **Settings Screen**
   - Language selection
   - CHW profile management
   - Data export
   - About & version info

### 7.2 Hardware Interfaces

**HW-001: Microphone**
- Access Android AudioRecord API
- Sample rate: 16kHz
- Bit depth: 16-bit PCM
- Channel: Mono
- Buffer size: 4096 samples

**HW-002: Storage**
- Access Android File I/O APIs
- Internal storage (app-private directory)
- Minimum 500MB free space required

**HW-003: SMS (Optional)**
- Access Android SmsManager API
- 2G/3G/4G compatible
- Requires SMS permission (runtime request)

---

## 8. Quality Attributes

### 8.1 Correctness
- **Clinical Accuracy**: ≥85% sensitivity, ≥80% specificity
- **Language Detection**: ≥90% accuracy
- **Feature Extraction**: Consistent across devices (±5% variance)

### 8.2 Robustness
- Handles ambient noise (SNR >10dB requirement)
- Graceful failure for poor audio quality
- Crash recovery with state restoration
- Offline operation in 100% of workflows

### 8.3 Efficiency
- Battery usage: ≤10% per screening
- Storage: ≤50MB per 100 screenings
- Processing time: <10 seconds total per screening

### 8.4 Integrity
- Data encryption at rest (AES-256)
- Tamper-evident audit logs
- Checksum validation for model files

### 8.5 Usability
- ≤2 days CHW training required
- ≤10 minutes per screening
- 90% CHW satisfaction rate

### 8.6 Maintainability
- Modular code architecture
- Model hot-swappable
- Comprehensive documentation

---

## 9. Constraints

### 9.1 Technical Constraints
- Must work offline (no internet dependency)
- Model size ≤5MB (device storage limits)
- Android 8.0+ only (API level 26+)
- No cloud infrastructure (privacy requirement)

### 9.2 Regulatory Constraints
- IRB approval required before deployment
- Not FDA-approved (research tool only)
- GDPR/HIPAA principles compliance
- Informed consent mandatory

### 9.3 Operational Constraints
- CHWs have limited technical training
- Devices may be shared among CHWs
- Intermittent electricity for charging
- 2G networks only in some regions

### 9.4 Economic Constraints
- Zero cost to patients
- Minimal operational costs (SMS only)
- Open-source (no licensing fees)

---

## 10. Acceptance Criteria

### 10.1 Phase 1 Acceptance (Prototype - March 2026)

**Functional Acceptance:**
- [ ] Voice recording works on 3+ Android devices
- [ ] MFCC feature extraction completes in ≤5 seconds
- [ ] ML model inference produces risk score
- [ ] Results display on UI in correct format
- [ ] SQLite database stores screening records
- [ ] UI supports English + 1 other language (Swahili)

**Performance Acceptance:**
- [ ] App launches in ≤2 seconds
- [ ] Recording starts in ≤500ms
- [ ] Total screening time ≤10 minutes
- [ ] No crashes in 50 consecutive screenings

**Usability Acceptance:**
- [ ] 3 test CHWs can complete screening independently
- [ ] CHW feedback: ≥7/10 satisfaction score

---

### 10.2 Phase 2 Acceptance (Pilot Ready - May 2026)

**Functional Acceptance:**
- [ ] All 7 workflow steps operational
- [ ] 6 languages supported (English, Swahili, Hindi, Amharic, Hausa, Yoruba)
- [ ] SMS referral notification works
- [ ] CHW training module complete (videos, quiz, certification)
- [ ] Data encryption implemented and tested
- [ ] Offline operation verified (airplane mode test)

**Performance Acceptance:**
- [ ] 100 screenings on single device without errors
- [ ] Model accuracy ≥85% sensitivity on UCI dataset
- [ ] Battery usage ≤10% per screening (tested on 3 devices)

**Security Acceptance:**
- [ ] Penetration testing passed
- [ ] Data encryption audit passed
- [ ] No PII leakage in logs

**Regulatory Acceptance:**
- [ ] UMich IRB approval received
- [ ] KNH IRB approval received
- [ ] Informed consent process validated

---

### 10.3 Phase 3 Acceptance (Kenya Pilot - August 2026)

**Clinical Acceptance:**
- [ ] 100 screenings completed in Nairobi
- [ ] Sensitivity ≥85%, Specificity ≥80% (vs neurologist diagnosis)
- [ ] Positive Predictive Value ≥70%
- [ ] Referral completion rate ≥50%

**Operational Acceptance:**
- [ ] 10 CHWs certified and operational
- [ ] CHW screening completion rate ≥90%
- [ ] Average screening time ≤7 minutes
- [ ] App crash rate <5%

**Community Acceptance:**
- [ ] Patient satisfaction ≥80%
- [ ] CHW satisfaction ≥90%
- [ ] Community leader endorsement letters (3+)
- [ ] ≥80% consent rate for participation

**Research Acceptance:**
- [ ] 50+ Swahili voice samples collected
- [ ] Multilingual model accuracy validated
- [ ] Data quality sufficient for publication
- [ ] IRB compliance confirmed (no violations)

---

### 10.4 Success Metrics Summary

| Metric Category | Target | Measurement Method |
|-----------------|--------|-------------------|
| **Clinical Accuracy** | ≥85% sensitivity, ≥80% specificity | Comparison with neurologist diagnosis |
| **Operational Efficiency** | ≤10 min screening time | Time tracking in app |
| **CHW Adoption** | ≥90% satisfaction | Post-pilot survey |
| **Community Acceptance** | ≥80% consent rate | Consent tracking |
| **System Reliability** | <5% crash rate | Crash analytics |
| **Referral Completion** | ≥50% follow-through | Hospital records |
| **Data Quality** | ≥90% usable samples | Manual QA review |
| **Cost Efficiency** | ≤$40 per screening | Budget tracking |

---

## Appendix A: Glossary

**Community Health Worker (CHW)**: Trained local health worker without medical degree who provides basic health services in underserved communities.

**Edge AI**: Artificial intelligence processing performed locally on a device (smartphone, IoT device) rather than in the cloud.

**MFCC (Mel-Frequency Cepstral Coefficients)**: Audio feature extraction technique that represents the short-term power spectrum of sound, commonly used in speech and audio processing.

**Parkinson's Disease (PD)**: Progressive neurological disorder affecting movement, characterized by tremor, rigidity, and bradykinesia (slowness of movement).

**Sensitivity**: True positive rate - percentage of actual PD cases correctly identified by the screening tool.

**Specificity**: True negative rate - percentage of healthy individuals correctly identified as not having PD.

**TensorFlow Lite (TFLite)**: Lightweight machine learning framework designed for mobile and embedded devices.

**UPDRS (Unified Parkinson's Disease Rating Scale)**: Clinical assessment tool used by neurologists to measure PD severity (gold standard).

---

## Appendix B: Risk Analysis

| Risk | Probability | Impact | Mitigation Strategy |
|------|-------------|--------|---------------------|
| **IRB approval delayed** | Medium | High | Apply early (March), have backup timeline |
| **Model accuracy below target** | Medium | Critical | Extensive validation, iterative improvement |
| **CHW adoption low** | Low | High | Co-design with CHWs, intensive training |
| **Technical failure in field** | Medium | Medium | Offline-first, robust error handling |
| **Community distrust** | Low | High | Extensive pre-engagement, local champions |
| **Funding shortfall** | Medium | Medium | Phased development, minimal viable product |
| **Multilingual model fails** | High | High | Language-agnostic features, fallback to English |
| **Device compatibility issues** | Medium | Medium | Test on 10+ devices, minimum specs |
| **Data privacy breach** | Low | Critical | Encryption, audit, security testing |
| **Referral pathway broken** | Medium | High | Backup hospitals, direct patient education |

---

## Appendix C: Development Phases

**Phase 1 (Jan-Mar 2026): Foundation**
- Baseline ML model training (UCI dataset)
- Basic Android app (voice recording + inference)
- English UI only
- Local testing

**Phase 2 (Apr-Jun 2026): Multilingual Expansion**
- 6 languages supported
- CHW training module
- SMS integration
- IRB approvals

**Phase 3 (Jun-Aug 2026): Kenya Pilot**
- Field deployment (Nairobi)
- 100 screenings
- Clinical validation
- Data collection

**Phase 4 (Sep-Dec 2026): Scale & Research**
- Expand to India, Ethiopia
- 500+ total screenings
- Research publication
- Open-source release

---

## Document Approval

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Project Lead | Junho Lee | __________ | 2026-01-07 |
| Faculty Advisor | TBD | __________ | _______ |
| KNH Collaborator | TBD | __________ | _______ |
| IRB Chair (UMich) | TBD | __________ | _______ |

---

**END OF DOCUMENT**

---

**Version History**

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-01-07 | Junho Lee | Initial SRS document based on project README and partnership strategy |

---

**Document Status**: DRAFT - Pending Faculty Review

**Next Review Date**: 2026-01-20

**Related Documents**:
- README.md (Project Overview)
- FACULTY_CONTACTS.md (Partnership Strategy)
- PARTNERSHIPS.md (Kenya Pilot Plan)
- CONTRIBUTING.md (Development Guidelines)
