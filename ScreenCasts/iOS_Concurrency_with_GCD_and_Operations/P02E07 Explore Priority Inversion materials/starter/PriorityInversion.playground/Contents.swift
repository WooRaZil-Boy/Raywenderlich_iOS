// Copyright (c) 2020 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

import Foundation
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

// TODO: Create queues with high and low qos values

let medium = DispatchQueue.global(qos: .userInitiated)

// TODO: Create semaphore with value 1


// TODO: Dispatch task that sleeps before calling semaphore.wait()








for i in 1 ... 10 {
  medium.async {
    print("Running medium task \(i)")
    let waitTime = Double(Int.random(in: 0..<7))
    Thread.sleep(forTimeInterval: waitTime)
  }
}

// TODO: Dispatch task that takes a long time






