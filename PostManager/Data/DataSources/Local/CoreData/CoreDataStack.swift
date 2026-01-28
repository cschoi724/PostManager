//
//  CoreDataStack.swift
//  PostManager
//
//  Core Data 기반 로컬 저장소 스택
//

import Foundation
import CoreData

final class CoreDataStack {

    enum StoreType {
        case persistent
        case inMemory
    }

    private let container: NSPersistentContainer

    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    init(
        name: String = "PostManager",
        storeType: StoreType = .persistent
    ) {
        container = NSPersistentContainer(name: name)

        if storeType == .inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }

        container.loadPersistentStores { _, error in
            if let error {
                assertionFailure("코어데이터 스토어 로드 실패: \(error)")
            }
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.automaticallyMergesChangesFromParent = true
        return context
    }

    func save(context: NSManagedObjectContext) throws {
        guard context.hasChanges else { return }
        try context.save()
    }

    func saveContext() {
        let context = container.viewContext
        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch {
            assertionFailure("코어데이터 저장 실패: \(error)")
        }
    }
}
