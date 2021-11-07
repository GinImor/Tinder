//
//  RecentMessagesLRUCache.swift
//  Tinder
//
//  Created by Gin Imor on 10/23/21.
//  Copyright © 2021 Brevity. All rights reserved.
//


import Foundation

class RecentMessagesLRUCache {
  
  class Node {
    var value: RecentMessage!
    var prev: Node!
    var next: Node!
    
    init() {}
    
    init(value: RecentMessage) {
      self.value = value
    }
  }
  
  
  private var cache = [String: Node]()
  private var size: Int = 0
  private var capacity: Int
  private let head, tail: Node
  
  init(capacity: Int) {
    self.capacity = capacity
    head = Node()
    tail = Node()
    head.next = tail
    tail.prev = head
  }
  
  func allKeys() -> [String] {
    var result: [String] = []
    var node = head.next!
    while (node !== tail) {
      result.append(node.value.uid)
      node = node.next
    }
    return result
  }
  
  func get(key: String) -> RecentMessage? {
    return cache[key]?.value
  }
  
  func put(value: RecentMessage) {
    let key = value.uid
    if let existingNode = cache[key] {
      // the key does exist, so just update value and move it to head
      existingNode.value?.text = value.text
      if head.next !== existingNode {
        moveToHead(existingNode)
      }
    } else {
      // the key doesn't exist
      let insertNode: Node
      if (size == capacity) {
        // the actual size reaches the max capacity, in order to
        // insert a new key, remove the least recently used key
        insertNode = removeTail()
        insertNode.value = value
      } else {
        insertNode = Node(value: value)
        size += 1
      }
      cache[key] = insertNode
      addToHead(insertNode)
    }
  }
  
  private func addToHead(_ node: Node) {
    node.prev = head
    node.next = head.next
    head.next?.prev = node
    head.next = node
  }
  
  private func removeNode(_ node: Node) {
    node.prev?.next = node.next
    node.next?.prev = node.prev
  }
  
  private func removeTail() -> Node {
    let tailNode = tail.prev!
    cache[tailNode.value.uid] = nil
    removeNode(tailNode)
    return tailNode
  }
  
  private func moveToHead(_ node: Node) {
    removeNode(node)
    addToHead(node)
  }
  
}
