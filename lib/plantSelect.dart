import 'package:flutter/material.dart';
import 'plantNicknameInput.dart';

class PlantSelect extends StatelessWidget {
  const PlantSelect({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              const Text(
                '식물 하나를 다 키우면 또 다른 식물을 키울 수 있으니\n걱정 말고 마음에 드는 친구를 골라주세요',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              const SizedBox(height: 50),
              Wrap(
                spacing: 30,
                runSpacing: 30,
                alignment: WrapAlignment.center,
                children: [
                  _buildPlantCard(context, '코스모스', '가녀린 줄기와 풍성한 꽃잎으로 유명한 코스모스는 가을의 대표적인 꽃이에요. 햇볕을 좋아하며 관리가 쉬워 초보자도 키우기 좋습니다. 다양한 색상으로 정원이나 화단을 밝게 만듭니다.', 'assets/flower/cosmos/cosmos0.png'),
                  _buildPlantCard(context, '데이지', '심플하고 귀여운 하얀 꽃잎과 노란 꽃 중심이 특징인 데이지는 사랑과 순수함을 상징합니다. 강한 생명력으로 어디서든 잘 자라며 그늘에서도 적응력이 뛰어나요. 작은 공간에서도 아름다운 포인트를 줍니다.', 'assets/flower/daisy/daisy0.png'),
                  _buildPlantCard(context, '아게라텀', '부드러운 퍼플, 블루, 화이트 색상의 털 같은 꽃이 매력적인 아게라텀은 여름 정원에 생기를 더해줍니다. 강렬한 햇볕에도 잘 자라며 벌과 나비를 끌어들이는 효과가 있어요. 낮은 키로 화단 가장자리에 심기 적합합니다.', 'assets/flower/ageratum/ageratum0.png'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildPlantCard(BuildContext context, String plantName, String description, String imagePath) {
    return GestureDetector(
      onTap: () => _showPlantDetail(context, plantName, description, imagePath),
      child: SizedBox(
        width: 140,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                // color: Colors.blue[100],
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(image: AssetImage(imagePath),
                fit: BoxFit.cover,
                ),

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

  static void _showPlantDetail(BuildContext context, String plantName, String description, String imagePath) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.white,
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
                        // color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(image: AssetImage(imagePath),
                        fit: BoxFit.cover,)
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      plantName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      description,
                      textAlign:  TextAlign.center,
                      style: const TextStyle(fontSize: 16),
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
                              fontSize: 16,
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
                              fontSize: 16,
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
