import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_access/providers/chw_auth_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthState', () {
    test('should have all required states', () {
      expect(AuthState.values.length, 5);
      expect(AuthState.values, contains(AuthState.initial));
      expect(AuthState.values, contains(AuthState.loading));
      expect(AuthState.values, contains(AuthState.authenticated));
      expect(AuthState.values, contains(AuthState.unauthenticated));
      expect(AuthState.values, contains(AuthState.error));
    });
  });

  group('ChwAuthProvider', () {
    late ChwAuthProvider provider;

    setUp(() {
      provider = ChwAuthProvider();
    });

    test('should start with initial state', () {
      expect(provider.state, AuthState.initial);
    });

    test('should not be authenticated initially', () {
      expect(provider.isAuthenticated, false);
    });

    test('should not be loading initially', () {
      expect(provider.isLoading, false);
    });

    test('currentUser should be null initially', () {
      expect(provider.currentUser, isNull);
    });

    test('errorMessage should be null initially', () {
      expect(provider.errorMessage, isNull);
    });

    test('isPinSet should be false initially', () {
      expect(provider.isPinSet, false);
    });

    test('isAuthenticated should check state', () {
      // The provider starts in initial state
      expect(provider.state, AuthState.initial);
      expect(provider.isAuthenticated, false);
    });

    test('isLoading should check state', () {
      expect(provider.state, AuthState.initial);
      expect(provider.isLoading, false);
    });
  });
}
