import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'backgroundSelectPage.dart';
import 'userData.dart'; // userData.dart를 올바르게 import
import 'package:cloud_firestore/cloud_firestore.dart';

class PlantNicknameInputPage extends StatefulWidget {
  final String plantId;
  const PlantNicknameInputPage({super.key, required this.plantId});

  @override
  State<PlantNicknameInputPage> createState() => _PlantNicknameInputPageState();
}

class _PlantNicknameInputPageState extends State<PlantNicknameInputPage> {
  final TextEditingController _plantNicknameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool isButtonEnabled = false;
  Map<String, dynamic>? plantData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlantData();
  }

  Future<void> _loadPlantData() async {
    try {
      final snapshot = await _db.collection('plants').doc(widget.plantId).get();
      if (snapshot.exists) {
        setState(() {
          plantData = snapshot.data() as Map<String, dynamic>;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("식물 데이터를 불러올 수 없습니다.")),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("오류 발생: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (plantData == null) {
      return const Scaffold(
        body: Center(child: Text("식물 데이터를 불러올 수 없습니다.")),
      );
    }

    final imageUrl = plantData!['imageUrl'] ?? '';
    final species = plantData!['species'] ?? '이름 없음';

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text(
          '식물 선택',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(size.width * 0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: size.height * 0.05,),
            Text(
              '${species}의 이름을 지어주세요',
              style: const TextStyle(fontSize: 23),
            ),
            SizedBox(height: size.height * 0.05),
            Container(
              width: size.width * 0.4,
              height: size.width * 0.4,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(size.width * 0.03),
                image: DecorationImage(
                  image: AssetImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: size.height * 0.03),
            SizedBox(
              width: size.width * 0.6,
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
                    borderRadius:
                    BorderRadius.all(Radius.circular(size.width * 0.02)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.all(Radius.circular(size.width * 0.02)),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ),
            SizedBox(height: size.height * 0.2),
            ElevatedButton(
              onPressed: isButtonEnabled
                  ? () async {
                final plantNickname = _plantNicknameController.text;
                final user = _auth.currentUser;

                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("로그인이 필요합니다.")),
                  );
                  return;
                }

                try {
                  await _db
                      .collection('Users')
                      .doc(user.uid)
                      .collection('Plants')
                      .doc('currentPlant')
                      .set({
                    ...plantData!,
                    'nickname': plantNickname,
                    'startDate': Timestamp.fromDate(DateTime.now()),
                    'growthStage': 1,
                  });
                  print('현재 내 식물 정보 업데이트');

                  final encyclopediaRef = _db
                      .collection('Users')
                      .doc(user.uid)
                      .collection('Plants')
                      .doc('encyclopedia')
                      .collection('plantsList')
                      .doc(widget.plantId);
                  await encyclopediaRef.set({
                    ...plantData!,
                    'nickname': plantNickname,
                    'startDate': Timestamp.fromDate(DateTime.now()),
                  });
                  print('내 도감 업데이트');

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BackgroundSelectPage(plantNickname: plantNickname),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("식물 정보 저장 실패: $e")),
                  );
                }
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                isButtonEnabled ? const Color(0xFF4A6FA5) : Colors.grey,
                minimumSize: Size(size.width * 0.8, size.height * 0.07),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(size.width * 0.03),
                ),
              ),
              child: Text(
                '다음',
                style: TextStyle(
                  color: isButtonEnabled ? Colors.white : Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
