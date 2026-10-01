import XCTest
@testable import MeCuidoCore

final class MediaStoreTests: XCTestCase {
    private var directory: URL!
    private var media: MediaStore!

    override func setUp() {
        super.setUp()
        directory = FileManager.default.temporaryDirectory.appendingPathComponent("mecuido-media-\(UUID().uuidString)")
        media = MediaStore(directory: directory)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: directory)
        super.tearDown()
    }

    private let photo = Data([0xFF, 0xD8, 0xFF, 0xE0])

    func testSaveAndDeletePhoto() throws {
        XCTAssertFalse(media.has(.photo, stepID: "mochila.1"))
        try media.save(photo, as: .photo, stepID: "mochila.1")
        XCTAssertTrue(media.has(.photo, stepID: "mochila.1"))
        XCTAssertFalse(media.has(.voice, stepID: "mochila.1"))
        XCTAssertEqual(try Data(contentsOf: media.url(for: .photo, stepID: "mochila.1")), photo)

        media.delete(.photo, stepID: "mochila.1")
        XCTAssertFalse(media.has(.photo, stepID: "mochila.1"))
    }

    func testRevisionChangesOnEveryWrite() throws {
        let start = media.revision
        try media.save(photo, as: .photo, stepID: "a.1")
        media.delete(.photo, stepID: "a.1")
        XCTAssertEqual(media.revision, start + 2)
    }

    func testAdoptMovesFileAndReplacesPrevious() throws {
        try media.save(Data("vieja".utf8), as: .voice, stepID: "cama.2")
        let temp = FileManager.default.temporaryDirectory.appendingPathComponent("grabacion-\(UUID().uuidString).m4a")
        try Data("nueva".utf8).write(to: temp)

        try media.adopt(fileAt: temp, as: .voice, stepID: "cama.2")
        XCTAssertFalse(FileManager.default.fileExists(atPath: temp.path))
        XCTAssertEqual(try Data(contentsOf: media.url(for: .voice, stepID: "cama.2")), Data("nueva".utf8))
    }

    func testFileNamesStayInsideDirectory() {
        let name = MediaStore.fileName(for: .photo, stepID: "../../etc/Passwd")
        XCTAssertFalse(name.contains("/"))
        XCTAssertFalse(name.contains(".."))
        XCTAssertEqual(media.url(for: .photo, stepID: "../x").deletingLastPathComponent().standardizedFileURL.path,
                       directory.standardizedFileURL.path)
        XCTAssertEqual(MediaStore.fileName(for: .voice, stepID: "custom-ab12.9f3e"), "custom-ab12.9f3e.m4a")
    }

    func testDeleteAllRemovesPhotosAndVoices() throws {
        try media.save(photo, as: .photo, stepID: "r.1")
        try media.save(photo, as: .voice, stepID: "r.1")
        try media.save(photo, as: .photo, stepID: "r.2")
        try media.save(photo, as: .photo, stepID: "otra.1")

        media.deleteAll(stepIDs: ["r.1", "r.2"])
        XCTAssertFalse(media.has(.photo, stepID: "r.1"))
        XCTAssertFalse(media.has(.voice, stepID: "r.1"))
        XCTAssertFalse(media.has(.photo, stepID: "r.2"))
        XCTAssertTrue(media.has(.photo, stepID: "otra.1"))
    }

    func testCopyMediaFollowsStepOrder() throws {
        let original = Routine.all[1]
        try media.save(photo, as: .photo, stepID: original.steps[0].id)
        try media.save(Data("voz".utf8), as: .voice, stepID: original.steps[2].id)

        let store = RoutineStore(fileURL: directory.appendingPathComponent("rutinas.json"))
        let copy = store.duplicate(original)
        media.copyMedia(from: original.steps, to: copy.steps)

        XCTAssertTrue(media.has(.photo, stepID: copy.steps[0].id))
        XCTAssertFalse(media.has(.photo, stepID: copy.steps[1].id))
        XCTAssertTrue(media.has(.voice, stepID: copy.steps[2].id))
        XCTAssertTrue(media.has(.photo, stepID: original.steps[0].id), "El original no se toca")
    }
}
