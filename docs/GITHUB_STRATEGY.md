# GitHub Development Strategy
# NeuroAccess Git Workflow & CI Strategy

**Project**: NeuroAccess - AI-Powered Parkinson's Screening for Underserved Communities  
**Version**: 1.0  
**Date**: 2026년 1월 7일  
**Methodology**: Agile + Continuous Integration  
**Team**: Solo developer (scalable to team)

---

## Document Control

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-01-07 | Junho Lee | Initial GitHub strategy document |

---

## Table of Contents

1. [Git Branching Strategy](#git-branching-strategy)
2. [Commit Conventions](#commit-conventions)
3. [Story-Based Development Workflow](#story-based-development-workflow)
4. [Pull Request Process](#pull-request-process)
5. [Code Review Guidelines](#code-review-guidelines)
6. [CI/CD Pipeline](#cicd-pipeline)
7. [Sprint Integration Pattern](#sprint-integration-pattern)
8. [GitHub Projects Integration](#github-projects-integration)

---

## Git Branching Strategy

### Branch Hierarchy

```
main (production-ready)
  ├── sprint-1 (Sprint 1 integration branch)
  │   ├── story/STORY-001-project-setup
  │   ├── story/STORY-002-figma-design
  │   ├── story/STORY-003-app-shell
  │   ├── story/STORY-004-voice-recording-service
  │   ├── story/STORY-005-voice-ui
  │   └── story/STORY-006-audio-quality
  │
  ├── sprint-2 (Sprint 2 integration branch)
  │   ├── story/STORY-007-ml-training
  │   ├── story/STORY-008-tflite-conversion
  │   ├── story/STORY-009-feature-extraction
  │   ├── story/STORY-010-ml-inference
  │   ├── story/STORY-011-risk-stratification
  │   └── story/STORY-012-pipeline-integration
  │
  └── sprint-3 (Sprint 3 integration branch)
      ├── story/STORY-013-figma-results
      ├── story/STORY-014-results-ui
      ├── story/STORY-015-database-setup
      ├── story/STORY-016-data-persistence
      ├── story/STORY-017-dashboard
      ├── story/STORY-018-figma-workflow
      └── story/STORY-019-patient-input
```

### Branch Types

#### 1. `main` Branch
- **Purpose**: Production-ready code
- **Protection**: Protected branch, requires PR approval
- **Merge Strategy**: Squash merge from sprint branches
- **Deploy**: Automatically builds release APK (future)
- **Rules**:
  - ✅ Always deployable
  - ✅ All tests passing
  - ✅ Sprint demo completed
  - ❌ No direct commits

#### 2. `sprint-N` Branches (Integration Branches)
- **Naming**: `sprint-1`, `sprint-2`, `sprint-3`, etc.
- **Purpose**: Integrate all stories for a sprint
- **Lifespan**: 2 weeks (sprint duration)
- **Created**: Monday of sprint start (Sprint Planning)
- **Merged**: Friday of sprint end (after Sprint Review)
- **Workflow**:
  ```bash
  # Create sprint branch from main
  git checkout main
  git pull origin main
  git checkout -b sprint-1
  git push -u origin sprint-1
  ```

#### 3. `story/STORY-XXX-description` Branches (Feature Branches)
- **Naming**: `story/STORY-001-project-setup`
- **Purpose**: Implement individual user story
- **Branched From**: Current sprint branch (e.g., `sprint-1`)
- **Merged To**: Sprint branch
- **Lifespan**: 1-3 days (story completion)
- **Workflow**:
  ```bash
  # Create story branch from sprint branch
  git checkout sprint-1
  git pull origin sprint-1
  git checkout -b story/STORY-001-project-setup
  ```

#### 4. `hotfix/` Branches (Emergency Fixes)
- **Naming**: `hotfix/fix-crash-on-recording`
- **Branched From**: `main`
- **Merged To**: `main` AND current `sprint-N` branch
- **Use Case**: Critical bugs in production (rare for MVP)

---

## Commit Conventions

### Commit Message Format (Conventional Commits)

```
<type>(<story-id>): <subject>

<body>

<footer>
```

### Commit Types

| Type | Usage | Example |
|------|-------|---------|
| `feat` | New feature implementation | `feat(STORY-004): implement voice recording service` |
| `fix` | Bug fix | `fix(STORY-005): resolve button alignment issue` |
| `docs` | Documentation only | `docs(README): add setup instructions` |
| `style` | Code formatting (no logic change) | `style(STORY-005): fix linting errors` |
| `refactor` | Code refactoring | `refactor(STORY-010): simplify inference logic` |
| `test` | Add or update tests | `test(STORY-004): add unit tests for recording` |
| `chore` | Maintenance tasks | `chore(deps): update flutter dependencies` |
| `ui` | UI/UX changes | `ui(STORY-005): implement recording button animation` |
| `perf` | Performance improvements | `perf(STORY-010): optimize feature extraction` |

### Commit Message Examples

#### ✅ Good Commits

```bash
feat(STORY-004): implement AudioRecordingService with 16kHz sampling

- Add flutter_sound package dependency
- Create AudioRecordingService class with start/stop methods
- Handle microphone permissions
- Save recordings to local storage as WAV files

Closes #4
```

```bash
ui(STORY-005): implement voice recording screen UI

- Add recording button with color states (green/red/gray)
- Implement countdown timer display
- Add waveform visualization placeholder
- Responsive layout for 4.5"-6.7" screens

Related to STORY-005 AC #3
```

```bash
fix(STORY-006): improve audio quality validation accuracy

- Adjust silence detection threshold from 10% to 5%
- Add clipping detection for distorted audio
- Provide specific error messages for each failure type

Fixes #6
```

#### ❌ Bad Commits

```bash
# Too vague
fix: bug fix

# No story reference
added some UI stuff

# All caps (avoid)
FEAT: NEW FEATURE

# Inconsistent format
Story 4 - recording service implementation
```

### Commit Frequency

**Guideline**: Commit **early and often** within a story.

**Recommended Pattern**:
- **Minimum**: 1 commit per story (at completion)
- **Ideal**: 3-5 commits per story (incremental progress)
- **Maximum**: No limit (atomic commits preferred)

**Example for STORY-004** (Voice Recording Service):
1. `feat(STORY-004): add flutter_sound dependency and permissions`
2. `feat(STORY-004): implement AudioRecordingService class`
3. `test(STORY-004): add unit tests for recording service`
4. `fix(STORY-004): handle permission denial gracefully`
5. `docs(STORY-004): add service documentation`

---

## Story-Based Development Workflow

### Workflow Overview

```
┌─────────────────────────────────────────────────────────┐
│                    Sprint Workflow                       │
└─────────────────────────────────────────────────────────┘

Day 1 (Mon):  Sprint Planning → Create sprint-N branch
Day 2-13:     Story Development (one story at a time)
              ├── Create story branch
              ├── Implement story (multiple commits)
              ├── Self-review
              ├── Merge story → sprint branch
              └── Move to next story
Day 14 (Fri): Sprint Review → Create PR (sprint-N → main)
Day 15:       PR review → Merge → Sprint complete
```

### Step-by-Step: Story Development Cycle

#### Step 1: Start New Story

```bash
# 1. Ensure sprint branch is up-to-date
git checkout sprint-1
git pull origin sprint-1

# 2. Create story branch
git checkout -b story/STORY-004-voice-recording-service

# 3. Update GitHub Projects: Move story to "In Progress"
# (Done via GitHub UI or CLI)
```

#### Step 2: Develop Story (Incremental Commits)

```bash
# Make changes (code, tests, docs)
# Commit frequently with descriptive messages

git add lib/services/audio_recording_service.dart
git commit -m "feat(STORY-004): implement AudioRecordingService class

- Add start/stop recording methods
- Configure 16kHz, 16-bit PCM format
- Handle microphone permissions

Related to STORY-004 AC #1, #2"

# Continue development...
git add test/services/audio_recording_service_test.dart
git commit -m "test(STORY-004): add unit tests for recording service"

# Push to remote (backup + collaboration)
git push -u origin story/STORY-004-voice-recording-service
```

#### Step 3: Complete Story & Self-Review

```bash
# Run all checks locally
flutter analyze                    # Linting
flutter test                       # Unit tests
flutter build apk --debug          # Build check

# Self-review checklist:
# ✅ All Acceptance Criteria met
# ✅ Code linting passes (no warnings)
# ✅ Unit tests written and passing
# ✅ No debug code (print statements, commented code)
# ✅ Documentation updated (if needed)
```

#### Step 4: Merge Story to Sprint Branch

**Option A: Direct Merge (Solo Developer)**
```bash
# Switch to sprint branch
git checkout sprint-1

# Merge story branch (no fast-forward for history)
git merge --no-ff story/STORY-004-voice-recording-service

# Push to remote
git push origin sprint-1

# Delete story branch (local and remote)
git branch -d story/STORY-004-voice-recording-service
git push origin --delete story/STORY-004-voice-recording-service
```

**Option B: Pull Request (Team/Discipline)**
```bash
# Create PR via GitHub UI: story/STORY-004 → sprint-1
# Self-review PR
# Merge PR (squash or merge commit)
# Delete story branch
```

#### Step 5: Update Tracking

```bash
# Update GitHub Projects:
# - Move STORY-004 from "In Progress" to "Done"
# - Add comment with commit hash
# - Update story points burned

# Update Sprint Board (if using separate tool)
```

### Continuous Integration Within Sprint

**Pattern**: Each story merge to `sprint-N` branch triggers integration check.

```
STORY-001 → sprint-1 ✅ (App builds)
STORY-002 → sprint-1 ✅ (App builds)
STORY-003 → sprint-1 ✅ (App builds)
  ...
STORY-006 → sprint-1 ✅ (Sprint 1 complete)
```

**Benefits**:
- Early detection of integration issues
- Always have a working sprint branch
- Easy rollback if a story breaks the build

---

## Pull Request Process

### Sprint-End Pull Request

**When**: End of Sprint (Friday afternoon)  
**What**: Merge entire sprint branch to `main`  
**Who**: Solo developer (self-review) OR team lead

### PR Creation

```bash
# Ensure sprint branch is fully integrated
git checkout sprint-1
git pull origin sprint-1

# Push final changes
git push origin sprint-1

# Create PR via GitHub UI or CLI
gh pr create \
  --base main \
  --head sprint-1 \
  --title "Sprint 1: Foundation & Voice Recording UI" \
  --body "$(cat PR_TEMPLATE.md)"
```

### PR Template

```markdown
## Sprint Summary

**Sprint**: Sprint 1 (Jan 13-26, 2026)  
**Sprint Goal**: Establish project foundation and deliver functional voice recording interface  
**Total Story Points**: 23 points  

## Stories Completed

- [x] STORY-001: Project Repository Setup (3 pts)
- [x] STORY-002: Figma UI Design - Voice Recording Screen (5 pts)
- [x] STORY-003: Basic App Shell with Navigation (3 pts)
- [x] STORY-004: Voice Recording Service Implementation (5 pts)
- [x] STORY-005: Voice Recording UI Implementation (5 pts)
- [x] STORY-006: Audio Quality Validation (2 pts)

## Deliverables

- ✅ Flutter project fully configured
- ✅ Figma designs for voice recording UI
- ✅ Functional voice recorder with quality validation
- ✅ UI matches Figma design (≥90%)
- ✅ Runnable on Android device

## Demo

**Video**: [Loom recording link]  
**Screenshots**:
- Home screen
- Voice recording screen (idle)
- Voice recording screen (active)
- Quality validation (pass/fail)

## Testing

- ✅ All unit tests passing (12/12)
- ✅ Manual testing on 3 devices:
  - Pixel 6 (Android 13)
  - Samsung Galaxy A52 (Android 12)
  - OnePlus 9 (Android 13)
- ✅ Linting passed (0 warnings)
- ✅ Build successful (APK size: 8.2 MB)

## Performance Metrics

- Recording start latency: <300ms ✅
- Audio quality validation: <2 seconds ✅
- App launch time: 1.2 seconds ✅
- Battery usage per recording: 4% ✅

## Known Issues

- [ ] Minor: Waveform animation stutters on low-end devices (non-blocking)

## Acceptance Criteria (Sprint-Level DoD)

- [x] All committed stories meet Story-Level DoD
- [x] Sprint goal achieved
- [x] Demo ready and recorded
- [x] Code merged to sprint-1 branch
- [x] App builds and runs on target devices
- [x] Sprint retrospective complete
- [x] Next sprint stories prioritized

## Reviewer Notes

- Self-reviewed all code
- All Figma designs linked in STORY-002 commit
- Database schema prepared (for Sprint 3)

## Merge Strategy

- **Method**: Squash and merge
- **Commit Message**: "Sprint 1: Foundation & Voice Recording UI (#1)"

---

**Ready for merge to `main`** 🚀
```

### PR Review Checklist (Self or Peer)

- [ ] **All stories completed**: Every story in sprint marked "Done"
- [ ] **Code quality**: Linting passes, no code smells
- [ ] **Tests**: All tests passing, coverage ≥80% for new code
- [ ] **Documentation**: README updated, inline comments for complex logic
- [ ] **Figma designs**: All UI matches designs (≥90%)
- [ ] **Performance**: No regressions (app still fast)
- [ ] **Build**: APK builds successfully, no errors
- [ ] **Demo**: Video or screenshots demonstrate sprint goal achieved
- [ ] **No sensitive data**: No API keys, passwords, or PII in commits
- [ ] **Dependencies**: Only necessary dependencies added
- [ ] **Conflicts**: No merge conflicts with `main`

### PR Approval & Merge

```bash
# After approval (self or peer)
# Merge via GitHub UI: "Squash and merge"
# OR via CLI:

gh pr merge sprint-1 \
  --squash \
  --delete-branch \
  --subject "Sprint 1: Foundation & Voice Recording UI" \
  --body "Completed all 6 stories (23 story points)"

# Tag release (optional, for milestones)
git checkout main
git pull origin main
git tag -a v0.1.0-sprint1 -m "Sprint 1 MVP: Voice Recording"
git push origin v0.1.0-sprint1
```

---

## Code Review Guidelines

### Self-Review Process (Solo Developer)

Since this is a solo project, self-review is critical to maintain quality.

#### Pre-Commit Review
1. **Read your own diff**: `git diff` before staging
2. **Remove debug code**: No `print()` statements, commented code
3. **Check formatting**: Run linter (`flutter analyze`)
4. **Test locally**: Run tests (`flutter test`)

#### Pre-Merge Review (Story → Sprint)
1. **Review entire story branch**: `git diff sprint-1...story/STORY-XXX`
2. **Run full test suite**: Ensure no regressions
3. **Build app**: Confirm it compiles
4. **Manual test**: Verify story acceptance criteria

#### Pre-PR Review (Sprint → Main)
1. **Review all commits**: `git log main..sprint-1 --oneline`
2. **Full integration test**: Test entire sprint's features together
3. **Performance check**: Profile if performance-critical changes
4. **Demo recording**: Record demo to verify completeness

### Code Review Checklist

#### Functionality
- [ ] Code does what the story requires
- [ ] All acceptance criteria met
- [ ] Edge cases handled
- [ ] Error handling implemented

#### Code Quality
- [ ] Follows Dart style guide
- [ ] No code duplication (DRY principle)
- [ ] Functions are small and focused (SRP)
- [ ] Meaningful variable/function names
- [ ] No "magic numbers" (use named constants)

#### Testing
- [ ] Unit tests for business logic
- [ ] Widget tests for UI components (if complex)
- [ ] Manual testing documented
- [ ] Test coverage ≥80% for new code

#### Security & Privacy
- [ ] No hardcoded secrets (API keys, passwords)
- [ ] User data encrypted (if applicable)
- [ ] Permissions properly requested
- [ ] No sensitive data in logs

#### Performance
- [ ] No N+1 queries (database)
- [ ] Images optimized
- [ ] Large lists use lazy loading
- [ ] No memory leaks (dispose controllers)

#### Documentation
- [ ] Complex logic commented
- [ ] Public APIs documented (dartdoc)
- [ ] README updated (if needed)
- [ ] CHANGELOG updated (for releases)

---

## CI/CD Pipeline

### GitHub Actions Workflow

**File**: `.github/workflows/ci.yml`

```yaml
name: NeuroAccess CI

on:
  push:
    branches: [ main, sprint-* ]
  pull_request:
    branches: [ main ]

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
        channel: 'stable'
    
    - name: Get dependencies
      run: flutter pub get
    
    - name: Verify formatting
      run: flutter format --set-exit-if-changed .
    
    - name: Analyze code
      run: flutter analyze
    
    - name: Run tests
      run: flutter test --coverage
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage/lcov.info
    
    - name: Build APK
      run: flutter build apk --debug
    
    - name: Upload APK artifact
      uses: actions/upload-artifact@v3
      with:
        name: app-debug-${{ github.sha }}.apk
        path: build/app/outputs/flutter-apk/app-debug.apk

  ui-tests:
    runs-on: macos-latest
    needs: build-and-test
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
    
    - name: Run integration tests
      uses: reactivecircus/android-emulator-runner@v2
      with:
        api-level: 29
        script: flutter test integration_test/
```

### CI Triggers

| Event | Trigger | Actions |
|-------|---------|---------|
| **Push to sprint-N** | Every commit | Lint, test, build |
| **Push to main** | Sprint merge | Lint, test, build, deploy (future) |
| **Pull Request** | PR created/updated | Full CI suite + integration tests |
| **Release Tag** | `v*.*.*` tag | Build release APK, create GitHub release |

### CI Status Badges

Add to `README.md`:

```markdown
![CI Status](https://github.com/morningpython/neuro-early-detection/workflows/NeuroAccess%20CI/badge.svg)
![Coverage](https://codecov.io/gh/morningpython/neuro-early-detection/branch/main/graph/badge.svg)
```

---

## Sprint Integration Pattern

### Sprint Lifecycle with Git

#### Phase 1: Sprint Start (Monday, Week 1)

```bash
# Sprint Planning complete → Create sprint branch

git checkout main
git pull origin main
git checkout -b sprint-1
git push -u origin sprint-1

# Create initial structure (if needed)
mkdir -p lib/services lib/ui lib/models
git add .
git commit -m "chore(sprint-1): initialize sprint structure"
git push origin sprint-1
```

#### Phase 2: Story Development (Week 1-2)

**Daily Pattern**:
```bash
# Morning: Check sprint branch status
git checkout sprint-1
git pull origin sprint-1

# Create story branch
git checkout -b story/STORY-001-project-setup

# Work on story (multiple commits)
# ... code, test, commit ...

# End of day: Push work
git push origin story/STORY-001-project-setup

# Story complete: Merge to sprint
git checkout sprint-1
git merge --no-ff story/STORY-001-project-setup
git push origin sprint-1

# Delete story branch
git branch -d story/STORY-001-project-setup
git push origin --delete story/STORY-001-project-setup
```

**Progress Tracking**:
```
Day 2-3:   STORY-001 ✅ → sprint-1
Day 4-5:   STORY-002 ✅ → sprint-1
Day 6-7:   STORY-003 ✅ → sprint-1
Day 8-9:   STORY-004 ✅ → sprint-1
Day 10-11: STORY-005 ✅ → sprint-1
Day 12-13: STORY-006 ✅ → sprint-1
```

#### Phase 3: Sprint Review & Integration (Friday, Week 2)

```bash
# Sprint Review preparation
git checkout sprint-1
git pull origin sprint-1

# Ensure all tests pass
flutter test
flutter analyze
flutter build apk --debug

# Create demo video (Loom recording)
# Record: Home → Recording → Result flow

# Create Pull Request: sprint-1 → main
gh pr create \
  --base main \
  --head sprint-1 \
  --title "Sprint 1: Foundation & Voice Recording UI" \
  --body-file sprint_1_pr_template.md
```

#### Phase 4: Sprint Retrospective & Merge (Weekend/Monday)

```bash
# Self-review PR
# Check demo video
# Verify all acceptance criteria

# Merge PR (squash)
gh pr merge sprint-1 --squash --delete-branch

# Tag sprint completion
git checkout main
git pull origin main
git tag -a v0.1.0-sprint1 -m "Sprint 1: Voice Recording MVP"
git push origin v0.1.0-sprint1

# Sprint retrospective (write notes in docs/retrospectives/)
```

### Continuous Integration Visualization

```
┌─────────────────────────────────────────────────────────┐
│                Continuous Integration                    │
│              (Sprint-Based Development)                  │
└─────────────────────────────────────────────────────────┘

main ──●─────────────────────────────●────────────────●──
       │                             │                │
       │ Sprint 1                    │ Sprint 2       │ Sprint 3
       ├─────────────────────┐       ├────────────┐   ├──────┐
       │                     │       │            │   │      │
sprint-1  STORY-001 ──●──────┤       │            │   │      │
          STORY-002 ──●──────┤       │            │   │      │
          STORY-003 ──●──────┤       │            │   │      │
          STORY-004 ──●──────┤       │            │   │      │
          STORY-005 ──●──────┤       │            │   │      │
          STORY-006 ──●──────┤       │            │   │      │
                      │       │       │            │   │      │
                      PR #1 ──┘       │            │   │      │
                      ✅ Merged       │            │   │      │
                                      │            │   │      │
                              sprint-2 STORY-007 ──●─┤   │      │
                                       STORY-008 ──●─┤   │      │
                                       STORY-009 ──●─┤   │      │
                                       STORY-010 ──●─┤   │      │
                                       STORY-011 ──●─┤   │      │
                                       STORY-012 ──●─┤   │      │
                                                 │   │   │      │
                                                 PR #2 ──┘      │
                                                 ✅ Merged      │
                                                                │
                                                        sprint-3 ...
                                                                │
                                                                PR #3
                                                                ✅ MVP!
```

### Integration Frequency

**Within Sprint**: Daily (story merges)
- Every story completion → Immediate integration to sprint branch
- Ensures sprint branch is always buildable

**Sprint to Main**: Bi-weekly (sprint completion)
- Every sprint completion → PR to main
- Ensures main always has complete features (not half-done work)

---

## GitHub Projects Integration

### Project Board Setup

**Board Name**: "NeuroAccess Development"  
**Type**: Automated Kanban

### Columns

1. **📋 Backlog**
   - All defined stories
   - Prioritized by sprint
   - Tagged: `sprint-1`, `sprint-2`, etc.

2. **🎯 Sprint Backlog**
   - Stories committed for current sprint
   - Moved here during Sprint Planning

3. **🔨 In Progress**
   - Stories currently being worked on
   - Limit: 1-2 stories (solo developer)

4. **👀 Review**
   - Stories completed, awaiting self-review
   - Before merging to sprint branch

5. **✅ Done**
   - Stories merged to sprint branch
   - Sprint not yet complete

6. **🚀 Released**
   - Stories merged to main (sprint PR approved)

### Automation Rules

```yaml
# .github/workflows/project-automation.yml

name: Project Board Automation

on:
  issues:
    types: [opened, closed]
  pull_request:
    types: [opened, closed, merged]

jobs:
  move-cards:
    runs-on: ubuntu-latest
    steps:
      - name: Move to In Progress
        if: github.event.action == 'opened'
        uses: actions/add-to-project@v0.3.0
        with:
          project-url: https://github.com/users/morningpython/projects/1
          column-name: In Progress
      
      - name: Move to Done
        if: github.event.action == 'closed'
        uses: actions/add-to-project@v0.3.0
        with:
          project-url: https://github.com/users/morningpython/projects/1
          column-name: Done
```

### Issue Tracking

**Each Story = GitHub Issue**

**Example Issue**: STORY-004

```markdown
**Story ID**: STORY-004  
**Epic**: EPIC-VOICE  
**Sprint**: Sprint 1  
**Story Points**: 5  

## User Story

**As a** CHW,  
**I want to** record a patient's voice using the smartphone microphone,  
**So that** I can capture audio samples for analysis.

## Description

Implement audio recording service using flutter_sound package. Support 16kHz, 16-bit PCM, mono format. Handle permissions and errors gracefully.

## Acceptance Criteria

- [ ] `AudioRecordingService` class created in `lib/services/`
- [ ] Microphone permission requested at runtime (Android)
- [ ] Recording starts/stops on user action
- [ ] Audio format: 16kHz, 16-bit PCM, mono (.wav file)
- [ ] Recording duration: 30 seconds (hardcoded for MVP)
- [ ] Save recording to local storage (`/files/audio/`)
- [ ] Error handling (permission denied, recording failure, storage full)
- [ ] Unit tests for recording service (start, stop, save)
- [ ] Manual test on physical Android device

## Technical Notes

- Use `flutter_sound` package
- File naming: `recording_[UUID]_[timestamp].wav`
- Temporary storage (will be deleted after analysis in future sprints)

## Branch

`story/STORY-004-voice-recording-service`

## Related

- Depends on: STORY-001 (project setup)
- Blocks: STORY-005 (UI implementation)

## Labels

`sprint-1`, `epic-voice`, `story`, `5-points`, `feature`
```

### Labels Structure

**Sprint Labels**:
- `sprint-1`, `sprint-2`, `sprint-3`, etc.

**Epic Labels**:
- `epic-found`, `epic-voice`, `epic-ml`, `epic-result`, etc.

**Type Labels**:
- `story`, `bug`, `task`, `documentation`

**Priority Labels**:
- `priority-critical`, `priority-high`, `priority-medium`, `priority-low`

**Size Labels**:
- `1-point`, `2-points`, `3-points`, `5-points`, `8-points`

---

## Git Commands Reference

### Daily Workflow Commands

```bash
# Start day: Sync sprint branch
git checkout sprint-1
git pull origin sprint-1

# Create story branch
git checkout -b story/STORY-XXX-description

# Stage changes
git add <files>

# Commit
git commit -m "feat(STORY-XXX): description"

# Push story branch
git push origin story/STORY-XXX-description

# Merge story to sprint
git checkout sprint-1
git merge --no-ff story/STORY-XXX-description
git push origin sprint-1

# Delete story branch
git branch -d story/STORY-XXX-description
git push origin --delete story/STORY-XXX-description
```

### Sprint Workflow Commands

```bash
# Create sprint branch
git checkout main
git pull origin main
git checkout -b sprint-N
git push -u origin sprint-N

# Create sprint-end PR
gh pr create --base main --head sprint-N --title "Sprint N: Goal"

# Merge sprint to main (after approval)
gh pr merge sprint-N --squash --delete-branch

# Tag release
git checkout main
git pull origin main
git tag -a v0.N.0-sprintN -m "Sprint N complete"
git push origin v0.N.0-sprintN
```

### Useful Git Commands

```bash
# View commit history
git log --oneline --graph --all

# View changes in a branch
git diff main...sprint-1

# View uncommitted changes
git diff

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Discard uncommitted changes
git checkout -- <file>

# Stash work in progress
git stash
git stash pop

# View all branches
git branch -a

# Delete merged branches
git branch --merged | grep -v "^\*" | xargs git branch -d
```

---

## Best Practices Summary

### ✅ Do's

1. **Commit frequently**: Small, atomic commits are better than large commits
2. **Write descriptive commit messages**: Future you will thank you
3. **Reference story IDs**: Always include `(STORY-XXX)` in commits
4. **Keep sprint branch green**: Never merge broken code
5. **Test before merging**: Run tests locally before every merge
6. **Delete merged branches**: Keep repository clean
7. **Tag releases**: Tag every sprint completion for easy reference
8. **Write meaningful PR descriptions**: Include demo, screenshots, metrics
9. **Self-review thoroughly**: Treat your code as if someone else will review it
10. **Document decisions**: Use commit messages to explain "why", not just "what"

### ❌ Don'ts

1. **Don't commit to main directly**: Always use sprint branches
2. **Don't merge untested code**: Tests must pass before merge
3. **Don't commit sensitive data**: API keys, passwords, personal info
4. **Don't use vague commit messages**: "fix bug", "updates", "wip"
5. **Don't mix unrelated changes**: One story per commit/branch
6. **Don't leave branches unmerged**: Merge or delete within 3 days
7. **Don't skip CI checks**: If CI fails, fix it before merging
8. **Don't force push to shared branches**: Use `--force-with-lease` if needed
9. **Don't rewrite history on main**: Never rebase or amend merged commits
10. **Don't ignore merge conflicts**: Resolve thoughtfully, test after resolution

---

## Example: Complete Sprint 1 Git Timeline

### Week 1 (Jan 13-19)

**Monday (Jan 13)**
```bash
# Sprint Planning complete
git checkout main
git checkout -b sprint-1
git push -u origin sprint-1

# STORY-001: Project Setup
git checkout -b story/STORY-001-project-setup
# ... work on project setup ...
git commit -m "feat(STORY-001): initialize Flutter project structure"
git commit -m "chore(STORY-001): add dependencies to pubspec.yaml"
git commit -m "docs(STORY-001): add README with setup instructions"
git checkout sprint-1
git merge --no-ff story/STORY-001-project-setup
git push origin sprint-1
git branch -d story/STORY-001-project-setup
# ✅ STORY-001 complete (3 pts burned)
```

**Tuesday-Wednesday (Jan 14-15)**
```bash
# STORY-002: Figma Design
git checkout -b story/STORY-002-figma-design
# ... create Figma designs ...
git commit -m "ui(STORY-002): create low-fidelity wireframes"
git commit -m "ui(STORY-002): create high-fidelity mockup for recording screen"
git commit -m "docs(STORY-002): add Figma link to README"
git checkout sprint-1
git merge --no-ff story/STORY-002-figma-design
git push origin sprint-1
# ✅ STORY-002 complete (5 pts burned, total: 8 pts)
```

**Thursday (Jan 16)**
```bash
# STORY-003: App Shell
git checkout -b story/STORY-003-app-shell
git commit -m "feat(STORY-003): configure MaterialApp and theme"
git commit -m "feat(STORY-003): implement home screen with navigation"
git commit -m "ui(STORY-003): add bottom navigation bar"
git checkout sprint-1
git merge --no-ff story/STORY-003-app-shell
git push origin sprint-1
# ✅ STORY-003 complete (3 pts burned, total: 11 pts)
```

**Friday (Jan 17)**
```bash
# STORY-004: Voice Recording Service (Day 1)
git checkout -b story/STORY-004-voice-recording-service
git commit -m "feat(STORY-004): add flutter_sound dependency"
git commit -m "feat(STORY-004): implement AudioRecordingService class"
git push origin story/STORY-004-voice-recording-service
# WIP, continue Monday
```

### Week 2 (Jan 20-26)

**Monday (Jan 20)**
```bash
# STORY-004: Voice Recording Service (Day 2)
git checkout story/STORY-004-voice-recording-service
git commit -m "test(STORY-004): add unit tests for recording service"
git commit -m "fix(STORY-004): handle permission denial gracefully"
git checkout sprint-1
git merge --no-ff story/STORY-004-voice-recording-service
git push origin sprint-1
# ✅ STORY-004 complete (5 pts burned, total: 16 pts)
```

**Tuesday-Wednesday (Jan 21-22)**
```bash
# STORY-005: Voice Recording UI
git checkout -b story/STORY-005-voice-ui
git commit -m "ui(STORY-005): implement recording screen layout"
git commit -m "ui(STORY-005): add recording button with state colors"
git commit -m "ui(STORY-005): implement countdown timer"
git commit -m "ui(STORY-005): add waveform visualization"
git commit -m "style(STORY-005): fix linting warnings"
git checkout sprint-1
git merge --no-ff story/STORY-005-voice-ui
git push origin sprint-1
# ✅ STORY-005 complete (5 pts burned, total: 21 pts)
```

**Thursday (Jan 23)**
```bash
# STORY-006: Audio Quality Validation
git checkout -b story/STORY-006-audio-quality
git commit -m "feat(STORY-006): implement AudioQualityValidator class"
git commit -m "test(STORY-006): add tests for validation rules"
git commit -m "ui(STORY-006): add quality feedback messages"
git checkout sprint-1
git merge --no-ff story/STORY-006-audio-quality
git push origin sprint-1
# ✅ STORY-006 complete (2 pts burned, total: 23 pts)
```

**Friday (Jan 24) - Sprint Review**
```bash
# All stories complete! Prepare PR
git checkout sprint-1
flutter test              # ✅ All tests pass
flutter analyze           # ✅ No warnings
flutter build apk --debug # ✅ Build successful

# Record demo video
# Create PR: sprint-1 → main
gh pr create --base main --head sprint-1 \
  --title "Sprint 1: Foundation & Voice Recording UI" \
  --body "$(cat docs/sprint_1_pr_template.md)"

# Self-review PR over weekend
```

**Monday (Jan 27) - Sprint Retrospective & Merge**
```bash
# PR approved (self-review complete)
gh pr merge sprint-1 --squash --delete-branch

# Tag release
git checkout main
git pull origin main
git tag -a v0.1.0-sprint1 -m "Sprint 1: Voice Recording MVP"
git push origin v0.1.0-sprint1

# Write retrospective notes
# docs/retrospectives/sprint_1_retro.md

# Start Sprint 2!
git checkout -b sprint-2
git push -u origin sprint-2
```

---

## Troubleshooting

### Common Issues

#### Issue: Merge conflict in sprint branch

```bash
# Scenario: Story branch has conflicts with sprint branch

git checkout story/STORY-005-voice-ui
git pull origin sprint-1  # Pull latest sprint changes

# Resolve conflicts in IDE
# Then:
git add <resolved-files>
git commit -m "fix(STORY-005): resolve merge conflicts with sprint-1"
git push origin story/STORY-005-voice-ui

# Now merge to sprint
git checkout sprint-1
git merge --no-ff story/STORY-005-voice-ui
```

#### Issue: Accidentally committed to wrong branch

```bash
# Scenario: Committed to sprint-1 instead of story branch

# Move last commit to new branch
git branch story/STORY-XXX-description
git reset --hard HEAD~1  # Remove commit from sprint-1

# Now on story branch
git checkout story/STORY-XXX-description
# Commit is already there!
```

#### Issue: Need to update sprint branch from main

```bash
# Scenario: Main has hotfix that sprint needs

git checkout sprint-1
git merge main  # Or rebase if no conflicts
git push origin sprint-1
```

---

## Conclusion

This GitHub strategy ensures:
- ✅ **Incremental integration**: Stories merge frequently to sprint branch
- ✅ **Always deployable**: Sprint branch is always buildable
- ✅ **Clear history**: Commit messages reference stories
- ✅ **Quality gates**: CI checks on every push
- ✅ **Traceable progress**: GitHub Projects tracks story status
- ✅ **Clean main branch**: Only complete sprints merge to main

**Key Principle**: *"Integrate early, integrate often, but only promote complete features to production."*

---

**Document Status**: ACTIVE - To be followed from Sprint 1 onwards

**Next Review**: After Sprint 1 completion (Jan 27, 2026)

**Related Documents**:
- `AGILE_SPRINT_PLAN.md` (Sprint definitions and stories)
- `DEVELOPMENT_PLAN_SRS.md` (Requirements specification)
- `CONTRIBUTING.md` (General contribution guidelines)

---

**END OF GITHUB STRATEGY DOCUMENT**
