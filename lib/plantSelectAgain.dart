import 'package:flutter/material.dart';
import 'plantNicknameInput.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobileapp/userData.dart';
import 'package:intl/intl.dart';


class PlantSelectAgain extends StatefulWidget {
  const PlantSelectAgain({super.key});

  @override
  State<PlantSelectAgain> createState() => _PlantSelectAgainState();
}

class _PlantSelectAgainState extends State<PlantSelectAgain> {
  final UserDataService userDataService = UserDataService();

  // final List<Map<String, String?>> plantData = const [
  //   {
  //     'nickname': '요미미',
  //     'species': '포인세티아',
  //     'startDate': '23.10.01',
  //     'endDate': null,
  //     'silhouetteImage': 'assets/flower/s1.png',
  //     'completeImage': 'assets/flower/s1_com.png',
  //     'detail':'안녕하세요안ㄴ여항새야ㅑ뇰알ㄴ이라ㅓ니얼냗ㄴ아러나러낭ㄹㅁㄴ댜ㅓ니아ㅣ아ㅓㄹ먀더ㅐㅑㅓㄴ리ㅏㅓ이라ㅓㄴㅁ이ㅏ로냗ㄹ너ㅣㅏ너이',
  //   },
  //   {
  //     'nickname': null,
  //     'species': '백일홍',
  //     'startDate': null,
  //     'endDate': null,
  //     'silhouetteImage': 'assets/flower/s1.png',
  //     'completeImage': 'assets/flower/s1_com.png',
  //     'detail':'dksdldsjdksjflsdkfsldfjsldkfjslkdf',
  //   },
  //   {
  //     'nickname': '붉은 장미',
  //     'species': '장미',
  //     'startDate': '23.08.01',
  //     'endDate': '23.09.12',
  //     'silhouetteImage': 'assets/flower/s1.png',
  //     'completeImage': 'assets/flower/s1_com.png',
  //     'detail':'dksdldsjdksjflsdkfsldfjsldkfjslkdf',
  //   },
  //   {
  //     'nickname': '이쁜 라벤더',
  //     'species': '라벤더',
  //     'startDate': '23.07.05',
  //     'endDate': '23.08.20',
  //     'silhouetteImage': 'assets/flower/s1.png',
  //     'completeImage': 'assets/flower/s1_com.png',
  //     'detail':'dksdldsjdksjflsdkfsldfjsldkfjslkdf',
  //   },
  //   {
  //     'nickname': null,
  //     'species': '사루비아',
  //     'startDate': null,
  //     'endDate': null,
  //     'silhouetteImage': 'assets/flower/s1.png',
  //     'completeImage': 'assets/flower/s1_com.png',
  //     'detail':'dksdldsjdksjflsdkfsldfjsldkfjslkdf',
  //   },{
  //     'nickname': null,
  //     'species': '캘리포니아 포피',
  //     'startDate': null,
  //     'endDate': null,
  //     'silhouetteImage': 'assets/flower/s1.png',
  //     'completeImage': 'assets/flower/s1_com.png',
  //     'detail':'dksdldsjdksjflsdkfsldfjsldkfjslkdf',
  //   },{
  //     'nickname': null,
  //     'species': '코스모스',
  //     'startDate': null,
  //     'endDate': null,
  //     'silhouetteImage': 'assets/flower/s1.png',
  //     'completeImage': 'assets/flower/s1_com.png',
  //     'detail':'dksdldsjdksjflsdkfsldfjsldkfjslkdf',
  //   },
  // ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // leading: IconButton(
        //   onPressed: () => Navigator.pop(context),
        //   icon: const Icon(Icons.arrow_back_ios),
        // ),
        backgroundColor: Colors.white,
        title: const Text(
          '식물 목록',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
          future: userDataService.fetchPlantEncyclopedia(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('오류 발생: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('식물 데이터가 없습니다.'));
            }

            final plantData = snapshot.data!;

            return GridView.builder(
              padding: const EdgeInsets.all(15.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: plantData.length,
              itemBuilder: (context, index) {
                final plant = plantData[index];
                return _buildPlantBookCard(context, plant);
              },
            );
          }
      ),
    );
  }

  Widget _buildPlantBookCard(BuildContext context, Map<String, dynamic> plant) {
    final isCompleted = plant['endDate'] != null;
    final imagePath =
    isCompleted ? plant['imageUrl']! : plant['silhouetteImage']!;

    return GestureDetector(
      onTap: () {
        _showPlantSelectDetail(context, plant);
      },
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              // color: Colors.yellow,
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (isCompleted) // 다 키운 식물 표시
            Positioned(
              top: 8,
              left: 10,
              child: Container(
                alignment: Alignment.center, // 텍스트 중앙 정렬
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    // 아래 텍스트: 테두리 역할
                    Text(
                      DateFormat('yyyy.MM.dd').format((plant['endDate'] as Timestamp).toDate()),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 5 // 테두리 두께
                          ..color = Colors.white.withAlpha(180), // 테두리 색상
                      ),
                    ),
                    // 위 텍스트: 실제 텍스트
                    Text(
                      DateFormat('yyyy.MM.dd').format((plant['endDate'] as Timestamp).toDate()),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF4A6FA5), // 텍스트 색상
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Positioned(
            bottom: 13,
            left: 0,
            right: 0,
            child: Text(
              plant['species'] ?? '???',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showPlantSelectDetail(BuildContext context, Map<String, dynamic> plant) {
    final isCompleted = plant['endDate'] != null;
    final plantId = plant['plantId'];
    print(plantId);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    // color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: AssetImage(
                        isCompleted
                            ? plant['imageUrl']!
                            : plant['silhouetteImage']!,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (isCompleted) ...[
                  Text(
                  '이름: ${plant['nickname'] ?? '???'}',
                  style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '종류: ${plant['species'] ?? '???'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (plant['startDate'] != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '만난 날짜: ${DateFormat('yyyy.MM.dd').format((plant['startDate'] as Timestamp).toDate())}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                  if (plant['endDate'] != null)...[
                    const SizedBox(height: 8),
                    Text(
                      '다 키운 날짜: ${DateFormat('yyyy.MM.dd').format((plant['endDate'] as Timestamp).toDate())}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB4C7E7),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      '닫기',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 15),
                    ),
                  ),
                ] else ...[
                  Text(
                    plant['species'] ?? '???',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    plant['description'] ?? '이 식물에 대한 설명이 없습니다.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCCCCCC),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
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
                          backgroundColor: const Color(0xFFB4C7E7),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlantNicknameInputPage(plantId: plantId),
                            ),
                          );
                        },
                        child: const Text(
                          '선택하기',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
