import Mockable
import SwiftData
import Testing
@testable import FlashCards

@MainActor
@Suite("Catalog view models")
struct CatalogViewModelTests {
    private let container: ModelContainer
    private let service = MockCatalogServicing()

    init() throws {
        container = try AppModelContainer.make(inMemory: true)
    }

    private func folder(_ name: String) -> Folder {
        let folder = Folder(name: name, learningLanguage: "en", backLanguage: "ru")
        container.mainContext.insert(folder)
        return folder
    }

    // Catches: moving on the first tap when the pair changes, skipping the warning.
    @Test("A move that changes the pair waits for the warning to be confirmed")
    func moveWaitsForWarning() {
        let season = folder("Season 1")
        let serbian = folder("Serbian")
        given(service).moveCheck(.any, to: .any).willReturn(.allowedAfterWarning)
        given(service).move(.any, to: .any).willReturn()
        let model = MoveFolderViewModel(folder: season, service: service)

        #expect(model.choose(serbian) == false)
        verify(service).move(.any, to: .any).called(.never)

        #expect(model.confirmWarning() == true)
        verify(service).move(.value(season), to: .value(serbian)).called(.once)
    }

    // Catches: deleting the wrong folder, or deleting without a pending confirmation.
    @Test("Confirming a delete deletes the folder that asked, once")
    func confirmDelete() {
        let season = folder("Season 1")
        given(service).delete(.any).willReturn()
        let actions = FolderRowActionsModel(service: service)

        actions.confirmDelete()
        verify(service).delete(.any).called(.never)

        actions.deleting = season
        actions.confirmDelete()
        verify(service).delete(.value(season)).called(.once)
        #expect(actions.deleting == nil)
    }

    // Catches: a failed save closing the form silently (the user would think it was saved).
    @Test("A failed save keeps the form open and shows why")
    func failedSaveKeepsForm() {
        given(service).rename(.any, to: .any).willThrow(CatalogError.emptyName)
        let model = FolderNameViewModel(mode: .rename(folder("Season 1")), service: service)
        model.name = "Pilot"

        #expect(model.save() == false)
        #expect(model.saveError == "A folder needs a name.")
    }
}
