import Foundation

// MARK: - Korean Particle Type
public enum KoreanParticleType {
    case 을를
    case 이가
    case 은는
    case 과와
    case 아야
    case 으로로

    /// 받침이 있을 때 사용될 조사
    public var withFinalConsonant: String {
        switch self {
        case .을를: return "을"
        case .이가: return "이"
        case .은는: return "은"
        case .과와: return "과"
        case .아야: return "아"
        case .으로로: return "으로"
        }
    }

    /// 받침이 없을 때 사용될 조사
    public var withoutFinalConsonant: String {
        switch self {
        case .을를: return "를"
        case .이가: return "가"
        case .은는: return "는"
        case .과와: return "와"
        case .아야: return "야"
        case .으로로: return "로"
        }
    }
}

// MARK: - Private helpers
private extension String {
    // 조사가 '바깥'에 와야 하는 닫는 따옴표/괄호류(후보)
    static let trailingWrapperScalars = CharacterSet(charactersIn: "”’\"'」』〉》)]}＞>")

    // tail 후보(공백/개행/문장부호/닫는 괄호/따옴표 등)
    static let trailingSkippableScalars: CharacterSet = {
        var set = CharacterSet.whitespacesAndNewlines
        set.formUnion(.punctuationCharacters)
        set.formUnion(trailingWrapperScalars)
        return set
    }()

    // 닫힘 → 대응 여는 기호 매핑
    static let closingToOpening: [Character: Character] = [
        ")": "(", "]": "[", "}": "{",
        "」": "「", "』": "『",
        "〉": "〈", "》": "《",
        "＞": "＜", ">": "<",
        // 따옴표(ASCII)는 동일 문자로 토글(짝수/홀수) 판단
        "\"": "\"", "'": "'",
        // 굽은 따옴표는 쌍 매핑
        "”": "“", "’": "‘",
    ]

    // core 안에 closing에 대응하는 '열린' 기호가 아직 남아있는지(짝이 안 맞았는지) 판단
    @inline(__always)
    static func hasUnmatchedOpening(in core: Substring, for closing: Character) -> Bool {
        guard let opening = closingToOpening[closing] else { return false }

        // ASCII 따옴표는 동일 문자로 토글: 개수가 홀수면 아직 열려 있음
        if closing == "\"" || closing == "'" {
            let count = core.reduce(into: 0) { $0 += ($1 == opening ? 1 : 0) }
            return count % 2 == 1
        }

        // 굽은 따옴표는 열린/닫힘 카운트 비교
        if closing == "”" || closing == "’" {
            let opens = core.reduce(into: 0) { $0 += ($1 == opening ? 1 : 0) }
            let closes = core.reduce(into: 0) { $0 += ($1 == closing ? 1 : 0) }
            return opens > closes
        }

        // 괄호류는 스택 대신 밸런스 계산
        var balance = 0
        for ch in core {
            if ch == opening { balance += 1 }
            else if ch == closing { balance -= 1 }
        }
        return balance > 0
    }

    /// 문자열을 core + wrappers + restTail로 분리
    /// - core: 본문
    /// - wrappers: core 바로 뒤에 있는 '실제로 감싸는' 닫힘 기호들
    /// - restTail: 쉼표/마침표/말줄임표/공백/개행 등 나머지 꼬리
    func splitCoreAndTails() -> (core: Substring, wrappers: Substring, restTail: Substring) {
        // 1) tail 전체 범위 식별
        var end = endIndex
        while end > startIndex {
            let i = index(before: end)
            let ch = self[i]
            if ch.unicodeScalars.allSatisfy({ Self.trailingSkippableScalars.contains($0) }) {
                end = i
            } else {
                break
            }
        }
        let core = self[..<end]
        let suffix = self[end...] // tail 전체

        // 2) tail 선두에서 '실제로 감싸는' wrappers만 연속 분리
        var idx = suffix.startIndex
        while idx < suffix.endIndex {
            let ch = suffix[idx]
            let isWrapperCandidate = ch.unicodeScalars.allSatisfy { Self.trailingWrapperScalars.contains($0) }
            if isWrapperCandidate, Self.hasUnmatchedOpening(in: core, for: ch) {
                idx = suffix.index(after: idx)
            } else {
                break
            }
        }
        let wrappers = suffix[..<idx]
        let restTail = suffix[idx...]
        return (core, wrappers, restTail)
    }

    /// 판단에 사용할 마지막 스칼라(NFC 정규화 후)
    func lastDecisionScalar(in text: Substring) -> Unicode.Scalar? {
        guard let lastChar = text.last else { return nil }
        let normalized = String(lastChar).precomposedStringWithCanonicalMapping
        return normalized.unicodeScalars.last
    }

    /// 한글 종성(받침) 여부
    func hasJongseong(scalarValue: UInt32) -> Bool {
        guard (0xAC00...0xD7A3).contains(scalarValue) else { return false }
        return (scalarValue - 0xAC00) % 28 != 0
    }

    /// 한글 ㄹ(리을) 받침 여부
    func hasRieulJongseong(scalarValue: UInt32) -> Bool {
        guard (0xAC00...0xD7A3).contains(scalarValue) else { return false }
        return (scalarValue - 0xAC00) % 28 == 8
    }
}

// MARK: - String Extension for Korean Particles
public extension String {
    /// 마지막 글자의 받침 여부
    /// - Note: 문장 끝의 공백/문장부호/닫는 괄호/따옴표 등은 무시하고 판단합니다.
    var hasJongseong: Bool {
        let (core, _, _) = splitCoreAndTails()
        guard let scalar = lastDecisionScalar(in: core) else { return false }
        return hasJongseong(scalarValue: scalar.value)
    }

    /// 마지막 글자의 ㄹ(리을) 받침 여부
    /// - Note: 문장 끝의 공백/문장부호/닫는 괄호/따옴표 등은 무시하고 판단합니다.
    var hasRieulJongseong: Bool {
        let (core, _, _) = splitCoreAndTails()
        guard let scalar = lastDecisionScalar(in: core) else { return false }
        return hasRieulJongseong(scalarValue: scalar.value)
    }

    /// 조사 타입에 따라 적절한 조사를 자동으로 붙입니다.
    /// - Parameter type: 조사 타입(을/를, 이/가, 은/는, 과/와, 아/야, 으로/로)
    /// - Returns: 조사가 붙은 문자열(문장 끝의 기호/공백은 자연스러운 위치에 유지)
    func kParticle(_ type: KoreanParticleType) -> String {
        let (core, wrappers, restTail) = splitCoreAndTails()
        guard !core.isEmpty else { return self }

        guard
            let lastWord = core.split(whereSeparator: \.isWhitespace).last,
            let scalar = lastDecisionScalar(in: lastWord)
        else {
            return String(core) + String(wrappers) + type.withoutFinalConsonant + String(restTail)
        }

        if type == .으로로 {
            // ㄹ 받침 예외: 받침이 ㄹ이면 "로" 사용
            if hasRieulJongseong(scalarValue: scalar.value) {
                return String(core) + String(wrappers) + "로" + String(restTail)
            }
            let useWith = hasJongseong(scalarValue: scalar.value)
            return String(core) + String(wrappers) + (useWith ? "으로" : "로") + String(restTail)
        } else {
            let useWith = hasJongseong(scalarValue: scalar.value)
            let particle = useWith ? type.withFinalConsonant : type.withoutFinalConsonant
            return String(core) + String(wrappers) + particle + String(restTail)
        }
    }
}
