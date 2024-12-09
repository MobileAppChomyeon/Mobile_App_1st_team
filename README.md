# Mobile_App_1st_team


TODO:
>기능
1. 식물 선택 화면
2. 홈
3. 수면 데이터 리스트 - 상세 데이터
4. 식물 도감 리스트 - 식물 상세 데이터
5. 설정
<br/>

# 1. Project Overview
- 프로젝트 이름: 초면
- 프로젝트 설명: 수면을 통한 식물 키우기


<br/>

# 2. Team Members (팀원 및 팀 소개)
|                                                        강지인                                                        |                                                        배준재                                                        |                                                        송정현                                                        |                                                        이형경                                                        |
|:-----------------------------------------------------------------------------------------------------------------:|:-----------------------------------------------------------------------------------------------------------------:|:-----------------------------------------------------------------------------------------------------------------:|:-----------------------------------------------------------------------------------------------------------------:|
| | |  |  |
|                                                       None                                                        |                                                        None                                                         |                                                        None                                                         |                                                        None                                                         |
|                                       [GitHub](https://github.com/J2in)                                        |                                       [GitHub](https://github.com/Baejjyee)                                        |                                        [GitHub](https://github.com/katie424)                                        |                                       [GitHub](https://github.com/Lee-Hyeongkyeong)                                       |


<br/>

# 3. Key Features (주요 기능)
- **식물 키우기**:
    - 식물 선택
    - 식물 정보
    - 식물 이름 짓기

- **식물 도감**:
    - 식물 상세 정보
    - 키우는 날짜

- **수면 질 체크**:
    - 수면 점수
    - 상세 수면 정보
    - 수면 목표 설정
      <br/>


# 4. Tasks & Responsibilities (작업 및 역할 분담)
<br/>


# 5. Technology Stack (기술 스택)
## 5.1 Language
|            | |
|------------|----------------|
| Flutter    || 

<br/>
<br/>


# 6. Project Structure (프로젝트 구조)
```plaintext
project_root/
├── lib/
│   ├── main.dart             # 앱의 진입점 파일
│   ├── background_select_page.dart
│   ├── home_screen.dart      # 메인 화면
│   ├── login.dart
│   ├── 다양한 .dart 파일들...
│   └── weeklySleepData.dart
├── assets/                   # 리소스 파일
│   ├── background/           # 배경 이미지
│   ├── flower/               # 꽃 관련 이미지
│   │   ├── ageratum/
│   │   ├── complete/
│   │   ├── cosmos/
│   │   ├── daisy/
│   │   └── silhouette/
│   ├── fonts/                # 폰트 파일
│   ├── icons/                # SVG 아이콘 파일
│   │   ├── book.svg
│   │   ├── dquote1.svg
│   │   ├── dquote2.svg
│   │   ├── gear.svg
│   │   └── moon.svg
│   └── images/               # 일반 이미지
│       ├── app_logo.png
│       ├── google_logo.png
│       └── hanja.png
├── pubspec.yaml              # 의존성 및 설정 파일
└── README.md                 # 프로젝트 설명
```

<br/>

# 7. Development Workflow (개발 워크플로우)
## 브랜치 전략 (Branch Strategy)
우리의 브랜치 전략은 Git Flow를 기반으로 하며, 다음과 같은 브랜치를 사용합니다.

- Main Branch
    - 배포 가능한 상태의 코드를 유지합니다.
    - 모든 배포는 이 브랜치에서 이루어집니다.

- {name} Branch
    - 팀원 각자의 개발 브랜치입니다.
    - 모든 기능 개발은 이 브랜치에서 이루어집니다.

<br/>

# 8. Coding Convention
## 문장 종료
```
// 세미콜론(;)
console.log("Hello World!");
```

<br/>


## 명명 규칙
* 상수 : 영문 대문자 + 스네이크 케이스
```
const NAME_ROLE;
```
* 변수 & 함수 : 카멜케이스
```
// state
const [isLoading, setIsLoading] = useState(false);
const [isLoggedIn, setIsLoggedIn] = useState(false);
const [errorMessage, setErrorMessage] = useState('');
const [currentUser, setCurrentUser] = useState(null);

// 배열 - 복수형 이름 사용
const datas = [];

// 정규표현식: 'r'로 시작
const = rName = /.*/;

// 이벤트 핸들러: 'on'으로 시작
const onClick = () => {};
const onChange = () => {};

// 반환 값이 불린인 경우: 'is'로 시작
const isLoading = false;

// Fetch함수: method(get, post, put, del)로 시작
const getEnginList = () => {...}
```

<br/>

## 블록 구문
```
// 한 줄짜리 블록일 경우라도 {}를 생략하지 않고, 명확히 줄 바꿈 하여 사용한다
// good
if(true){
  return 'hello'
}

// bad
if(true) return 'hello'
```

<br/>

## 함수
```
함수는 함수 표현식을 사용하며, 화살표 함수를 사용한다.
// Good
const fnName = () => {};

// Bad
function fnName() {};
```

<br/>

## 폴더 네이밍
카멜 케이스를 기본으로 하며, 컴포넌트 폴더일 경우에만 파스칼 케이스로 사용한다.
```
// 카멜 케이스
camelCase
// 파스칼 케이스
PascalCase
```
<br/>

# 9. 커밋 컨벤션
## 기본 구조
```
type : subject

body 
```
<br/>

## type 종류
```
feat : 새로운 기능 추가
fix : 버그 수정
docs : 문서 수정
style : 코드 포맷팅, 세미콜론 누락, 코드 변경이 없는 경우
refactor : 코드 리펙토링
test : 테스트 코드, 리펙토링 테스트 코드 추가
chore : 빌드 업무 수정, 패키지 매니저 수정
```

<br/>

## 커밋 이모지
```
== 코드 관련
📝	코드 작성
🔥	코드 제거
🔨	코드 리팩토링
💄	UI / style 변경

== 문서&파일
📰	새 파일 생성
🔥	파일 제거
📚	문서 작성

== 버그
🐛	버그 리포트
🚑	버그를 고칠 때

== 기타
🐎	성능 향상
✨	새로운 기능 구현
💡	새로운 아이디어
🚀	배포
```

<br/>

## 커밋 예시
```
== ex1
✨Feat: "회원 가입 기능 구현"

SMS, 이메일 중복확인 API 개발

== ex2
📚chore: styled-components 라이브러리 설치

UI개발을 위한 라이브러리 styled-components 설치
```

<br/>
<br/>
