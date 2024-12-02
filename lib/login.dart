import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'register.dart';
import 'home_screen.dart';
import 'plantSelect.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _loginWithEmail() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Login Successful')));

      // Navigate to HomeScreen after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PlantSelect()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _loginWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return; // User cancelled login
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Google Login Successful')));

      // Navigate to HomeScreen after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
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
                    backgroundColor: Color.fromRGBO(82, 110, 160, 1.0),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: isGoogleLogin ? _loginWithGoogle : _loginWithEmail,
                  child: Text(
                    isGoogleLogin ? 'Google 로그인 실행' : '이메일 로그인 실행',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text('Login'),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/hanja.png'),
            // const Text(
            //   '초면: 草眠',
            //   style: TextStyle(fontSize: 40),
            // ),
            const Text('건강한 수면으로 키우는 초록 친구',style: TextStyle(fontFamily: "Pretendard",fontWeight:FontWeight.w400,fontSize: 14,color: Colors.black ),),
            Image.asset("assets/images/app_logo.png"),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                );
              },
              child: const Text('이메일로 회원가입하기',style: TextStyle(fontFamily: "Pretendard",fontWeight:FontWeight.w400,fontSize: 16,color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(82, 110, 160, 1.0),
                minimumSize: const Size.fromHeight(50),
                // side: BorderSide(color: Colors.black,width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () => _showLoginModal(false), // 이메일 로그인 모달
              child: const Text('이메일 로그인',style: TextStyle(fontFamily: "Pretendard",fontWeight:FontWeight.w400,fontSize: 20,color: Colors.white)),
            ),

            SizedBox(height: 10,),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                side: BorderSide(color: Colors.black,width: 1),
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
                    child: const Text('Google 로그인',style: TextStyle(fontFamily: "Pretendard",fontWeight:FontWeight.w400,fontSize: 20,color: Colors.black),),
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