//
//  InboxMessage+Additions.swift
//  BlossomApp
//
//  Created by nim on 30/7/2564 BE.
//

import Foundation
import CoreData

private class InboxMessageHelper: NSObject {
    
    static let shared: InboxMessageHelper = InboxMessageHelper()
    
    let persistentContainer: NSPersistentContainer
    let fetchedResultsController: NSFetchedResultsController<InboxMessage>

    private override init() {
        let persistentContainer = NSPersistentContainer(name: "BlossomApp")
        persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        self.persistentContainer = persistentContainer
        
        let request = NSFetchRequest<InboxMessage>(entityName: "InboxMessage")
        let sort = NSSortDescriptor(key: "createdAt", ascending: false)
        request.sortDescriptors = [sort]
        request.fetchBatchSize = 20

        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: persistentContainer.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        self.fetchedResultsController = fetchedResultsController
        
        super.init()
        fetchedResultsController.delegate = self
    }
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                debugPrint("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

extension InboxMessageHelper: NSFetchedResultsControllerDelegate {
    
}

extension InboxMessage {
    
    static func addNewInbox(identifier: String?, message: String? = "", deeplink: String? = "") {
        
        let context = InboxMessageHelper.shared.persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "InboxMessage", in: context) else {
            return
        }
        
        let newMessage = InboxMessage(entity: entity, insertInto: context)
        newMessage.setValue(message, forKey: "message")
        newMessage.setValue(identifier ?? "\(Date().timeIntervalSince1970*1000)", forKey: "messageID")
        newMessage.setValue(deeplink, forKey: "deeplink")
        newMessage.setValue(Date(), forKey: "createdAt")
        InboxMessageHelper.shared.saveContext()
        
    }
    
    static func getMessages() {
        try? InboxMessageHelper.shared.fetchedResultsController.performFetch()
    }
    
    static func numberOfSections() -> Int {
        return InboxMessageHelper.shared.fetchedResultsController.sections?.count ?? 0
    }

    static func numberOfRowsInSection(_ sectionIndex: Int) -> Int {
        guard let sections = InboxMessageHelper.shared.fetchedResultsController.sections,
              sectionIndex < sections.count else {
            return 0
        }
        return sections[sectionIndex].numberOfObjects
    }
    
    static func objectAtIndexPath(_ indexPath: IndexPath) -> InboxMessage {
        return InboxMessageHelper.shared.fetchedResultsController.object(at: indexPath)
    }
    
}
