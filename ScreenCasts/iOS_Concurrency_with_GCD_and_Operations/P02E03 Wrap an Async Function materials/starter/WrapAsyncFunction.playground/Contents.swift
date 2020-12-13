// Copyright (c) 2020 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

import UIKit
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
//: # Wrapping an Asynchronous Function for DispatchGroup
//: There are lots of asynchronous APIs that don't have group parameters. What can you do with them, so the group knows when they *really* finish?
//:
//: Remember from Part 1 the `slowAdd` function you wrapped as an asynchronous function?
let numberArray = [(0,1), (2,3), (4,5), (6,7), (8,9)]

func asyncAdd(_ input: (Int, Int),
  runQueue: DispatchQueue = DispatchQueue.global(qos: .userInitiated),
  completionQueue: DispatchQueue = DispatchQueue.main,
  completion: @escaping (Result<Int, SlowAddError>) -> ()) {
  runQueue.async {
    let result = slowAddPlus(input)
    completionQueue.async { completion(result) }
  }
}
//: Wrap `asyncAdd` function
// TODO: Create asyncAdd_Group





//print("\n=== Group of async tasks ===\n")
let wrappedGroup = DispatchGroup()

for pair in numberArray {
  // TODO: use the new function here to calculate the sums of the array

}

// TODO: Notify of completion


