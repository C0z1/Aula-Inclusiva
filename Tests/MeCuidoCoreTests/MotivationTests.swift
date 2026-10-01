import XCTest
@testable import MeCuidoCore

final class MotivationTests: XCTestCase {
    private let cama = Routine.all[2]

    // MARK: - Catálogos

    func testExistingAccessoryThresholdsNeverRise() {
        // Subirlos volvería a bloquear accesorios que un niño ya ganó.
        let original = ["estrella": 1, "gorra": 3, "corazon": 5, "corona": 8, "cohete": 12]
        for (id, medals) in original {
            XCTAssertLessThanOrEqual(Accessory.all.first { $0.id == id }?.medalsRequired ?? .max, medals, id)
        }
    }

    func testPetsAndBackdropsAreWellFormed() {
        XCTAssertEqual(Pet.all.first?.id, "huellita", "La mascota original sigue siendo la de inicio")
        XCTAssertEqual(Set(Pet.all.map(\.id)).count, Pet.all.count)
        XCTAssertEqual(Backdrop.all.first?.medalsRequired, 0, "Siempre hay un fondo disponible")
        XCTAssertEqual(Backdrop.all.map(\.medalsRequired), Backdrop.all.map(\.medalsRequired).sorted())
    }

    // MARK: - Mascota y fondo

    func testPetNameAndChoicePersist() {
        let defaults = makeTestDefaults()
        let progress = ProgressStore(defaults: defaults)
        XCTAssertEqual(progress.displayPetName, "Huellita")

        progress.choosePet(Pet.all[2])
        XCTAssertEqual(progress.displayPetName, "Michi", "Sin nombre propio, usa el de la mascota")
        progress.setPetName("  Bolita de nieve gigante y feliz ")

        let reloaded = ProgressStore(defaults: defaults)
        XCTAssertEqual(reloaded.pet.id, "gatito")
        XCTAssertLessThanOrEqual(reloaded.petName.count, Pet.nameMaxLength)
        XCTAssertTrue(reloaded.displayPetName.hasPrefix("Bolita"))

        reloaded.setPetName("   ")
        XCTAssertEqual(reloaded.displayPetName, "Michi")
    }

    func testLockedBackdropCannotBeChosen() {
        let progress = ProgressStore(defaults: makeTestDefaults())
        progress.chooseBackdrop(Backdrop.all.last!)
        XCTAssertEqual(progress.backdrop.id, "cielo")

        for _ in 0..<Backdrop.all[1].medalsRequired { progress.finish(cama) }
        progress.chooseBackdrop(Backdrop.all[1])
        XCTAssertEqual(progress.backdrop.id, Backdrop.all[1].id)
    }

    // MARK: - Contadores

    func testCountersOnlyGoUpAndRepeatedStepCountsOnce() {
        let defaults = makeTestDefaults()
        let progress = ProgressStore(defaults: defaults)
        progress.complete(cama.steps[0])
        progress.complete(cama.steps[0]) // repasar el mismo paso
        progress.complete(cama.steps[1])
        XCTAssertEqual(progress.stepsDone, 2)

        progress.finish(cama)
        progress.complete(cama.steps[0]) // nueva vuelta: vuelve a contar
        progress.finish(cama)

        let reloaded = ProgressStore(defaults: defaults)
        XCTAssertEqual(reloaded.stepsDone, 3)
        XCTAssertEqual(reloaded.timesDone(cama), 2)
        XCTAssertEqual(reloaded.totalRoutinesDone, 2)
    }

    // MARK: - Álbum

    func testAlbumShowsEarnedAndNextGoal() {
        let progress = ProgressStore(defaults: makeTestDefaults())
        for _ in 0..<3 { progress.finish(cama) }
        let album = progress.album(for: [cama])

        let camaStickers = album.filter { $0.id.hasPrefix("rutina.cama.") }
        XCTAssertEqual(camaStickers.map(\.target), [1, 3, 5], "Ganadas 1 y 3, y la siguiente meta 5")
        XCTAssertEqual(camaStickers.filter(\.isEarned).count, 2)
        XCTAssertEqual(camaStickers.last?.progress ?? 0, 0.6, accuracy: 0.001)
        XCTAssertEqual(camaStickers.last?.detail, "5 veces")
    }

    func testEmptyAlbumShowsOnlyFirstGoals() {
        let progress = ProgressStore(defaults: makeTestDefaults())
        let album = progress.album(for: Routine.all)
        XCTAssertTrue(album.allSatisfy { !$0.isEarned })
        XCTAssertEqual(album.count, 2 + Routine.all.count, "Una meta por serie")
    }

    func testFinishingRevealsNewStickers() {
        let progress = ProgressStore(defaults: makeTestDefaults())
        let before = progress.earnedAchievementIDs(for: [cama])
        progress.finish(cama)
        let new = progress.earnedAchievementIDs(for: [cama]).subtracting(before)
        XCTAssertEqual(new, ["total.1", "rutina.cama.1"])
    }

    // MARK: - Ánimo

    func testEncouragementNeverRepeatsTwiceInARow() {
        var generator = SystemRandomNumberGenerator()
        var last: String?
        for _ in 0..<200 {
            let next = Encouragement.pick(from: Encouragement.stepDone, avoiding: last, using: &generator)
            XCTAssertNotEqual(next, last)
            XCTAssertTrue(Encouragement.stepDone.contains(next))
            last = next
        }
        XCTAssertEqual(Encouragement.pick(from: ["Única"], avoiding: "Única"), "Única")
    }
}
