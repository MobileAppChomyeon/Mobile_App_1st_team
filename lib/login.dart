import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'register.dart';
import 'home_screen.dart';
import 'plantSelect.dart';
import 'plantData.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _navigateBasedOnUserInfo(User user) async {
    try {
      final plantService = PlantService();
      print('도감에 식물정보 추가');
      await plantService.addEncyclopedia();

      // 현재 사용자의 Firestore 문서 참조
      final currentPlantDoc = await FirebaseFirestore.instance
          .collection('Users') // Users 컬렉션
          .doc(user.uid) // userId 문서
          .collection('Plants') // Plants 서브컬렉션
          .doc('currentPlant') // currentPlant 문서
          .get();

      // nickname 필드 확인
      if (currentPlantDoc.exists && currentPlantDoc.data()?['nickname'] != null) {
        // nickname 존재 -> HomeScreen으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // nickname 없음 -> PlantSelect로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PlantSelect()),
        );
      }
    } catch (e) {
      // 오류 처리
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }


  void _showLoginModal(bool isGoogleLogin) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 전체 화면 모달
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.9, // 화면 높이의 90% 차지
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus(); // 키보드 닫기
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isGoogleLogin ? 'Google 로그인' : '이메일 로그인',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context); // 모달 닫기
                        },
                      ),
                    ],
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
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(82, 110, 160, 1.0),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () async {
                      FocusScope.of(context).unfocus(); // 키보드 닫기
                      if (isGoogleLogin) {
                        await _loginWithGoogle();
                      } else {
                        await _loginWithEmail();
                      }
                    },
                    child: Text(
                      isGoogleLogin ? 'Google 로그인 실행' : '이메일 로그인 실행',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showPopupMessage(String message) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          alignment: Alignment.center,
          backgroundColor: Colors.white, // 배경 흰색
          content: Column(
            mainAxisSize: MainAxisSize.min, // 팝업 크기를 내용에 맞게 조정
            children: [
              const SizedBox(height: 20), // 텍스트를 아래로 내리기 위한 여백
              Text(
                message,
                textAlign: TextAlign.center, // 텍스트 가운데 정렬
                style: const TextStyle(
                  fontFamily: "Pretendard",
                  fontWeight: FontWeight.w400,
                  fontSize: 22,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          actions: [
            Center( // 버튼을 가운데 정렬
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 팝업 닫기
                },
                child: const Text(
                  '확인',
                  style: TextStyle(
                    fontFamily: "Pretendard",
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }



  Future<void> _loginWithEmail() async {
    try {

      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // 로그인 성공 시 다음 페이지로 이동
      await _navigateBasedOnUserInfo(credential.user!);
    } catch (e) {
      // 로그인 실패 시 안내 메시지 표시
      await _showPopupMessage('로그인하지 못했습니다.');
    }
  }

  Future<void> _loginWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return; // 로그인 취소
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      // 로그인 성공 시 다음 페이지로 이동
      await _navigateBasedOnUserInfo(userCredential.user!);
    } catch (e) {
      // 로그인 실패 시 안내 메시지 표시
      await _showPopupMessage('로그인하지 못했습니다.');
    }
  }



  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // 화면 크기 가져오기

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(size.width * 0.04), // 너비의 4%를 패딩으로 설정
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/hanja.png'),
            SizedBox(height: size.height * 0.02), // 높이의 2% 간격
            const Text(
              '건강한 수면으로 키우는 초록 친구',
              style: TextStyle(
                fontFamily: "Pretendard",
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            SizedBox(
              height: size.height * 0.4, // 높이의 15%
              child: Image.asset('assets/images/app_logo.png'),
            ),
            SizedBox(height: size.height * 0.03), // 높이의 3% 간격
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                );
              },
              child: const Text(
                '이메일로 회원가입하기',
                style: TextStyle(
                  fontFamily: "Pretendard",
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            SizedBox(height: size.height * 0.01),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(82, 110, 160, 1.0),
                minimumSize: Size.fromHeight(size.height * 0.06), // 너비의 80%, 높이의 6%
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () => _showLoginModal(false), // 이메일 로그인 모달
              child: const Text(
                '이메일 로그인',
                style: TextStyle(
                  fontFamily: "Pretendard",
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: size.height * 0.01), // 높이의 2% 간격
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: Size.fromHeight(size.height * 0.06),
                side: const BorderSide(color: Colors.black, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () => _showLoginModal(true), // Google 로그인 모달
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset('assets/images/google_logo.png'),
                  ),
                  Center(
                    child: const Text(
                      'Google 로그인',
                      style: TextStyle(
                        fontFamily: "Pretendard",
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
