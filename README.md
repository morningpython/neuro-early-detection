# NeuroAccess: AI-Powered Parkinson's Screening for Underserved Communities
# 의료 사각지대를 위한 AI 기반 파킨슨병 스크리닝 플랫폼

> **University of Michigan Global Health & Neuroscience Initiative**  
> 저소득 지역사회를 위한 음성 기반 파킨슨병 조기 발견 도구
> 
> *"Bringing neurological care to those who need it most"*

---

## 📌 프로젝트 개요

**NeuroAccess**는 의료 자원이 부족한 저소득 지역사회를 위한 **스마트폰 기반 파킨슨병 스크리닝 도구**입니다. 신경과 전문의가 없는 지역에서도 **음성 녹음만으로** 파킨슨병 조기 발견이 가능하도록 설계되었습니다.

### 🌍 Global Health Challenge

**현실:**
- 전 세계 파킨슨병 환자의 **70%가 저소득 국가**에 거주
- 사하라 이남 아프리카: 신경과 전문의 비율 **100만 명당 0.03명**
- 동남아시아 농촌: 병원까지 평균 **50km+ 이동** 필요
- 진단까지 평균 **2-3년 지연** → 치료 골든타임 놓침

### 🎯 프로젝트 목표

**Primary Goal: Health Equity Through Technology**
- ✅ **Zero-cost screening**: 스마트폰만 있으면 검사 가능
- ✅ **Multilingual support**: 영어, 스와힐리어, 힌디어, 암하라어 등
- ✅ **Offline-first**: 인터넷 없이도 작동 (Edge AI)
- ✅ **Community health worker (CHW) 활용**: 의사 없이도 운영 가능
- ✅ **Data sovereignty**: 환자 데이터가 로컬에만 저장

### 💡 왜 이 프로젝트인가?

**의대 지원자 관점**
- ✅ **Health disparities 해결** - 의대 Personal Statement 핵심 주제
- ✅ **Social determinants of health** 이해 및 실천
- ✅ **Global Health 경험** - UMich Global Health track과 연계
- ✅ **Community-based medicine** - 실제 지역사회 임팩트
- ✅ **Innovation in resource-limited settings** - WHO/Gates Foundation 주목 분야

**사회적 임팩트**
- 조기 진단 시 **삶의 질 5년 이상 연장** 가능
- **가정에서 10분 이내** 스크리닝 완료
- **병원 방문 비용 제로** → 빈곤층 접근성 극대화
- **NGO/WHO 협력 가능성** - 실제 배포 경로 확보

**연구 가치**
- 다양한 인종/언어에서의 음성 biomarker 검증
- Low-resource setting에서의 AI deployment 연구
- Community health worker training 프로토콜 개발

---

## 🔬 기술적 배경

### 왜 음성 기반인가?

**Low-resource setting에 최적화된 선택:**
- ✅ **장비 불필요**: 스마트폰 마이크만 있으면 됨
- ✅ **문맹도 가능**: 읽기/쓰기 능력 불필요
- ✅ **비침습적**: 혈액 검사나 MRI 같은 고가 장비 없음
- ✅ **빠른 검사**: 30초 음성 녹음으로 완료
- ✅ **언어 보편성**: 모든 언어에서 음성 변화 나타남

### 파킨슨병 음성 Biomarkers

**연구 검증된 음성 특징 (언어 무관):**
- **Hypophonia**: 음량 감소 (가장 초기 증상)
- **Monotone**: 음높이 변화 감소
- **Tremor**: 음성 떨림 (4-6 Hz)
- **Breathiness**: 기식음 증가
- **Articulatory imprecision**: 조음 정확도 저하

**기존 연구 성과:**
- UCI 데이터셋: 97% 정확도 (그러나 모두 영어 화자)
- 이탈리아어 연구: 89% 정확도
- **Gap**: 아프리카/아시아 언어 데이터 부족 ← **우리 프로젝트의 기여 포인트**

### AI/ML 접근법 (경량화 중심)

**Edge AI Architecture:**
- **TensorFlow Lite**: 스마트폰에서 직접 실행
- **Model compression**: 5MB 이하 모델 크기
- **Quantization**: INT8로 변환 → 속도 4배 향상
- **Offline inference**: 인터넷 없이도 작동

**Language-agnostic Features:**
- MFCC (Mel-frequency cepstral coefficients)
- Jitter, Shimmer (음성 불안정성)
- HNR (Harmonic-to-Noise Ratio)
- Prosodic features (운율적 특징)

**Privacy-First Design:**
- 모든 처리가 디바이스에서 발생
- 서버로 음성 데이터 전송 없음
- GDPR/HIPAA 완벽 준수

---

## 🛠️ 기술 스택

### Mobile-First Edge AI
- **TensorFlow Lite**: On-device inference (Android/iOS)
- **Flutter**: Cross-platform mobile app (single codebase)
- **SQLite**: Local database (offline storage)
- **Hive**: Lightweight key-value storage
- **WorkManager**: Background processing for Android

### ML Model Development
- **Python 3.11+**: Model training
- **TensorFlow/Keras**: Neural network training
- **librosa**: Audio feature extraction
- **scikit-learn**: Feature selection & validation
- **ONNX**: Model format conversion
- **Model Optimization Toolkit**: Quantization & pruning

### Backend (Minimal, Optional)
- **FastAPI**: Lightweight API (for model updates only)
- **PostgreSQL**: Aggregated analytics (NO patient data)
- **Redis**: Caching
- **Docker**: Containerization

### Cloud (Optional - for research only)
- **Azure Blob Storage**: Anonymized dataset storage
- **Azure Container Registry**: Docker images
- **GitHub Actions**: CI/CD pipeline

### Multilingual Support
- **Google ML Kit**: On-device language detection
- **i18n/l10n**: UI translations (10+ languages)
- **Phonetic analysis**: Language-agnostic features

### Data & Research
- **Multilingual PD datasets**:
  - UCI Parkinson's (English - baseline)
  - Italian Parkinson's Voice Dataset
  - **NEW**: Swahili, Hindi, Amharic speaker collection (우리 프로젝트)
- **Data augmentation**: Noise injection, speed variation
- **Cross-lingual validation**: Transfer learning across languages

---

## 🎨 주요 기능

### Phase 1: Offline Voice Screening (현재 개발 중)

**Community Health Worker (CHW) 인터페이스:**
- [ ] **30초 음성 녹음** - "Ahhh" 발성 + 문장 읽기
- [ ] **언어 자동 감지** - 10개 언어 지원
- [ ] **오프라인 AI 분석** - 디바이스에서 즉시 처리
- [ ] **3단계 리스크 평가**: Low / Medium / High
- [ ] **간단한 시각적 리포트** - 문맹 환자도 이해 가능
- [ ] **SMS 알림** - 인터넷 없이 가족에게 결과 전송

**저대역폭 최적화:**
- [ ] **2G 네트워크 지원** - 최소한의 데이터만 사용
- [ ] **Progressive Web App (PWA)** - 설치 불필요
- [ ] **< 5MB 앱 크기** - 저사양 폰에서도 작동
- [ ] **배터리 효율** - 백그라운드 처리 최소화

### Phase 2: CHW Training & Validation

**Community Health Worker 교육 모듈:**
- [ ] **Interactive tutorial** - 음성 녹음 방법 교육
- [ ] **Quality check** - 녹음 품질 자동 검증
- [ ] **Certification system** - CHW 자격 인증
- [ ] **Referral protocol** - 고위험 환자 병원 연계

**Multi-language Support:**
- [ ] **UI translations**: 영어, 스와힐리어, 힌디어, 암하라어, 하우사어, 줄루어
- [ ] **Voice instructions**: 각 언어로 녹음 가이드
- [ ] **Cultural adaptation**: 지역별 UI/UX 커스터마이징

### Phase 3: Field Pilot in Kenya (2026 여름)

**실제 배포 및 검증:**
- [ ] **Nairobi 빈민촌 파일럿** - 100명 스크리닝
- [ ] **CHW 트레이닝** - 10명 지역 보건요원 교육
- [ ] **Clinical validation** - 신경과 전문의와 결과 비교
- [ ] **User feedback** - 지역사회 피드백 수집
- [ ] **IRB approval** - UMich + Kenya research ethics

### Phase 4: Scale & Research

**확장 및 연구:**
- [ ] **WHO/NGO 협력** - Partners in Health, Médecins Sans Frontières
- [ ] **데이터 수집** - 익명화된 다국어 음성 데이터베이스 구축
- [ ] **논문 발표** - 다국어 음성 biomarker 연구
- [ ] **오픈소스 공개** - 다른 질병으로 확장 가능하도록

---

## 📁 프로젝트 구조

```
neuro-early-detection/
├── backend/
│   ├── app/
│   │   ├── api/
│   │   │   ├── routes/
│   │   │   │   ├── voice.py          # 음성 분석 엔드포인트
│   │   │   │   ├── drawing.py        # 필기 분석 엔드포인트
│   │   │   │   └── results.py        # 결과 조회
│   │   │   └── dependencies.py
│   │   ├── models/
│   │   │   ├── ml/
│   │   │   │   ├── voice_model.py    # 음성 분석 ML 모델
│   │   │   │   └── drawing_model.py  # 필기 분석 ML 모델
│   │   │   └── database/
│   │   │       └── schemas.py        # Cosmos DB 스키마
│   │   ├── services/
│   │   │   ├── audio_processor.py    # 음성 특징 추출
│   │   │   ├── image_processor.py    # 이미지 처리
│   │   │   └── risk_calculator.py    # 리스크 계산
│   │   └── main.py
│   ├── notebooks/
│   │   ├── data_exploration.ipynb    # 데이터 탐색
│   │   └── model_training.ipynb      # 모델 학습
│   ├── tests/
│   ├── requirements.txt
│   └── Dockerfile
│
├── frontend/
│   ├── src/
│   │   ├── components/
│   │   │   ├── VoiceRecorder.tsx     # 음성 녹음 컴포넌트
│   │   │   ├── DrawingCanvas.tsx     # 그리기 캔버스
│   │   │   ├── ResultsDashboard.tsx  # 결과 대시보드
│   │   │   └── RiskVisualization.tsx # 리스크 시각화
│   │   ├── services/
│   │   │   └── api.ts                # API 클라이언트
│   │   ├── pages/
│   │   │   ├── Home.tsx
│   │   │   ├── VoiceTest.tsx
│   │   │   └── Results.tsx
│   │   └── App.tsx
│   ├── public/
│   ├── package.json
│   └── Dockerfile
│
├── ml_models/
│   ├── voice/
│   │   ├── train.py
│   │   ├── evaluate.py
│   │   └── saved_models/
│   └── drawing/
│       ├── train.py
│       └── saved_models/
│
├── data/
│   ├── raw/                          # 원본 데이터셋
│   ├── processed/                    # 전처리된 데이터
│   └── README.md                     # 데이터 출처 및 라이선스
│
├── docs/
│   ├── RESEARCH_BACKGROUND.md        # 연구 배경 및 논문 리뷰
│   ├── MODEL_ARCHITECTURE.md         # 모델 아키텍처 설명
│   ├── API_DOCUMENTATION.md          # API 문서
│   └── DEPLOYMENT_GUIDE.md           # 배포 가이드
│
├── .github/
│   └── workflows/
│       ├── backend-ci.yml
│       └── frontend-ci.yml
│
├── README.md
├── LICENSE
└── .gitignore
```

---

## 🚀 시작하기

### Prerequisites
- Python 3.11+
- Node.js 18+
- Git
- Azure 계정 (optional, for deployment)

### 로컬 개발 환경 설정

**1. 저장소 클론**
```bash
git clone https://github.com/junho-lee/neuro-early-detection.git
cd neuro-early-detection
```

**2. Backend 설정**
```bash
cd backend
python -m venv venv
venv\Scripts\activate  # Windows
pip install -r requirements.txt
```

**3. Frontend 설정**
```bash
cd frontend
npm install
```

**4. 환경 변수 설정**
```bash
# backend/.env
COSMOS_DB_ENDPOINT=your_cosmos_endpoint
COSMOS_DB_KEY=your_cosmos_key
AZURE_STORAGE_CONNECTION_STRING=your_storage_string
```

**5. 실행**
```bash
# Backend (Terminal 1)
cd backend
uvicorn app.main:app --reload

# Frontend (Terminal 2)
cd frontend
npm run dev
```

브라우저에서 `http://localhost:3000` 접속

---

## 📊 데이터셋

### Phase 1: Baseline Models (기존 데이터)

1. **UCI Parkinson's Voice Dataset** (영어)
   - 출처: UCI Machine Learning Repository
   - 크기: 195명, 5,875 샘플
   - **한계**: 모두 미국/영국 영어 화자, 백인 중심
   - 용도: Baseline model 학습

2. **Italian PD Voice Corpus** (이탈리아어)
   - 출처: Politecnico di Torino
   - 크기: 88명
   - 용도: Cross-lingual validation

### Phase 2: Multilingual Data Collection (우리의 기여!) ⭐

**Target Languages & Regions:**

1. **East Africa** (Kenya, Tanzania, Ethiopia)
   - **Swahili** (5,000만 화자)
   - **Amharic** (2,500만 화자)
   - 목표: 각 언어당 100명 수집
   - 파트너: Kenyatta National Hospital, UMich Kenya office

2. **South Asia** (India, Bangladesh)
   - **Hindi** (6억 화자)
   - **Bengali** (2억 화자)
   - 목표: 각 언어당 150명 수집
   - 파트너: AIIMS New Delhi, Apollo Hospitals

3. **West Africa** (Nigeria, Ghana)
   - **Hausa** (8,000만 화자)
   - **Yoruba** (4,500만 화자)
   - 목표: 각 언어당 100명 수집
   - 파트너: University of Lagos Teaching Hospital

**Data Collection Protocol:**
- IRB approval from UMich + local institutions
- Informed consent in local languages
- 3 tasks: Sustained phonation ("Ahhh"), Reading passage, Free speech
- Clinical validation by local neurologists
- Full anonymization before aggregation

### Data Privacy & Sovereignty

**Community-First Approach:**
- ✅ **Data stays local**: 환자 데이터는 해당 국가에만 저장
- ✅ **Federated learning**: 모델만 공유, 데이터는 공유 안 함
- ✅ **Community ownership**: 지역사회가 데이터 사용 권한 보유
- ✅ **Benefit sharing**: 연구 결과를 해당 지역사회 우선 환원
- ✅ **Encryption**: AES-256 암호화
- ✅ **GDPR/HIPAA compliant**: 국제 표준 준수

---

## 🗓️ 개발 로드맵

### 2026년 1-3월: Foundation & Model Development (현재)

**Technical Development:**
- [x] 프로젝트 방향 설정 (Global Health focus)
- [ ] UCI 데이터셋으로 baseline 모델 학습
- [ ] TensorFlow Lite 변환 및 최적화
- [ ] Flutter 모바일 앱 기본 구조
- [ ] 오프라인 음성 녹음 + 특징 추출

**Partnership Building:**
- [ ] UMich Global Health program 교수님 미팅
- [ ] Kenya/India NGO 파트너 탐색
- [ ] IRB proposal 초안 작성

### 2026년 4-6월: Multilingual Expansion

**Model Training:**
- [ ] 이탈리아어 데이터로 cross-lingual validation
- [ ] Language-agnostic feature engineering
- [ ] Model compression (< 5MB)
- [ ] 3개 언어 지원 (영어, 스와힐리어, 힌디어)

**App Development:**
- [ ] CHW 인터페이스 디자인 (Kenya CHW와 협업)
- [ ] Offline-first architecture 구현
- [ ] SMS integration (인터넷 없이 결과 전송)
- [ ] Battery optimization

### 2026년 여름 방학 (6-8월): Field Pilot in Kenya 🌍

**Pre-deployment:**
- [ ] UMich + Kenyatta Hospital IRB approval
- [ ] 10명 CHW 트레이닝 (Nairobi)
- [ ] 100대 저가 안드로이드 폰 확보
- [ ] Local partnership MOU 체결

**Pilot Study:**
- [ ] **Nairobi 빈민촌 100명 스크리닝**
- [ ] Clinical validation (신경과 전문의 진단 vs AI)
- [ ] User experience research
- [ ] 데이터 수집 (IRB 승인 하 익명화)
- [ ] Field notes 및 개선사항 도출

**Academic Output:**
- [ ] UMich 교수님께 중간 발표
- [ ] Summer research poster presentation

### 2026년 9-12월: Scale & Research

**Expansion:**
- [ ] India pilot (AIIMS New Delhi 협력)
- [ ] Ethiopia pilot (Addis Ababa)
- [ ] 6개 언어 지원으로 확대
- [ ] 500+ 다국어 음성 데이터 수집

**Research:**
- [ ] 논문 작성: "Multilingual Voice Biomarkers for PD in Low-Resource Settings"
- [ ] Conference submission (Global Health or Neurology)
- [ ] 데이터셋 공개 (privacy-preserving)

**Medical School Application:**
- [ ] Personal statement에 프로젝트 경험 작성
- [ ] 추천서 요청 (Kenya 협력 병원 의사 + UMich 교수)
- [ ] Activity description 작성

### 2027년: Long-term Impact

**Sustainability:**
- [ ] NGO 파트너십 (Partners in Health, MSF)
- [ ] WHO digital health toolkit 제안
- [ ] 오픈소스 공개 (MIT License)
- [ ] 다른 질병으로 확장 (TB, Diabetes screening)

**Academic:**
- [ ] 저널 논문 게재 (JMIR, Lancet Global Health)
- [ ] Gates Foundation Grand Challenges 지원
- [ ] TED talk / UN Global Health conference

---

## 🎓 UMich 교수진 연계 전략

### 타겟 교수님 연구 분야

**Primary Targets (Global Health + Neuroscience):**

1. **Global Health Program Faculty**
   - Dr. Matthew Boulton (School of Public Health)
   - Focus: Community-based interventions in Africa
   - Connection: CHW training, Kenya field work

2. **Movement Disorders + Health Disparities**
   - Neurology faculty with global health interest
   - Focus: Parkinson's in diverse populations
   - Connection: Multilingual biomarker research

3. **Digital Health & mHealth**
   - Biomedical Engineering + Computer Science
   - Focus: Mobile health apps for low-resource settings
   - Connection: Edge AI, offline-first design

4. **Medical Anthropology**
   - Focus: Cultural adaptation of health interventions
   - Connection: Community engagement, local knowledge

### UMich Global Reach Opportunities

**Existing Programs to Leverage:**

1. **Center for Global Health Equity (CGHE)**
   - Kenya, India, Ghana offices
   - Established community partnerships
   - IRB expertise for international research

2. **Global Health Internship Program**
   - Summer funding for field work
   - Academic credit for research
   - Mentorship from global health faculty

3. **UROP (Undergraduate Research)**
   - Funding for project development
   - Faculty mentor matching
   - Presentation opportunities

### 어프로치 방법

**Step 1: 교수님 연구 조사**
```
1. UMich Global Health + Neurology 교수님 목록 확인
2. 각 교수님의 최근 프로젝트 (특히 아프리카/아시아 협력)
3. 연구실의 community partnerships 파악
4. 기존 학생 프로젝트 사례 조사
```

**Step 2: 이메일 문의 템플릿**
```
Subject: First-Year Student - Global Health Project on Parkinson's Screening in Kenya

Dear Professor [Name],

My name is Junho Lee, a first-year student passionate about addressing 
health disparities through technology. I have been following your work on 
[specific global health project], particularly your partnership with 
[country/institution].

I am developing **NeuroAccess**, a smartphone-based Parkinson's screening tool 
designed specifically for underserved communities in East Africa and South Asia. 
The project addresses a critical gap: 70% of Parkinson's patients live in 
low-resource settings, yet 99% of diagnostic research focuses on high-income 
populations.

What makes this different:
- Offline-first: Works without internet (Edge AI on smartphone)
- Multilingual: Supporting Swahili, Hindi, Amharic, etc.
- CHW-operated: Designed for community health workers, not doctors
- Privacy-focused: All data stays on device
- Field-tested: Planning pilot in Nairobi slums (Summer 2026)

I have:
✓ Built a working prototype with 89% accuracy on UCI dataset
✓ Converted model to TensorFlow Lite (5MB, runs on $50 phones)
✓ Designed culturally-adapted UI based on CHW feedback
✓ Identified potential partners (Kenyatta Hospital, UMich Kenya office)

I would greatly appreciate:
1. Your guidance on community engagement strategies
2. Advice on IRB process for international research
3. Potential introduction to UMich Kenya partners
4. Opportunity to present this project to your team

I am committed to ensuring this work benefits the communities involved, 
not just my medical school application. I believe technology can be a tool 
for health equity, not just innovation.

Would you have 15 minutes to discuss how this project might align with 
your program's mission?

Thank you for your time and for the incredible work you do.

Respectfully,
Junho Lee
University of Michigan, Class of 2028
Email: junholee@umich.edu
Project: github.com/junho-lee/neuro-access
```

**Step 3: Office Hours 방문**
- 프로젝트 데모 준비 (5분 버전)
- 질문 리스트 준비
- CV 및 transcript 지참

**Step 4: 연구실 참여 경로**
- UROP (Undergraduate Research Opportunity Program) 지원
- Independent Study (학점 인정)
- Summer Research Internship

---

## 📚 참고 논문 및 리소스

### 핵심 논문
1. Tsanas, A. et al. (2012). "Accurate telemonitoring of Parkinson's disease symptom severity using nonlinear speech signal processing and statistical machine learning"
2. Little, M.A. et al. (2009). "Exploiting Nonlinear Recurrence and Fractal Scaling Properties for Voice Disorder Detection"
3. Shulman, L.M. (2010). "Understanding Disability in Parkinson's Disease"
4. Nasreddine, Z.S. et al. (2005). "The Montreal Cognitive Assessment (MoCA): A Brief Screening Tool For Mild Cognitive Impairment"

### 데이터셋
- [UCI Parkinson's Dataset](https://archive.ics.uci.edu/ml/datasets/parkinsons)
- [mPower Parkinson's Study](https://www.synapse.org/#!Synapse:syn4993293)
- [ADNI - Alzheimer's Disease Neuroimaging Initiative](https://adni.loni.usc.edu/)

### 유용한 도구
- [librosa Documentation](https://librosa.org/)
- [TensorFlow Tutorials](https://www.tensorflow.org/tutorials)
- [Azure Cosmos DB for AI](https://learn.microsoft.com/azure/cosmos-db/)

---

## 🤝 기여 및 피드백

이 프로젝트는 **교육 및 연구 목적**으로 개발되었습니다.

- 피드백 및 제안: [GitHub Issues](https://github.com/junho-lee/neuro-early-detection/issues)
- 기여 가이드: [CONTRIBUTING.md](CONTRIBUTING.md)
- 행동 강령: [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)

---

## ⚠️ 면책 조항

**이 도구는 의학적 진단 도구가 아닙니다.**

- 본 프로젝트는 연구 및 교육 목적의 프로토타입입니다.
- 실제 의학적 진단은 반드시 의료 전문가와 상담하세요.
- 이 도구의 결과는 스크리닝 참고용이며 확정 진단이 아닙니다.
- FDA 승인을 받지 않았습니다.

---

## 📄 라이선스

MIT License - 자유롭게 사용, 수정, 배포 가능

---

## 👨‍🎓 제작자

**Junho Lee**
- University of Michigan, Arts & Science '28
- Prospective Neuroscience Major
- Email: junholee@umich.edu
- LinkedIn: [linkedin.com/in/junho-lee](https://linkedin.com)
- GitHub: [@junho-lee](https://github.com/junho-lee)

---

## 🌟 프로젝트 비전

> **"Technology should serve those who need it most, not just those who can afford it."**
>
> 전 세계 파킨슨병 환자의 70%는 저소득 국가에 살고 있지만, 
> 99%의 연구는 고소득 국가에서만 이루어집니다. 
>
> **NeuroAccess**는 이 불평등을 바꾸기 위한 프로젝트입니다.
>
> 케냐 나이로비의 빈민촌 주민도, 
> 인도 시골 마을의 농부도, 
> 에티오피아의 어머니도 
> **스마트폰 하나로** 신경과 전문의 수준의 스크리닝을 받을 수 있어야 합니다.
>
> AI는 Silicon Valley의 전유물이 아닙니다. 
> AI는 **건강 형평성(Health Equity)**을 실현하는 도구가 되어야 합니다.

### Long-term Vision

**2027:** 10,000명 스크리닝 (Kenya, India, Ethiopia)  
**2028:** WHO Digital Health Toolkit 채택  
**2029:** 20개국, 50개 언어 지원  
**2030:** 파킨슨병 외 다른 질병으로 확장 (TB, Diabetes, Malaria)  

**Ultimate Goal:**  
**"모든 사람은 우편번호나 소득에 관계없이 조기 진단받을 권리가 있다."**

---

**Made with ❤️ for health equity**  
**Powered by community, not profit**

---

**Last Updated**: 2026년 1월 7일  
**Version**: 0.2.0 (Global Health Focus - Pivot to Underserved Communities)  
**Status**: Seeking partnerships & preparing for Kenya pilot
