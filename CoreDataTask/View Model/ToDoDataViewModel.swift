import Foundation
import UIKit
import CoreData

class ToDoDataViewModel {
    var toDoItems: [ListEntity] = []
    func fetchToDoItems(completion: @escaping (Result<[ListEntity], Error>) -> Void) {
        let context = CoreDataModel.shared.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ListEntity> = ListEntity.fetchRequest()

        do {
            toDoItems = try context.fetch(fetchRequest)
            completion(.success(toDoItems))
        } catch {
            completion(.failure(error))
        }
    }
    func deleteToDoItem(item: ListEntity, completion: @escaping (Bool) -> Void) {
        let context = CoreDataModel.shared.persistentContainer.viewContext
        context.delete(item)

        do {
            try context.save()
            if let index = toDoItems.firstIndex(where: { $0.id == item.id }) {
                toDoItems.remove(at: index)
            }
            completion(true)
        } catch {
            print("Failed to delete item: \(error)")
            completion(false)
        }
    }
    func updateToDoItem(item: ListEntity, completion: @escaping (Bool) -> Void) {
        let context = CoreDataModel.shared.persistentContainer.viewContext

        do {
            let existingItem = try context.existingObject(with: item.objectID) as! ListEntity
            existingItem.title = item.title
            existingItem.desc = item.desc
            existingItem.date = item.date
            try context.save()
            if let index = toDoItems.firstIndex(where: { $0.id == item.id }) {
                toDoItems[index] = existingItem
            }
            completion(true)
        } catch {
            print("Failed to Update item: \(error)")
            completion(false)
        }
    }
}

