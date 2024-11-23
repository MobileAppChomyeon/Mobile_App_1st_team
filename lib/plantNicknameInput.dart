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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          }, icon: const Icon(Icons.arrow_back_ios)),
        title: const Text(
            '식물 선택',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                '식물친구의 이름을 지어주세요',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 60),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 230,
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
                  decoration: const InputDecoration(
                    counter: Center(
                      child: Text(
                        "이름은 6글자까지만 가능해요",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                      )
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: const BorderSide(
                        color: Colors.grey, // 포커스 상태 테두리 색상
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 140),
              ElevatedButton(
                onPressed: isButtonEnabled ? () {
                  final plantNickname = _plantNicknameController.text;
                  print('식물 이름 설정됨');
                  // Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BackgroundSelectPage(plantNickname: plantNickname)),
                  );
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isButtonEnabled ? const Color(0xFF4A6FA5) : Colors.grey,
                  minimumSize: const Size(300, 60),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(fontSize: 18,),
                ),
                child: Text('다음',
                  style: TextStyle(
                    color: isButtonEnabled ? Colors.white : Colors.black54, // 활성/비활성 상태에 따라 색상 변경
                  ),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}