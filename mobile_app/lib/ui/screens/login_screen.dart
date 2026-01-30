/// Login Screen
/// STORY-027: CHW Authentication System
///
/// CHW 로그인 화면입니다.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/chw_auth_provider.dart';

/// 로그인 화면
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<ChwAuthProvider>();
    final success = await authProvider.login(
      _phoneController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      // 로그인 성공 - 홈으로 이동
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      // 에러 스낵바 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? '로그인 실패'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // 로고 및 타이틀
                _buildHeader(),
                
                const SizedBox(height: 48),
                
                // 로그인 폼
                _buildLoginForm(),
                
                const SizedBox(height: 24),
                
                // 로그인 버튼
                _buildLoginButton(),
                
                const SizedBox(height: 16),
                
                // PIN 로그인
                _buildPinLoginOption(),
                
                const SizedBox(height: 32),
                
                // 등록 링크
                _buildRegisterLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.medical_services,
            size: 40,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'NeuroAccess',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '지역사회 건강요원 로그인',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        // 전화번호
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: const InputDecoration(
            labelText: '전화번호',
            hintText: '예: 0712345678',
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '전화번호를 입력하세요';
            }
            if (value.length < 9) {
              return '올바른 전화번호를 입력하세요';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // 비밀번호
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: '비밀번호',
            prefixIcon: const Icon(Icons.lock),
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '비밀번호를 입력하세요';
            }
            if (value.length < 6) {
              return '비밀번호는 6자 이상이어야 합니다';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 8),
        
        // 로그인 유지
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value ?? false;
                });
              },
            ),
            const Text('로그인 유지'),
            const Spacer(),
            TextButton(
              onPressed: () {
                // 비밀번호 재설정 화면으로 이동
              },
              child: const Text('비밀번호 찾기'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Consumer<ChwAuthProvider>(
      builder: (context, authProvider, child) {
        return ElevatedButton(
          onPressed: authProvider.isLoading ? null : _login,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: authProvider.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(
                  '로그인',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        );
      },
    );
  }

  Widget _buildPinLoginOption() {
    return Consumer<ChwAuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isPinSet) return const SizedBox.shrink();
        
        return TextButton.icon(
          onPressed: () {
            _showPinDialog();
          },
          icon: const Icon(Icons.pin),
          label: const Text('PIN으로 빠른 로그인'),
        );
      },
    );
  }

  void _showPinDialog() {
    showDialog(
      context: context,
      builder: (context) => const PinLoginDialog(),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('계정이 없으신가요?'),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/register');
          },
          child: const Text('등록하기'),
        ),
      ],
    );
  }
}

/// PIN 로그인 다이얼로그
class PinLoginDialog extends StatefulWidget {
  const PinLoginDialog({super.key});

  @override
  State<PinLoginDialog> createState() => _PinLoginDialogState();
}

class _PinLoginDialogState extends State<PinLoginDialog> {
  final List<String> _pin = [];
  static const int _pinLength = 4;

  void _addDigit(String digit) {
    if (_pin.length < _pinLength) {
      setState(() {
        _pin.add(digit);
      });

      if (_pin.length == _pinLength) {
        _submitPin();
      }
    }
  }

  void _removeDigit() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin.removeLast();
      });
    }
  }

  Future<void> _submitPin() async {
    final pinString = _pin.join();
    final authProvider = context.read<ChwAuthProvider>();
    final success = await authProvider.loginWithPin(pinString);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      setState(() {
        _pin.clear();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'PIN이 올바르지 않습니다'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'PIN 입력',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            // PIN 표시
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pinLength, (index) {
                return Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: index < _pin.length 
                        ? Theme.of(context).primaryColor 
                        : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: index < _pin.length
                      ? const Icon(Icons.circle, size: 12, color: Colors.white)
                      : null,
                );
              }),
            ),
            
            const SizedBox(height: 24),
            
            // 숫자 키패드
            _buildKeypad(),
            
            const SizedBox(height: 16),
            
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['1', '2', '3'].map(_buildKeypadButton).toList(),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['4', '5', '6'].map(_buildKeypadButton).toList(),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['7', '8', '9'].map(_buildKeypadButton).toList(),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 60),
            _buildKeypadButton('0'),
            SizedBox(
              width: 60,
              height: 60,
              child: IconButton(
                onPressed: _removeDigit,
                icon: const Icon(Icons.backspace_outlined),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeypadButton(String digit) {
    return SizedBox(
      width: 60,
      height: 60,
      child: ElevatedButton(
        onPressed: () => _addDigit(digit),
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          digit,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

/// 등록 화면
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String _selectedRegion = 'KE';
  String _selectedFacility = 'FAC-001';
  bool _acceptTerms = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이용약관에 동의해주세요')),
      );
      return;
    }

    final authProvider = context.read<ChwAuthProvider>();
    final success = await authProvider.register(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      email: _emailController.text.trim().isNotEmpty 
          ? _emailController.text.trim() 
          : null,
      password: _passwordController.text,
      regionCode: _selectedRegion,
      facilityId: _selectedFacility,
    );

    if (!mounted) return;

    if (success) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('등록 완료'),
          content: const Text('등록이 완료되었습니다.\n관리자 승인 후 로그인할 수 있습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? '등록 실패'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CHW 등록'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 이름
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: '이름 *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '이름을 입력하세요';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: '성 *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '성을 입력하세요';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 전화번호
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: '전화번호 *',
                  hintText: '예: 0712345678',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '전화번호를 입력하세요';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // 이메일
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: '이메일 (선택)',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 비밀번호
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '비밀번호 *',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력하세요';
                  }
                  if (value.length < 6) {
                    return '비밀번호는 6자 이상이어야 합니다';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // 비밀번호 확인
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '비밀번호 확인 *',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return '비밀번호가 일치하지 않습니다';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // 지역 선택
              DropdownButtonFormField<String>(
                value: _selectedRegion,
                decoration: const InputDecoration(
                  labelText: '지역 *',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'KE', child: Text('케냐')),
                  DropdownMenuItem(value: 'TZ', child: Text('탄자니아')),
                  DropdownMenuItem(value: 'UG', child: Text('우간다')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedRegion = value!;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // 시설 선택
              DropdownButtonFormField<String>(
                value: _selectedFacility,
                decoration: const InputDecoration(
                  labelText: '소속 시설 *',
                  prefixIcon: Icon(Icons.local_hospital),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'FAC-001', child: Text('키베라 건강센터')),
                  DropdownMenuItem(value: 'FAC-002', child: Text('마타레 클리닉')),
                  DropdownMenuItem(value: 'FAC-003', child: Text('카와로티 건강센터')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedFacility = value!;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // 이용약관 동의
              CheckboxListTile(
                value: _acceptTerms,
                onChanged: (value) {
                  setState(() {
                    _acceptTerms = value ?? false;
                  });
                },
                title: const Text('이용약관 및 개인정보 처리방침에 동의합니다'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              
              const SizedBox(height: 24),
              
              // 등록 버튼
              Consumer<ChwAuthProvider>(
                builder: (context, authProvider, child) {
                  return ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: authProvider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('등록하기', style: TextStyle(fontSize: 16)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
