//
//  CacheStorage.swift
//  WeatherApp
//
//  Created by Vadim Popov on 24.03.2024.
//

import Foundation
import CoreData


class CacheStorage<Key: Codable & Equatable, Value: Codable>: Service {
    
    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CacheStorageModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    required init(_ globals: [String : Any?]) {
    }
    
    public func object(forKey key: Key) -> Value? {
        guard let someObject = someObject(forKey: key) else { return nil }
        
        do {
            guard let someObjectData = someObject.data else { return nil }
            return try JSONDecoder().decode(Value.self, from: someObjectData)
            
        } catch {
            return nil
        }
    }
    
    public func setObject(_ object: Value, forKey key: Key) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "SomeObject", in: context) else {
            return
        }
        
        if let obj = someObject(forKey: key) {
            do {
                obj.data = try JSONEncoder().encode(object)
            } catch {}
            
        } else {
            let obj = SomeObject(entity: entityDescription, insertInto: context)
            
            do {
                obj.key = try JSONEncoder().encode(key)
                obj.data = try JSONEncoder().encode(object)
            } catch {}
        }
        
        trySave()
    }
    
    public func removeObject(forKey key: Key) {
        let keyEncodedData: Data
        do {
            keyEncodedData = try JSONEncoder().encode(key)
        } catch { return }
        
        let fetchRequest: NSFetchRequest<SomeObject> = SomeObject.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "key == %@", keyEncodedData as CVarArg)
        
        let objects: [SomeObject]
        do {
            objects = try context.fetch(fetchRequest)
        } catch { return }
        
        for object in objects {
            context.delete(object)
        }
        
        trySave()
    }
    
    private func someObject(forKey key: Key) -> SomeObject? {
        let keyEncodedData: Data
        do {
            keyEncodedData = try JSONEncoder().encode(key)
        } catch { return nil }
        
        let fetchRequest: NSFetchRequest<SomeObject> = SomeObject.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "key == %@", keyEncodedData as CVarArg)
        
        do {
            return try context.fetch(fetchRequest).first
            
        } catch {
            return nil
        }
    }
    
    private func trySave() {
        if context.hasChanges {
            do {
                try context.save()
                
            } catch {
                context.rollback()
            }
        }
    }
    
}
