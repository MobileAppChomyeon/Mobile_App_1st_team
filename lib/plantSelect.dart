import 'package:flutter/material.dart';
import 'plantNicknameInput.dart';

class PlantSelect extends StatelessWidget {
  const PlantSelect({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '오늘부터 키워볼 식물을 골라볼까요?',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                '식물 하나를 다 키우면 또 다른 식물을 키울 수 있으니\n걱정 말고 마음에 드는 친구를 골라주세요',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.5, color: Colors.black),
              ),
              const SizedBox(height: 30),
              Wrap(
                spacing: 30,
                runSpacing: 30,
                alignment: WrapAlignment.center,
                children: [
                  _buildPlantCard(context, '식물1', '식물설명왕아아아\n식물설명1'),
                  _buildPlantCard(context, '식물2', '식물설명왕아아아\n식물설명2'),
                  _buildPlantCard(context, '식물3', '식물설명왕아아아\n식물설명3'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildPlantCard(BuildContext context, String plantName, String description) {
    return GestureDetector(
      onTap: () => _showPlantDetail(context, plantName, description),
      child: SizedBox(
        width: 140,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              plantName,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  static void _showPlantDetail(BuildContext context, String plantName, String description) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 30, bottom: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      plantName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      description,
                      textAlign:  TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFCCCCCC),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w100,
                            ),
                            minimumSize: const Size(110, 40),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            '취소하기',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A6FA5),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w100,
                            ),
                            minimumSize: const Size(110, 40),
                          ),
                          onPressed: () {
                            // 선택하기 로직 추가
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      PlantNicknameInputPage()),
                            ); // 이름 설정 페이지로 이동
                          },
                          child: const Text(
                            '선택하기',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}