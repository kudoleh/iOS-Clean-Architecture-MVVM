import CoreData

enum CoreDataStorageError: Error {
    case readError(Error)
    case saveError(Error)
    case deleteError(Error)
}

final class CoreDataStorage {

    static let shared = CoreDataStorage()
    
    // MARK: - Core Data stack
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataStorage")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                // TODO: - Log to Crashlytics
                assertionFailure("CoreDataStorage Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // TODO: - Log to Crashlytics
                assertionFailure("CoreDataStorage Unresolved error \(error), \((error as NSError).userInfo)")
            }
        }
    }

    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }
}
