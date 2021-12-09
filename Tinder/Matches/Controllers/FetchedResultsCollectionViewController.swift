//
//  FetchedResultsCollectionViewController.swift
//  Tinder
//
//  Created by Gin Imor on 12/6/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit
import CoreData

class FetchedResultsCollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate {
  
  private var ops: [BlockOperation] = []
  
  deinit {
    for o in ops { o.cancel() }
    ops.removeAll()
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    switch type {
    case .insert:
      ops.append(BlockOperation(block: { [weak self] in
        self?.collectionView.insertItems(at: [newIndexPath!])
      }))
    case .delete:
      ops.append(BlockOperation(block: { [weak self] in
        self?.collectionView.deleteItems(at: [indexPath!])
      }))
    case .update:
      ops.append(BlockOperation(block: { [weak self] in
        self?.collectionView.reloadItems(at: [indexPath!])
      }))
    case .move:
      ops.append(BlockOperation(block: { [weak self] in
        self?.collectionView.moveItem(at: indexPath!, to: newIndexPath!)
      }))
    @unknown default:
      break
    }
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    collectionView.performBatchUpdates({ () -> Void in
      for op: BlockOperation in self.ops { op.start() }
    }, completion: { (finished) -> Void in self.ops.removeAll() })
  }

}
