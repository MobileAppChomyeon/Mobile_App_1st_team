import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login.dart'; // LoginScreen을 import 합니다.

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool showPasswordError = false;
  bool showPasswordLengthError = false;
  bool showEmailError = false;

  // bool _validateEmail() {
  //   final email = emailController.text.trim();
  //   final isValidEmail = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  //   // if (!isValidEmail) {
  //   //   ScaffoldMessenger.of(context).showSnackBar(
  //   //     const SnackBar(content: Text('유효한 이메일 주소를 입력하세요.')),
  //   //   );
  //   // }
  //   // showEmailError = isValidEmail;
  //   return showEmailError = !isValidEmail;
  // }

  Map<String, bool> _validatePasswords() {
    setState(() {
      // 비밀번호 길이가 6자 이상인지 검증
      showPasswordLengthError = passwordController.text.length < 6;
      print('길이 유효성 여부: $showPasswordLengthError');

      // 비밀번호와 확인 비밀번호가 일치하는지 검증
      showPasswordError =
          passwordController.text != confirmPasswordController.text;
      print('일치 유효성 여부: $showPasswordError');

      final email = emailController.text.trim();
      final isValidEmail = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
      showEmailError = !isValidEmail;
      print('이메일 유효성 여부: $showEmailError');
    });

    return {
      'showPasswordError': showPasswordError,
      'showPasswordLengthError': showPasswordLengthError,
      'showEmailError': showEmailError,
    };
  }


  // 이메일로 회원가입
  Future<void> _registerWithEmail() async {
    // if (!_validatePasswords()) {
    //   // 비밀번호 검증 실패 시 함수 종료
    //   return;
    // }
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원가입이 완료되었습니다.')),
      );

      // 회원가입 성공 후 로그인 페이지로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Firebase Error: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: ${e.toString()}')),
      );
    }
    // 비밀번호 길이 체크
    // if (passwordController.text.length < 6) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('비밀번호는 최소 6자리 이상이어야 합니다.'),
    //       duration: Duration(seconds: 2), // 표시 시간 설정
    //     ),
    //   );
    //   return;
    // }
    //
    // setState(() {
    //   showPasswordLengthError = passwordController.text.length < 6;
    //   showPasswordError =
    //       passwordController.text != confirmPasswordController.text;
    // });
    //
    // if (showPasswordError) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('비밀번호가 일치하지 않습니다.'),
    //       duration: Duration(seconds: 2),
    //     ),
    //   );
    //   return;
    // }
    //
    // try {
    //   await FirebaseAuth.instance.createUserWithEmailAndPassword(
    //     email: emailController.text.trim(),
    //     password: passwordController.text,
    //   );
    //
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Email registration completed!')),
    //   );
    //
    //   // 회원가입 성공 후 로그인 페이지로 이동
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (context) => const LoginScreen()),
    //   );
    // } on FirebaseAuthException catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Error: ${e.message}')),
    //   );
    // } catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Unexpected error: ${e.toString()}')),
    //   );
    // }
  }

  // Google 회원가입
  Future<void> _registerWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return; // 사용자가 로그인 취소

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google registration completed: ${userCredential.user?.email}')),
      );

      // 회원가입 성공 후 로그인 페이지로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account already exists with a different credential.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Firebase Error: ${e.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: ${e.toString()}')),
      );
    }
  }

  // 이메일 회원가입 모달을 띄우는 함수
  void _showRegisterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.8,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(), // 키보드 숨기기
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '이메일 회원가입',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: confirmPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    // 상태에 따른 경고 메시지 표시
                    if (showEmailError)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          '유효한 이메일을 입력하세요',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    if (showPasswordLengthError)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          '비밀번호는 6자리 이상이어야 합니다.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    if (showPasswordError)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          '비밀번호가 일치하지 않습니다.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        FocusScope.of(context).unfocus(); // 키보드 닫기
                        // final emailResult = _validateEmail();
                        final result = _validatePasswords();
                        if (!result['showPasswordError']! && !result['showPasswordLengthError']! && !result['showEmailError']!) {
                          await _registerWithEmail();
                        } else {
                          print('Validation failed');
                        }
                        // setState(() {
                        //   // 비밀번호 길이 체크
                        //   showPasswordLengthError = passwordController.text.length < 6;
                        //   // 비밀번호 확인 체크
                        //   showPasswordError =
                        //       passwordController.text != confirmPasswordController.text;
                        // });
                        //
                        // // 모든 조건 충족 시 회원가입 시도
                        // if (!showPasswordError && !showPasswordLengthError) {
                        //   _registerWithEmail();
                        // }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(82, 110, 160, 1.0),
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        '가입하기',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "이메일로 회원가입 해보세요",
                style: TextStyle(
                  fontFamily: "Pretendard",
                  fontWeight: FontWeight.w400,
                  fontSize: 24,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 50),
              // ElevatedButton(
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Colors.white,
              //     minimumSize: const Size.fromHeight(50),
              //     side: const BorderSide(color: Colors.black, width: 1),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(8.0),
              //     ),
              //   ),
              //   onPressed: _registerWithGoogle,
              //   child: Stack(
              //     children: [
              //       Align(
              //         alignment: Alignment.centerLeft,
              //         child: Image.asset('assets/images/google_logo.png'),
              //       ),
              //       const Center(
              //         child: Text(
              //           'Google 회원가입하기',
              //           style: TextStyle(
              //             fontFamily: "Pretendard",
              //             fontWeight: FontWeight.w400,
              //             fontSize: 20,
              //             color: Colors.black,
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              // const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(82, 110, 160,1.0),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: _showRegisterModal,
                child: const Text(
                  '이메일 회원가입하기',
                  style: TextStyle(
                    fontFamily: "Pretendard",
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
