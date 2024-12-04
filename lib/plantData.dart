import 'package:cloud_firestore/cloud_firestore.dart';
class PlantService {
  final plants = [
    {
      'plantId': 'cosmos',
      'species': '코스모스',
      'nickname': null,
      'description': '가녀린 줄기와 풍성한 꽃잎으로 유명한 코스모스는 가을의 대표적인 꽃이에요. 햇볕을 좋아하며 관리가 쉬워 초보자도 키우기 좋습니다. 다양한 색상으로 정원이나 화단을 밝게 만듭니다.',
      'startDate': null,
      'endDate': null,
      'growthStage': 0,
      'silhouetteImage': 'assets/flower/silhouette/s6.png',
      'imageUrl': 'assets/flower/cosmos/cosmos0.png',
    },
    {
      'plantId': 'daisy',
      'species': '데이지',
      'nickname': null,
      'description': '심플하고 귀여운 하얀 꽃잎과 노란 꽃 중심이 특징인 데이지는 사랑과 순수함을 상징합니다. 강한 생명력으로 어디서든 잘 자라며 그늘에서도 적응력이 뛰어나요. 작은 공간에서도 아름다운 포인트를 줍니다.',
      'growthStage': 0,
      'silhouetteImage': 'assets/flower/silhouette/s7.png',
      'startDate': null,
      'endDate': null,
      'imageUrl': 'assets/flower/daisy/daisy0.png',
    },
    {
      'plantId': 'ageratum',
      'species': '아게라텀',
      'nickname': null,
      'description': '부드러운 퍼플, 블루, 화이트 색상의 털 같은 꽃이 매력적인 아게라텀은 여름 정원에 생기를 더해줍니다. 강렬한 햇볕에도 잘 자라며 벌과 나비를 끌어들이는 효과가 있어요. 낮은 키로 화단 가장자리에 심기 적합합니다.',
      'growthStage': 0,
      'silhouetteImage': 'assets/flower/silhouette/s8.png',
      'startDate': null,
      'endDate': null,
      'imageUrl': 'assets/flower/ageratum/ageratum0.png',
    },
    {
      'plantId': 'other1',
      'species': '백일홍',
      'description': '오랜 시간 동안 꽃을 피워내는 백일홍은 여름의 정원에 강렬한 색감을 더합니다. 더운 날씨에 강하고 관리가 간단해 초보자에게도 적합해요. 다양한 색상과 크기로 정원의 중심을 장식할 수 있습니다.',
      'nickname': null,
      'growthStage': 0,
      'silhouetteImage': 'assets/flower/silhouette/s1.png',
      'startDate': null,
      'endDate': null,
      'imageUrl': null,
    },
    {
      'plantId': 'other2',
      'species': '사루비아',
      'description': '강렬한 빨간색 꽃송이가 특징인 사루비아는 여름과 가을 정원의 눈길을 사로잡습니다. 따뜻한 햇볕 아래서 잘 자라며 벌과 나비를 유혹하는 매력이 있어요. 깔끔한 줄기 모양으로 화단의 구조를 더해줍니다.',
      'growthStage': 0,
      'silhouetteImage': 'assets/flower/silhouette/s2.png',
      'startDate': null,
      'endDate': null,
      'imageUrl': null,
    },
    {
      'plantId': 'other3',
      'species': '캘리포니아 포피',
      'description': '밝은 오렌지색 꽃이 특징인 캘리포니아 포피는 양지바른 곳에서 가장 잘 자랍니다. 건조한 환경에도 강하고, 관리가 쉬워 도시 정원에서도 인기가 많아요. 자연스러운 매력으로 화단을 따뜻하게 만듭니다.',
      'growthStage': 0,
      'silhouetteImage': 'assets/flower/silhouette/s3.png',
      'startDate': null,
      'endDate': null,
      'imageUrl': null,
    },
    {
      'plantId': 'other4',
      'species': '루드베키아',
      'description': '큰 노란 꽃잎과 어두운 중앙이 특징인 루드베키아는 정원에서 햇빛처럼 빛나는 분위기를 제공합니다. 강한 생명력과 내구성으로 초보자에게도 적합해요. 여름부터 가을까지 오랜 기간 꽃을 피웁니다.',
      'growthStage': 0,
      'silhouetteImage': 'assets/flower/silhouette/s4.png',
      'startDate': null,
      'endDate': null,
      'imageUrl': null,
    },
    {
      'plantId': 'other5',
      'species': '안스리움',
      'description': '빨간색 하트 모양의 꽃과 광택 있는 잎으로 실내를 화사하게 만드는 안스리움은 열대 분위기를 연출합니다. 반그늘에서 잘 자라며 공기 정화 효과가 있어 인기가 높아요. 실내 장식용으로 이상적인 선택입니다.',
      'growthStage': 0,
      'silhouetteImage': 'assets/flower/silhouette/s5.png',
      'startDate': null,
      'endDate': null,
      'imageUrl': null,
    },
  ];

  Future<void> addDefaultPlantsIfNeeded(String userId) async {
    try {
      final plantCollection = FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('Plants')
          .doc('encyclopedia')
          .collection('plantsList'); // This is a subcollection for individual plants

      for (var plant in plants) {
        // Add each plant as a document under the plantsList subcollection
        await plantCollection.doc(plant['plantId'] as String).set({
          'species': plant['species'],
          'nickname': plant['nickname'],
          'description': plant['description'],
          'startDate': plant['startDate'],
          'endDate': plant['endDate'],
          'growthStage': plant['growthStage'],
          'silhouetteImage': plant['silhouetteImage'],
          'imageUrl': plant['imageUrl'],
        });

        print('${plant['species']} added to encyclopedia.');
      }
    } catch (e) {
      print('Error adding plants to encyclopedia: $e');
    }
  }
}