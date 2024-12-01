import 'package:flutter/material.dart';
import 'backgroundSelectPage.dart';

class PlantNicknameInputPage extends StatefulWidget {
  const PlantNicknameInputPage({super.key});

  @override
  State<PlantNicknameInputPage> createState() => _PlantNicknameInputPageState();
}

class _PlantNicknameInputPageState extends State<PlantNicknameInputPage> {
  final TextEditingController _plantNicknameController = TextEditingController();
  bool isButtonEnabled = false;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size; // 화면 크기 가져오기

    return Scaffold(
      resizeToAvoidBottomInset: false, // 키보드에 따라 레이아웃을 조정
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text(
          '식물 선택',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '식물친구의 이름을 지어주세요',
                style: TextStyle(fontSize: 23),
              ),
              SizedBox(height: size.height * 0.08),
              Container(
                width: size.width * 0.4,
                height: size.width * 0.4, // 가로와 세로를 동일 비율로 설정
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(size.width * 0.03),
                ),
              ),
              SizedBox(height: size.height * 0.03),
              SizedBox(
                width: size.width * 0.6, // 텍스트 필드의 너비를 화면 크기에 비례하도록 설정
                child: TextFormField(
                  controller: _plantNicknameController,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF4A6FA5),
                  ),
                  onChanged: (value) {
                    setState(() {
                      isButtonEnabled = value.isNotEmpty;
                    });
                  },
                  decoration: InputDecoration(
                    counter: const Center(
                      child: Text(
                        "이름은 6글자까지만 가능해요",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(size.width * 0.02)),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(size.width * 0.02)),
                      borderSide: const BorderSide(
                        color: Colors.grey, // 포커스 상태 테두리 색상
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.2),
              ElevatedButton(
                onPressed: isButtonEnabled
                    ? () {
                  final plantNickname = _plantNicknameController.text;
                  print('식물 이름 설정됨');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BackgroundSelectPage(plantNickname: plantNickname),
                    ),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isButtonEnabled ? const Color(0xFF4A6FA5) : Colors.grey,
                  minimumSize: Size(size.width * 0.8, size.height * 0.07), // 버튼의 크기를 화면 비율로 설정
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.1,
                    vertical: size.height * 0.015,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(size.width * 0.03),
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: Text(
                  '다음',
                  style: TextStyle(
                    color: isButtonEnabled ? Colors.white : Colors.black54, // 활성/비활성 상태에 따라 색상 변경
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
