# EunNeun

 [![Swift](https://img.shields.io/badge/Swift-5.7%2B-orange)](https://swift.org)
 [![Platforms](https://img.shields.io/badge/지원-iOS%2013%2B%20%7C%20macOS%2010.15%2B%20%7C%20watchOS%206%2B%20%7C%20tvOS%2013%2B-blue)](#compatibility)

한국어 조사 자동 선택을 위한 Swift 라이브러리

## Overview

EunNeun은 문자열의 "마지막 단어"를 기준으로 받침 유무를 판별하고, 적절한 조사를 자동으로 붙여줍니다.

- ㄹ(리을) 받침의 "으로/로" 특수 규칙을 지원
- 따옴표/괄호/말줄임표/공백 등 문장 끝 tail을 자연스럽게 처리(Smart tail)
  - 예) `"\"사과\"".kParticle(.을를)` → `"\"사과\"를"`, `"(사과)".kParticle(.을를)` → `"(사과)를"`, `"사과...".kParticle(.을를)` → `"사과를..."`

```swift
// 👇 잊지 말고!
import EunNeun

"사과".kParticle(.을를)           // "사과를"
"책".kParticle(.이가)             // "책이"
"선물".kParticle(.으로로)         // "선물로" (ㄹ 받침 특수 처리)
"우리 집 (2층)".kParticle(.으로로) // "우리 집 (2층)으로"
"카페.... )".kParticle(.을를)     // "카페를.... )"
```

## Installation (Swift Package Manager)

### Xcode

1. File > Add Packages…
2. 리포지토리 URL: `https://github.com/halococo/EunNeun`
3. 프로젝트 타깃(앱/프레임워크)에 EunNeun 추가

### Package.swift

```swift
// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "YourApp",
    dependencies: [
        .package(url: "https://github.com/halococo/EunNeun.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "YourApp",
            dependencies: ["EunNeun"]
        )
    ]
)
```

## Usage

### 조사 타입: `KoreanParticleType`

- `.을를`, `.이가`, `.은는`, `.과와`, `.아야`, `.으로로`

### String 확장

- `kParticle(_ type: KoreanParticleType) -> String`
- `hasJongseong: Bool`
- `hasRieulJongseong: Bool`

### 예시

```swift
"안녕 세계".kParticle(.은는)   // "안녕 세계는"
"학교".kParticle(.으로로)       // "학교로"
"선물".kParticle(.으로로)       // "선물로"
```

## Rules (조사 선택 규칙)

### 일반 규칙

- `.을를`: 받침 있음 → "을", 받침 없음 → "를"
- `.이가`: 받침 있음 → "이", 받침 없음 → "가"
- `.은는`: 받침 있음 → "은", 받침 없음 → "는"
- `.과와`: 받침 있음 → "과", 받침 없음 → "와"
- `.아야`: 받침 있음 → "아", 받침 없음 → "야"

### 특수 규칙: `.으로로`

- 받침 있음 → "으로"
- 단, ㄹ(리을) 받침이면 "로"
- 받침 없음 → "로"

```swift
"집".kParticle(.으로로)   // "집으로" (일반 받침)
"길".kParticle(.으로로)   // "길로"   (ㄹ 받침 예외)
"학교".kParticle(.으로로) // "학교로" (받침 없음)
```

## How it works (기술적 배경)

- 한글 유니코드 범위(가–힣): 0xAC00 ~ 0xD7A3
- 종성(받침) 계산
  - 기본 계산식: `(유니코드값 - 0xAC00) % 28`
  - 결과가 `0`이면 받침 없음, `1 ~ 27`이면 받침 있음
  - ㄹ 받침 여부: `(유니코드값 - 0xAC00) % 28 == 8`

## Examples

### 기본 사용

```swift
import EunNeun

let fruits = ["사과", "바나나", "딸기"]
let messages = fruits.map { "\($0.kParticle(.을를)) 좋아해요" }
// ["사과를 좋아해요", "바나나를 좋아해요", "딸기를 좋아해요"]
```

### 동적 문장 생성

```swift
func createGreeting(name: String) -> String {
    "\(name.kParticle(.이가)) 안녕하세요!"
}

createGreeting(name: "철수")  // "철수가 안녕하세요!"
createGreeting(name: "영희")  // "영희가 안녕하세요!"
```

### 게임/앱 메시지

```swift
func showResult(item: String, action: String) -> String {
    "\(item.kParticle(.을를)) \(action)했습니다!"
}

showResult(item: "검", action: "획득")     // "검을 획득했습니다!"
showResult(item: "사과", action: "획득")   // "사과를 획득했습니다!"
```

## Notes (주의사항)

- 여러 단어가 있을 경우 "마지막 단어"를 기준으로 판정합니다.
- 비한글로 끝나는 문자열은 받침이 없는 것으로 처리됩니다.
  - 예: `"Apple".kParticle(.이가)` → `"Apple가"`, `"10".kParticle(.으로로)` → `"10로"`
- 문자열 끝 처리(Smart tail)
  - 닫는 따옴표/괄호는 조사 '앞'에 배치: `"\"사과\""` → `"\"사과\"를"`, `"(사과)"` → `"(사과)를"`
  - 쉼표/마침표/말줄임표/공백/개행은 조사 '뒤'에 유지: `"사과..."` → `"사과를..."`, `"사과, "` → `"사과를, "`
  - 짝이 없는 닫는 괄호는 tail로 간주: `"학교)"` → `"학교로)"`
- 유니코드 분해형(NFD) 입력은 드물게 예상과 다를 수 있습니다(일반 입력기는 합성형/NFC 사용).

## Compatibility

- iOS 13.0+
- macOS 10.15+
- watchOS 6.0+
- tvOS 13.0+
- Swift 5.7+

Package.swift의 platforms/도구 버전과 일치시키는 것을 권장합니다.

## License

MIT

## Contributing

버그 리포트 시 재현 케이스와 환경 정보를 함께 제공해 주세요.
