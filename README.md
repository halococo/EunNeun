# EunNeun 🇰🇷

> 한국어 조사, 이제 걱정 끝!  
> 헷갈리던 조사 선택을 대신 해드립니다.  
> `"사과".kParticle(.을를)` → `"사과를"` 

[![Version](https://img.shields.io/badge/version-1.0.2-blue.svg)](https://github.com/halococo/EunNeun/releases)
[![Swift](https://img.shields.io/badge/Swift-5.7%2B-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2013%2B%20|%20macOS%2010.15%2B%20|%20watchOS%206%2B%20|%20tvOS%2013%2B-lightgrey.svg)](https://developer.apple.com)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![SPM](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg)](https://swift.org/package-manager)

---

## EunNeun은 어떤 라이브러리인가요?

문자열에 `.kParticle(...)` 메서드를 호출하면,  
**받침 유무와 특수 규칙(예: ㄹ 받침, 괄호 등)을 자동 판별**하여  
알맞은 **한국어 조사**를 붙여줍니다.

> `"학교)".kParticle(.으로로)` → `"학교로)"`  
> `"물".kParticle(.으로로)` → `"물로"` (ㄹ 받침 예외 적용)

---

## 이런 경험 있으시죠?

```swift
// 헷갈리는 조사들...
let message = userName + "이/가" + " " + itemName + "을/를" + " 획득했습니다!"

// 조건문으로 직접 처리...
let particle = hasJongseong(word) ? "을" : "를"
let result = word + particle

// ㄹ 받침 예외도 처리해야...
if word.last == "ㄹ" && particleType == "으로/로" {
    // ...
}
```

---

## 이제 이렇게 간단하게!

```swift
// 👇 잊지 말고!
import EunNeun

"사과".kParticle(.을를)   // "사과를"
"책".kParticle(.을를)     // "책을"

let message = "\(userName.kParticle(.이가)) \(itemName.kParticle(.을를)) 획득했습니다!"
// 예: "철수가 검을 획득했습니다!"
```

---

## 왜 EunNeun인가요?

- **정확성**
  - 유니코드 기반 받침 분석
  - ㄹ(리을) 받침 예외 자동 처리
  - 종성 계산 로직 → 빠르고 정확함
- **편의성**
  - `.kParticle(.을를)`처럼 직관적인 API
  - 공백, 개행, 괄호, 따옴표도 자동 정리
  - 메서드 체이닝 친화적
- **실용성**
  - 게임, 채팅, 알림 등에 즉시 사용 가능
  - Swift 스타일 가이드에 맞춘 구현
  - SPM으로 간편 설치

---

## 설치

### Swift Package Manager

```swift
// Package.swift
// swift-tools-version:5.7
dependencies: [
    .package(url: "https://github.com/halococo/EunNeun", from: "1.0.2")
]
```

### Xcode
- File → Add Package Dependencies →  
  `https://github.com/halococo/EunNeun`

> Swift 5.7+, Xcode 14.0+ 환경 권장

---

## 1분만에 배우기

```swift
import EunNeun

"사과".kParticle(.을를)     // "사과를"
"책".kParticle(.이가)       // "책이"
"철수".kParticle(.아야)     // "철수야"
"학교".kParticle(.으로로)   // "학교로"

let user = "지영"
let item = "포도"
print("\(user.kParticle(.이가)) \(item.kParticle(.을를)) 맛있어요")
// → "지영이 포도를 맛있어요"
```

---

## 실전 활용 예제

### 게임 메시지
```swift
func showReward(item: String, count: Int) -> String {
    "\(item.kParticle(.을를)) \(count)개 획득하셨습니다!"
}
```

### 채팅 봇
```swift
func createGreeting(name: String) -> String {
    let isMorning = Calendar.current.component(.hour, from: Date()) < 12
    return "\(name.kParticle(.이가)) \(isMorning ? "좋은 아침" : "안녕하세요")!"
}
```

### 알림 메시지
```swift
func createNotification(friend: String, action: String) -> String {
    "\(friend.kParticle(.이가)) 회원님의 게시물에 \(action)습니다."
}
```

---

## 지원하는 조사 종류

| 조사 | 예시 |
|------|------|
| `.을를` | `"책".kParticle(.을를)` → `"책을"` |
| `.이가` | `"사과".kParticle(.이가)` → `"사과가"` |
| `.은는` | `"고양이".kParticle(.은는)` → `"고양이는"` |
| `.과와` | `"친구".kParticle(.과와)` → `"친구와"` |
| `.아야` | `"민수".kParticle(.아야)` → `"민수야"` |
| `.으로로` | `"물".kParticle(.으로로)` → `"물로"` / `"집".kParticle(.으로로)` → `"집으로"` |

---

## 고급 기능

### ㄹ 받침 자동 처리
```swift
"물".kParticle(.으로로)   // "물로"
"길".kParticle(.으로로)   // "길로"
"집".kParticle(.으로로)   // "집으로"
```

### 스마트 tail 정리
```swift
"\"사과\"".kParticle(.을를)         // "\"사과\"를"
"(책)".kParticle(.이가)             // "(책)이"
"학교)".kParticle(.으로로)          // "학교로)"
"카페.... )".kParticle(.을를)       // "카페를.... )"
"사과   \n".kParticle(.을를)        // "사과를   \n"
```

---

## 동작 원리

- 유니코드 한글 범위: U+AC00 ~ U+D7A3
- 종성(받침) 판별 공식:

```swift
let offset = unicodeScalar - 0xAC00
let hasFinalConsonant = (offset % 28) != 0
let isRieul = (offset % 28) == 8
```

---

## 시스템 요구사항

- Swift 5.7+
- iOS 13.0+, macOS 10.15+, watchOS 6.0+, tvOS 13.0+
- Xcode 14.0+ (권장)

---

## 참고 사항

- “마지막 단어” 기준으로 조사 판별
- 한글 외 문자열은 받침 없는 것으로 간주
  - `"Apple".kParticle(.이가)` → `"Apple가"`
- 괄호, 따옴표 등은 적절히 밖/안 구분하여 조사 붙임

---

## 기여하기

- 기능 제안: [GitHub Discussions](https://github.com/halococo/EunNeun/discussions)
- 버그 제보: [GitHub Issues](https://github.com/halococo/EunNeun/issues)

---

## 라이선스

MIT License © 2025 [Byul Kang](mailto:halococoa@gmail.com)  
See [LICENSE](./LICENSE) for details.
