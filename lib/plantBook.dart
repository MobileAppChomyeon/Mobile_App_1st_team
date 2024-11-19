import 'package:flutter/material.dart';

class PlantBook extends StatelessWidget {
  const PlantBook({super.key});

  final List<Map<String, String>> plantData = const [
    {
      'nickname': '요미미',
      'species': '포인세티아',
      'startDate': '23.10.01',
      'endDate': '23.11.12'
    },
    {
      'nickname': '선인장',
      'species': '사막의 친구',
      'startDate': '23.09.10',
      'endDate': '23.10.15'
    },
    {
      'nickname': '장미',
      'species': '붉은 장미',
      'startDate': '23.08.01',
      'endDate': '23.09.12'
    },
    {
      'nickname': '라벤더',
      'species': '향기로운 허브',
      'startDate': '23.07.05',
      'endDate': '23.08.20',
    },
    {
      'nickname': '바질',
      'species': '요리의 동반자',
      'startDate': '23.06.15',
      'endDate': '23.07.25',
    },
    {
      'nickname': '튤립',
      'species': '봄의 전령',
      'startDate': '23.03.20',
      'endDate': '23.04.30',
    },
    {
      'nickname': '무궁화',
      'species': '한국의 꽃',
      'startDate': '23.02.10',
      'endDate': '23.03.20',
    },
    {
      'nickname': '벚꽃',
      'species': '사쿠라',
      'startDate': '23.04.01',
      'endDate': '23.05.01',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text(
          '도감',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.only(left: 30.0, right: 30, top: 15, bottom: 30),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,

        ),
        itemCount: plantData.length,
        itemBuilder: (context, index) {
          final plant = plantData[index];
          return _buildPlantBookCard(
            context,
            plant['nickname']!,
            plant['species']!,
            plant['startDate']!,
            plant['endDate']!,
          );
        },
      ),
    );
  }

  Widget _buildPlantBookCard(
      BuildContext context,
      String nickname,
      String species,
      String startDate,
      String endDate,
      ) {
    return GestureDetector(
      onTap: () {
        _showPlantBookDetail(context, nickname, species, startDate, endDate);
      },
      child: SizedBox(
        width: 130,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              nickname,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  static void _showPlantBookDetail(
      BuildContext context,
      String nickname,
      String species,
      String startDate,
      String endDate,
      ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20, bottom: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '이름: $nickname',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  '종류: $species',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  '만난 날짜: $startDate',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  '다 키운 날짜: $endDate',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB4C7E7),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 13),
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
              ],
            ),
          ),
        );
      },
    );
  }
}
