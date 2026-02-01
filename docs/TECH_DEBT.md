# Technical Debt - Test Coverage Improvement

## Document Purpose
이 문서는 현재 플랫폼 의존성으로 인해 테스트 커버리지가 낮은 모듈들을 추적하고, 향후 개선 방향을 제시합니다.

**작성일**: 2026년 2월 1일  
**현재 전체 커버리지**: 44.91% (1,350 tests passing)  
**브랜치**: feature/test-coverage-improvement

---

## Executive Summary

### Decision Rationale
현재 시점에 Mock 라이브러리를 도입하여 플랫폼 의존성을 격리하는 것보다, Tech Debt로 관리하고 추후 revisit하는 것이 더 효율적이라고 판단:

1. **프로젝트 Velocity 우선순위**: 핵심 비즈니스 로직 테스트는 이미 완료 (Models 87.7%, Utils 100%)
2. **투자 대비 효과**: 플랫폼 의존성 모듈들은 얇은 wrapper 패턴으로 설계되어 있어, 복잡한 로직이 적음
3. **Mock 유지보수 비용**: Mockito/Mocktail 설정과 유지보수에 소요되는 시간 대비 실질적 가치 낮음
4. **Integration Test 계획**: 실제 디바이스에서의 통합 테스트로 더 효과적인 검증 가능
5. **리소스 집중**: 새로운 기능 개발과 사용자 가치 제공에 집중

### Coverage Breakdown by Category
| Category | Coverage | Status |
|----------|----------|--------|
| Models | 87.7% | ✅ Excellent |
| Utils | 100% | ✅ Complete |
| Providers | 45.8% | ⚠️ Moderate |
| Services | 29.9% | ⚠️ Low (platform dependencies) |
| UI | 6.6% | ⚠️ Very Low (widget testing) |

---

## Platform Dependency Tech Debt Items

### 1. AudioRecordingService
**Current Coverage**: 9.4% (12/127 lines)  
**File**: `lib/services/audio_recording_service.dart`  
**Test File**: `test/services/audio_recording_service_test.dart`

#### Dependencies
- `flutter_sound` (FlutterSoundRecorder)
- `permission_handler` (microphone permissions)
- iOS/Android native audio APIs

#### Current Test Scope
```dart
// Note: Full audio recording tests require mocking FlutterSoundRecorder
// Current tests focus on initialization and permission checks
```

✅ **Tested**: Initialization, permission state checks  
❌ **Not Tested**: Actual recording, file I/O, audio format handling

#### Recommendation
- **Priority**: Medium
- **Approach**: Integration tests on real devices
- **Alternative**: Wait for `flutter_sound` to provide official mock support
- **Effort Estimate**: 3-5 days (mock setup + comprehensive tests)

---

### 2. EncryptionService
**Current Coverage**: 8.3% (7/84 lines)  
**File**: `lib/services/encryption_service.dart`  
**Test File**: `test/services/encryption_service_test.dart`

#### Dependencies
- `flutter_secure_storage` (iOS Keychain, Android EncryptedSharedPreferences)
- Platform-specific secure storage APIs

#### Current Test Scope
```dart
// Note: Full encryption service tests require mocking FlutterSecureStorage
// Current tests verify basic initialization
```

✅ **Tested**: Service initialization  
❌ **Not Tested**: Actual encryption/decryption, key storage, key rotation

#### Recommendation
- **Priority**: High (security-critical)
- **Approach**: Consider integration tests with test encryption keys
- **Security Note**: Mock tests may not catch platform-specific security issues
- **Effort Estimate**: 2-3 days

---

### 3. ChwAuthService
**Current Coverage**: 6.2% (10/162 lines)  
**File**: `lib/services/chw_auth_service.dart`  
**Test File**: `test/services/chw_auth_service_test.dart`

#### Dependencies
- `flutter_secure_storage` (credential storage)
- `sqflite` (local user database)
- Network layer (API calls)

#### Current Test Scope
```dart
// Note: Comprehensive auth testing requires mocking FlutterSecureStorage and Database
```

✅ **Tested**: Basic initialization  
❌ **Not Tested**: Login flow, token management, credential storage, session handling

#### Recommendation
- **Priority**: High (authentication-critical)
- **Approach**: Integration tests with test accounts
- **Consideration**: E2E tests may be more valuable than unit tests with mocks
- **Effort Estimate**: 4-6 days

---

### 4. SyncService
**Current Coverage**: 8.3% (12/145 lines)  
**File**: `lib/services/sync_service.dart`  
**Test File**: `test/services/sync_service_test.dart`

#### Dependencies
- `sqflite` (local database)
- `connectivity_plus` (network status)
- Network layer (API sync)

#### Current Test Scope
✅ **Tested**: Initialization  
❌ **Not Tested**: Sync queue processing, conflict resolution, retry logic, offline handling

#### Recommendation
- **Priority**: Medium-High
- **Approach**: Mock `connectivity_plus` relatively easy; database mocking more complex
- **Consideration**: Sync logic may benefit from dedicated integration tests
- **Effort Estimate**: 5-7 days

---

### 5. SecureDatabaseHelper
**Current Coverage**: 11.5% (9/78 lines)  
**File**: `lib/services/secure_database_helper.dart`  
**Test File**: `test/services/secure_database_helper_test.dart`

#### Dependencies
- `sqflite` (SQLite database)
- `EncryptionService` (data encryption)

#### Current Test Scope
✅ **Tested**: Basic initialization  
❌ **Not Tested**: CRUD operations, encryption integration, schema migrations

#### Recommendation
- **Priority**: Medium
- **Approach**: Use `sqflite_common_ffi` for in-memory testing
- **Consideration**: Encryption integration testing requires EncryptionService mock
- **Effort Estimate**: 3-4 days

---

### 6. DatabaseHelper ⚠️
**Current Coverage**: 0.0% (0/87 lines)  
**File**: `lib/services/database_helper.dart`  
**Test File**: ❌ **DOES NOT EXIST**

#### Dependencies
- `sqflite` (SQLite database)

#### Current Test Scope
❌ **No tests exist**

#### Recommendation
- **Priority**: **HIGH** - Critical gap
- **Approach**: 
  1. Create basic test file using `sqflite_common_ffi`
  2. Test schema creation and migrations first
  3. Add CRUD operation tests incrementally
- **Effort Estimate**: 2-3 days (initial coverage) + 2-3 days (comprehensive)
- **Action Item**: This should be addressed before feature freeze

---

### 7. PatientInfoScreen (UI)
**Current Coverage**: 6.6% (12/182 lines)  
**File**: `lib/ui/screens/patient_info_screen.dart`  
**Test File**: `test/ui/screens/patient_info_screen_test.dart`

#### Dependencies
- Flutter Widget framework
- Various providers and services
- Navigation context

#### Current Test Scope
✅ **Tested**: Widget creation  
❌ **Not Tested**: User interactions, form validation, navigation flow, accessibility

#### Recommendation
- **Priority**: Medium
- **Approach**: Widget tests with `WidgetTester`
- **Consideration**: May be better covered by integration/E2E tests
- **Effort Estimate**: 2-4 days per major screen

---

## Revisit Plan

### Phase 1: Critical Gaps (Sprint N+1)
**Target**: Address 0% coverage items
- [ ] Create `test/services/database_helper_test.dart`
- [ ] Achieve minimum 30% coverage on DatabaseHelper
- **Estimated Effort**: 1 sprint

### Phase 2: Security-Critical Services (Sprint N+2)
**Target**: Improve auth and encryption coverage
- [ ] ChwAuthService integration tests
- [ ] EncryptionService integration tests with test keys
- **Estimated Effort**: 1 sprint

### Phase 3: Mock Library Evaluation (Backlog)
**Target**: Reassess mock library adoption
- [ ] Evaluate project size and complexity
- [ ] Review mock maintenance overhead vs. value
- [ ] Decision: Adopt Mockito/Mocktail or continue with integration tests
- **Timing**: When team size > 3 or coverage target > 70%

### Phase 4: UI Test Strategy (Backlog)
**Target**: Define widget testing approach
- [ ] Evaluate widget testing vs. E2E testing
- [ ] Create screen testing template
- [ ] Implement for critical user flows
- **Timing**: Post-MVP or when UI stabilizes

---

## Monitoring & Metrics

### Coverage Targets
- **Current**: 44.91%
- **Phase 1 Goal**: 50% (after DatabaseHelper tests)
- **Long-term Goal**: 60-70% (when integration tests added)

### Success Criteria
1. ✅ All critical business logic tested (Models, Utils)
2. ⚠️ Zero modules with 0% coverage (DatabaseHelper needs attention)
3. ⚠️ Security services have integration test coverage
4. ⏳ Platform-dependent services documented in Tech Debt

### Review Cadence
- **Sprint Retrospective**: Review tech debt priority
- **Quarterly**: Reassess mock library adoption decision
- **Pre-Release**: Ensure no new 0% coverage modules

---

## References

### Related Documents
- [AGILE_SPRINT_PLAN.md](./AGILE_SPRINT_PLAN.md) - Sprint planning and velocity tracking
- [DEVELOPMENT_PLAN_SRS.md](./DEVELOPMENT_PLAN_SRS.md) - Overall development requirements

### Test Files with Explicit Limitations
```
test/services/audio_recording_service_test.dart
test/services/chw_auth_service_test.dart
test/services/encryption_service_test.dart
test/services/sync_service_test.dart
test/services/secure_database_helper_test.dart
test/ui/screens/patient_info_screen_test.dart
```

### Coverage Report Location
- Coverage data: `mobile_app/coverage/lcov.info`
- Generate report: `flutter test --coverage`

---

## Appendix: Platform Dependency Patterns

### Common Pattern
대부분의 낮은 커버리지 모듈들은 **Thin Wrapper Pattern**을 따름:
```dart
class ServiceName {
  final PlatformDependency _dependency; // FlutterSecureStorage, Database 등
  
  // Simple wrapper methods
  Future<void> doSomething() async {
    return await _dependency.platformMethod();
  }
}
```

### Why Mocking May Not Add Value
1. **Wrapper 코드는 로직이 거의 없음**: 단순 호출 전달
2. **Platform API 계약 테스트**: Mock은 실제 플랫폼 동작 검증 불가
3. **Integration Test로 실효성 높은 검증 가능**: 실제 디바이스에서 동작 확인

### Counter-Example: When to Mock
복잡한 비즈니스 로직이 있는 경우 Mock 가치 높음:
```dart
class ComplexSyncService {
  // 복잡한 재시도 로직
  // 복잡한 충돌 해결 알고리즘  
  // 복잡한 상태 관리
}
```
→ 이런 경우는 Mock을 통한 단위 테스트가 효과적

---

**Last Updated**: 2026-02-01  
**Next Review**: Sprint Retrospective  
**Owner**: Development Team
