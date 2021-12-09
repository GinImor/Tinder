//
//  CoreDataStack.swift
//  Tinder
//
//  Created by Gin Imor on 12/2/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import Foundation
import CoreData

let coreDataStack = CoreDataStack()
let tempDataStack = TempCoreDataStack()

class CoreDataStack {
  
  fileprivate static let modelName = "Model"
  // there are two core data stack, if they both call the persistent container's initializer with
  // only model name, then there will be two loading of managed object model, causing ambiguous
  // managed object problems
  fileprivate static let model: NSManagedObjectModel = {
    let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd")!
    return NSManagedObjectModel(contentsOf: modelURL)!
  }()
  
  lazy var mainContext: NSManagedObjectContext = {
    return self.storeContainer.viewContext
  }()
  
  lazy var storeContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(
      name: CoreDataStack.modelName,
      managedObjectModel: CoreDataStack.model)
    container.loadPersistentStores { (storeDescription, error) in
      if let error = error {
        fatalError("Unresolved error \(error), \(error.localizedDescription)")
      }
    }
    return container
  }()
  
  fileprivate init() { }
}

extension CoreDataStack {
  
  func saveContext () {
    guard mainContext.hasChanges else { return }
    
    do {
      try mainContext.save()
    } catch let nserror as NSError {
      fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
    }
  }
}


class TempCoreDataStack: CoreDataStack {
  
  override fileprivate init() {
    super.init()
    
    let persistentStoreDescription = NSPersistentStoreDescription()
    persistentStoreDescription.type = NSInMemoryStoreType
    
    let container = NSPersistentContainer(
      name: CoreDataStack.modelName,
      managedObjectModel: CoreDataStack.model)
    container.persistentStoreDescriptions = [persistentStoreDescription]
    container.loadPersistentStores { (_, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    }
    // self.storeContainer is lazy, this make the lazy property doesn't get its original initialization
    self.storeContainer = container
  }
  
  func deleteAll() {
    let deleteMatchUserRequest = MatchUser.fetchRequest()
    do {
      let matchUsers = try tempDataStack.mainContext.fetch(deleteMatchUserRequest)
      for matchUser in matchUsers {
        tempDataStack.mainContext.delete(matchUser)
      }
      tempDataStack.saveContext()
    } catch {
      print("delete match users error ", error)
    }
    let deleteRecentMessageRequest = Message.fetchRequest()
    do {
      let recentMessages = try tempDataStack.mainContext.fetch(deleteRecentMessageRequest)
      for recentMessage in recentMessages {
        tempDataStack.mainContext.delete(recentMessage)
      }
      tempDataStack.saveContext()
    } catch {
      print("delete recent messages error ", error)
    }
  }

}
