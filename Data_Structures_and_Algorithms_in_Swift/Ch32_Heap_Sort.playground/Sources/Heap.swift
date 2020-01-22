// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

public struct Heap<Element: Equatable> {
  
  public var elements: [Element] = []
  public let sort: (Element, Element) -> Bool
  
  public init(sort: @escaping (Element, Element) -> Bool, elements: [Element] = []) {
    self.sort = sort
    self.elements = elements
    
    if !elements.isEmpty {
      for i in stride(from: elements.count / 2 - 1, through: 0, by: -1) {
        siftDown(from: i, upTo: elements.count)
      }
    }
  }
  
  public var isEmpty: Bool {
    elements.isEmpty
  }
  
  public var count: Int {
    elements.count
  }
  
  public func peek() -> Element? {
    elements.first
  }
  
  public func leftChildIndex(ofParentAt index: Int) -> Int {
    (2 * index) + 1
  }
  
  public func rightChildIndex(ofParentAt index: Int) -> Int {
    (2 * index) + 2
  }
  
  public func parentIndex(ofChildAt index: Int) -> Int {
    (index - 1) / 2
  }
  
  public mutating func remove() -> Element? {
    guard !isEmpty else {
      return nil
    }
    elements.swapAt(0, count - 1)
    defer {
      siftDown(from: 0, upTo: elements.count)
    }
    return elements.removeLast()
  }
  
  public mutating func siftDown(from index: Int, upTo size: Int) {
    var parent = index
    while true {
      let left = leftChildIndex(ofParentAt: parent)
      let right = rightChildIndex(ofParentAt: parent)
      var candidate = parent
      if left < size && sort(elements[left], elements[candidate]) {
        candidate = left
      }
      if right < size && sort(elements[right], elements[candidate]) {
        candidate = right
      }
      if candidate == parent {
        return
      }
      elements.swapAt(parent, candidate)
      parent = candidate
    }
  }
  
  public mutating func insert(_ element: Element) {
    elements.append(element)
    siftUp(from: elements.count - 1)
  }
  
  public mutating func siftUp(from index: Int) {
    var child = index
    var parent = parentIndex(ofChildAt: child)
    while child > 0 && sort(elements[child], elements[parent]) {
      elements.swapAt(child, parent)
      child = parent
      parent = parentIndex(ofChildAt: child)
    }
  }
  
  public mutating func remove(at index: Int) -> Element? {
    guard index < elements.count else {
      return nil // 1
    }
    if index == elements.count - 1 {
      return elements.removeLast() // 2
    } else {
      elements.swapAt(index, elements.count - 1) // 3
      defer {
        siftDown(from: index, upTo: elements.count) // 5
        siftUp(from: index)
      }
      return elements.removeLast() // 4
    }
  }
  
  public func index(of element: Element, startingAt i: Int) -> Int? {
    if i >= count {
      return nil
    }
    if sort(element, elements[i]) {
      return nil
    }
    if element == elements[i] {
      return i
    }
    if let j = index(of: element, startingAt: leftChildIndex(ofParentAt: i)) {
      return j
    }
    if let j = index(of: element, startingAt: rightChildIndex(ofParentAt: i)) {
      return j
    }
    return nil
  }
}
