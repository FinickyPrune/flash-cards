import Foundation
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

        #expect(model.confirmWarning(for: serbian) == true)
        verify(service).move(.value(season), to: .value(serbian)).called(.once)
    }

    // Catches: deleting the wrong folder, or leaving the dialog pointing at a deleted folder.
    @Test("Confirming a delete deletes that folder once and closes the dialog")
    func confirmDelete() {
        let season = folder("Season 1")
        given(service).delete(.any).willReturn()
        let actions = FolderRowActionsModel(dependencies: AppDependencies(
            catalogService: service,
            cardService: MockCardServicing(),
            reviewService: MockReviewServicing()
        ))
        actions.deleting = season

        actions.confirmDelete(season)

        verify(service).delete(.value(season)).called(.once)
        #expect(actions.deleting == nil)
    }

    // Catches: counting only the first root, or only the roots' own cards and not their subfolders'.
    @Test("Home's due total sums the root folders' subtrees")
    func homeDueTotal() {
        let english = folder("English")
        let serbian = folder("Serbian")
        let season = Folder(name: "Season 1", parent: english)
        for (front, folder) in [("run", english), ("see", season), ("kuća", serbian)] {
            container.mainContext.insert(Card(front: front, back: "x", backSource: "custom", folder: folder))
        }

        #expect(HomeViewModel.dueToday(in: [english, serbian], at: .now) == 3)
    }

    // Catches: the two form modes swapped, so a new subfolder renames its parent instead.
    @Test("The new subfolder form creates the folder under its parent")
    func newSubfolder() {
        let show = folder("Breaking Bad")
        given(service).createSubfolder(name: .any, in: .any).willReturn(folder("Pilot"))
        let model = FolderNameViewModel(mode: .newSubfolder(in: show), service: service)
        model.name = "Pilot"

        #expect(model.save() == true)
        verify(service).createSubfolder(name: .value("Pilot"), in: .value(show)).called(.once)
    }

    // Catches: a failed save closing the form silently (the user would think it was saved).
    @Test("A failed save keeps the form open and shows an error")
    func failedSaveKeepsForm() {
        given(service).rename(.any, to: .any).willThrow(CocoaError(.fileWriteOutOfSpace))
        let model = FolderNameViewModel(mode: .rename(folder("Season 1")), service: service)
        model.name = "Pilot"

        #expect(model.save() == false)
        #expect(model.saveError != nil)
    }

    // Catches: saving the shown palette while "same as parent" is on (the subfolder would stop
    // following), or a picked swatch not turning that off.
    @Test("Appearance saves nil while following the parent and the picked palette otherwise")
    func appearanceSave() {
        let english = Folder(name: "English", learningLanguage: "en", backLanguage: "ru", palette: .lilac)
        let season = Folder(name: "Season 1", parent: english)
        container.mainContext.insert(english)
        given(service).setPalette(.any, of: .any).willReturn()
        let model = AppearanceViewModel(folder: season, service: service)

        #expect(model.isSameAsParent)
        #expect(model.save())
        verify(service).setPalette(.value(nil), of: .value(season)).called(.once)

        model.pick(.rose)
        #expect(!model.isSameAsParent)
        #expect(model.save())
        verify(service).setPalette(.value(.rose), of: .value(season)).called(.once)

        // Back to following: the preview shows the parent's palette again.
        model.isSameAsParent = true
        #expect(model.selection == .lilac)
    }

    // Catches: the form ignoring the service's default, or creating with a fixed palette instead
    // of the one picked.
    @Test("The new folder form starts on the offered palette and creates with the picked one")
    func newRootFolderPalette() {
        given(service).paletteForNewRoot().willReturn(.aurora)
        given(service).createRootFolder(name: .any, learningLanguage: .any, backLanguage: .any, palette: .any)
            .willReturn(folder("English"))
        let model = NewRootFolderViewModel(service: service)
        model.name = "English"

        #expect(model.palette == .aurora)
        model.palette = .rose
        #expect(model.create())
        verify(service).createRootFolder(name: .any, learningLanguage: .any, backLanguage: .any, palette: .value(.rose))
            .called(.once)
    }
}
