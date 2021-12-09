//
//  NSBatchInsertRequest+execute.swift
//  Tinder
//
//  Created by Gin Imor on 12/5/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import CoreData

extension NSBatchInsertRequest {
  
  func executeRequestBy(context: NSManagedObjectContext) {
    resultType = NSBatchInsertRequestResultType.objectIDs
    let result = try? context.execute(self) as? NSBatchInsertResult
    if let objectIDs = result?.result as? [NSManagedObjectID], !objectIDs.isEmpty {
      let save = [NSInsertedObjectsKey: objectIDs]
      NSManagedObjectContext.mergeChanges(fromRemoteContextSave: save, into: [context])
    }
  }
}
