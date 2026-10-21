import XCTest
@testable import MeCuidoCore

final class ChimeTests: XCTestCase {
    func testWavHeaderMatchesSamples() {
        let wav = Chime.wav(notes: [659.25, 880.00])
        XCTAssertEqual(String(decoding: wav.prefix(4), as: UTF8.self), "RIFF")
        XCTAssertEqual(String(decoding: wav[8..<16], as: UTF8.self), "WAVEfmt ")
        XCTAssertEqual(String(decoding: wav[36..<40], as: UTF8.self), "data")

        func uint32(at offset: Int) -> Int {
            wav[offset..<offset + 4].enumerated().reduce(0) { $0 | Int($1.element) << (8 * $1.offset) }
        }
        XCTAssertEqual(uint32(at: 4), wav.count - 8)
        XCTAssertEqual(uint32(at: 40), wav.count - 44)
        // 0.14 s por nota extra + 0.45 s de caída, a 44.1 kHz y 2 bytes por muestra.
        XCTAssertEqual(wav.count - 44, Int(0.59 * 44_100) * 2)
    }

    func testLongestChimeDoesNotClip() {
        let wav = Chime.wav(notes: [523.25, 659.25, 783.99, 1046.50])
        let peak = stride(from: 44, to: wav.count, by: 2)
            .map { abs(Int(Int16(bitPattern: UInt16(wav[$0]) | UInt16(wav[$0 + 1]) << 8))) }
            .max() ?? 0
        XCTAssertGreaterThan(peak, 0)
        XCTAssertLessThan(peak, Int(Int16.max))
    }
}
