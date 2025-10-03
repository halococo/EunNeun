import XCTest
@testable import EunNeun

final class EunNeunTests: XCTestCase {
    
    // MARK: - 받침 판단 / Final Consonant Detection
    
    func testHasJongseongBasics() {
        // 받침 있는 단어 / Words with final consonants
        XCTAssertTrue("책".hasJongseong)
        XCTAssertTrue("집".hasJongseong)
        XCTAssertTrue("물".hasJongseong)
        
        // 받침 없는 단어 / Words without final consonants
        XCTAssertFalse("사과".hasJongseong)
        XCTAssertFalse("나무".hasJongseong)
        XCTAssertFalse("학교".hasJongseong)
        
        // 문장부호/괄호 무시 / Ignore punctuation/brackets
        XCTAssertTrue("책,".hasJongseong)
        XCTAssertFalse("사과,".hasJongseong)
        XCTAssertTrue("값)".hasJongseong)
    }
    
    func testHasRieulJongseongBasics() {
        // ㄹ 받침 / Rieul final consonant
        XCTAssertTrue("물".hasRieulJongseong)
        XCTAssertTrue("길".hasRieulJongseong)
        XCTAssertTrue("을".hasRieulJongseong)
        
        // ㄹ 받침 아님 / Not Rieul
        XCTAssertFalse("집".hasRieulJongseong)
        XCTAssertFalse("책".hasRieulJongseong)
        XCTAssertFalse("학교".hasRieulJongseong)
        
        // 문장부호/괄호 무시 / Ignore punctuation/brackets
        XCTAssertTrue("물)".hasRieulJongseong)
        XCTAssertFalse("학교,".hasRieulJongseong)
    }
    
    // MARK: - 조사 붙이기 / Korean Particle Attachment
    
    func testEulReul() {
        // 을/를 조사 / Object marker
        XCTAssertEqual("책".kParticle(.을를), "책을")
        XCTAssertEqual("사과".kParticle(.을를), "사과를")
        
        // 꼬리 보존 / Preserve trailing characters
        XCTAssertEqual("사과, ".kParticle(.을를), "사과를, ")
        XCTAssertEqual("사과...".kParticle(.을를), "사과를...")
        XCTAssertEqual("\"사과\"".kParticle(.을를), "\"사과\"를")
    }
    
    func testIGa() {
        // 이/가 조사 / Subject marker
        XCTAssertEqual("책".kParticle(.이가), "책이")
        XCTAssertEqual("사과".kParticle(.이가), "사과가")
        XCTAssertEqual("사과\n".kParticle(.이가), "사과가\n")
    }
    
    func testEunNeun() {
        // 은/는 조사 / Topic marker
        XCTAssertEqual("물".kParticle(.은는), "물은")
        XCTAssertEqual("바나나".kParticle(.은는), "바나나는")
    }
    
    func testGwaWa() {
        // 과/와 조사 / Conjunction marker
        XCTAssertEqual("책".kParticle(.과와), "책과")
        XCTAssertEqual("친구".kParticle(.과와), "친구와")
    }
    
    func testAYa() {
        // 아/야 조사 / Vocative marker
        XCTAssertEqual("철수".kParticle(.아야), "철수야")
        XCTAssertEqual("민혁".kParticle(.아야), "민혁아")
        XCTAssertEqual("영희".kParticle(.아야), "영희야")
    }
    
    func testEuroRoSpecialRule() {
        // ㄹ 받침 특수 처리 / Special rule for Rieul final consonant
        XCTAssertEqual("물".kParticle(.으로로), "물로")
        XCTAssertEqual("길".kParticle(.으로로), "길로")
        
        // 일반 받침 → "으로" / Regular final consonants → "euro"
        XCTAssertEqual("집".kParticle(.으로로), "집으로")
        XCTAssertEqual("값".kParticle(.으로로), "값으로")
        
        // 받침 없음 → "로" / No final consonant → "ro"
        XCTAssertEqual("학교".kParticle(.으로로), "학교로")
        
        // 문장부호/괄호 꼬리 보존 / Preserve punctuation/brackets
        XCTAssertEqual("우리 집 (2층)".kParticle(.으로로), "우리 집 (2층)으로")
        XCTAssertEqual("학교)".kParticle(.으로로), "학교로)")
        XCTAssertEqual("카페.... )".kParticle(.은는), "카페는.... )")
    }
    
    // MARK: - 다단어 문장 처리 / Multi-word Sentences
    
    func testMultiWordSentences() {
        // 마지막 단어 기준으로 조사 선택 / Particle selection based on the last word
        XCTAssertEqual("빨간 사과".kParticle(.을를), "빨간 사과를")
        XCTAssertEqual("안녕 세계".kParticle(.은는), "안녕 세계는")
        XCTAssertEqual("우리 집".kParticle(.으로로), "우리 집으로")
    }
    
    // MARK: - 엣지 케이스 / Edge Cases
    
    func testEdgeCases() {
        // 빈 문자열 → 원본 유지 / Empty string → keep original
        XCTAssertEqual("".kParticle(.을를), "")
        
        // 공백/문장부호만 있는 경우 → 원본 유지 / Only whitespace/punctuation → keep original
        XCTAssertEqual("   ".kParticle(.이가), "   ")
        XCTAssertEqual("!!!".kParticle(.이가), "!!!")
        
        // 영문/숫자 → 비한글로 처리 (받침 없음으로 간주) / English/Numbers → treated as no final consonant
        XCTAssertEqual("Apple".kParticle(.이가), "Apple가")
        XCTAssertEqual("10".kParticle(.으로로), "10로")
    }
    
    // MARK: - 괄호/따옴표 짝 맞춤 / Bracket/Quote Pairing
    
    func testBracketPairing() {
        // 괄호가 완전히 닫혔을 때: 조사가 괄호 '밖'에 / When brackets are closed: particle goes outside
        XCTAssertEqual("책(좋은 책)".kParticle(.을를), "책(좋은 책)을")
        XCTAssertEqual("사과(빨간 사과)".kParticle(.을를), "사과(빨간 사과)를")
        
        // 괄호가 열린 상태: 일반 문자처럼 처리 (받침 기준) / When brackets are open: treated as regular text
        XCTAssertEqual("책(좋은".kParticle(.을를), "책(좋은을")
        XCTAssertEqual("사과(빨간".kParticle(.을를), "사과(빨간을")
        
        // 중첩 괄호 / Nested brackets
        XCTAssertEqual("책((안쪽))".kParticle(.을를), "책((안쪽))을")
    }
    
    func testQuotePairing() {
        // 굽은 따옴표 - 유니코드로 명시 / Curly quotes - Unicode escaped
        XCTAssertEqual("\u{201C}사과\u{201D}".kParticle(.을를), "\u{201C}사과\u{201D}를")
        XCTAssertEqual("\u{2018}책\u{2019}".kParticle(.을를), "\u{2018}책\u{2019}을")
        
        // ASCII 따옴표는 이스케이프 / ASCII quotes escaped
        XCTAssertEqual("\"책\"".kParticle(.을를), "\"책\"을")
        XCTAssertEqual("\"사과".kParticle(.을를), "\"사과를") // 열린 상태 / open state
    }
    
    // MARK: - 유니코드 정규화 / Unicode Normalization
    
    func testNFDInputLight() {
        // 분해형으로 만들어도 '사과'는 받침 없음이라 결과 동일 / NFD decomposed form still has no final consonant
        let nfd = "사과".decomposedStringWithCanonicalMapping
        XCTAssertEqual(nfd.kParticle(.을를), nfd + "를")
        
        // 꼬리 보존 확인 / Verify tail preservation
        let nfdWithPunct = (nfd + "...")
        XCTAssertEqual(nfdWithPunct.kParticle(.을를), nfd + "를...")
    }
}
