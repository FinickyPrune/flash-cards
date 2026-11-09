import Foundation
import Observation

/// Home: the root folders' actions, creating a root folder, and Import CSV without a folder yet.
@MainActor
@Observable
final class HomeViewModel {
    var isCreatingFolder = false
    var isPickingCSVFile = false
    /// The open CSV import preview.
    var csvImport: CSVImportViewModel?
    let rowActions: FolderRowActionsModel
    private let dependencies: AppDependencies

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        rowActions = FolderRowActionsModel(dependencies: dependencies)
    }

    /// Home's subtitle count: what Play would take today across all root folders.
    static func dueToday(in roots: [Folder], at now: Date) -> Int {
        roots.reduce(0) { $0 + $1.dueCount(at: now) }
    }

    func newRootFolderModel() -> NewRootFolderViewModel {
        NewRootFolderViewModel(service: dependencies.catalogService)
    }

    /// Import CSV on Home: the file importer, or the UI tests' file.
    func startCSVImport() {
        if let file = LaunchOptions.csvFile {
            importCSV(from: file)
        } else {
            isPickingCSVFile = true
        }
    }

    /// `url` is nil when the file importer failed. The preview starts without a folder.
    func importCSV(from url: URL?) {
        csvImport = CSVImportViewModel(url: url, folder: nil, dependencies: dependencies)
    }

    /// Every pushed folder screen, at any depth: Home owns the navigation stack.
    func folderModel(for folder: Folder) -> FolderViewModel {
        FolderViewModel(folder: folder, dependencies: dependencies)
    }
}
