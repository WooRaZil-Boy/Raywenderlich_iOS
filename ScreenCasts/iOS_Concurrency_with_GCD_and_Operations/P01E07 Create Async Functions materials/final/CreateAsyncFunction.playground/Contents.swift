// Copyright (c) 2020 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

import UIKit
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
//: # Create Asynchronous Functions
//:
//: Global queues:
let userQueue = DispatchQueue.global(qos: .userInitiated)
let defaultQueue = DispatchQueue.global()
//: A slow synchronous function:
func slowAdd(_ input: (Int, Int)) -> Int {
  sleep(1)
  return input.0 + input.1
}
//: To use it only once, keep it simple:
// DONE: Dispatch slowAdd to userQueue
userQueue.async {
  let result = slowAdd((1,2))
  result
}
//: You'll modify `slowAdd` to return a `Result` that's either an `Int`, or this specific error type, `Slow-add-error`:
enum SlowAddError: Error {
  case notEnoughFingers
}
//: Define `slowAddPlus` to return `Result` instead of `Int`.
//: Flip a coin to decide whether to return success or failure.
// DONE
func slowAddPlus(_ input: (Int, Int)) -> Result<Int, SlowAddError> {
  sleep(1)
  return Bool.random() ? .success(input.0 + input.1) : .failure(.notEnoughFingers)
}
//: Check `slowAddPlus` works:
// DONE: Dispatch slowAddPlus on userQueue
userQueue.async {
  let result = slowAddPlus((1,2))
  result
}

sleep(3)
// Comment out the next line before running the Reusable task exercise.
//PlaygroundPage.current.finishExecution()
//: ### 2. Reusable task
//: Wrap the `async` dispatch as an asynchronous function, with arguments for the input, queues and completion handler, and default values for the two queues.
//:
//: __Note:__ In an app, you would return to the main queue, but that doesn't work in playgrounds.
// DONE: Create asyncAdd function
func asyncAdd(_ input: (Int, Int),
  runQueue: DispatchQueue = DispatchQueue.global(qos: .userInitiated),
  completionQueue: DispatchQueue = DispatchQueue.main,
  completion: @escaping (Result<Int, SlowAddError>) -> ()) {
  runQueue.async {
    let result = slowAddPlus(input)
    completionQueue.async {
      completion(result)
    }
  }
}
//: Call `asyncAdd` with default queues. The completion handler
//: is in a trailing closure, and uses a `switch` block:
// DONE
asyncAdd((1,2)) { result in
  switch result {
  case let .success(sum):
    print(sum)
  case let .failure(error):
    print(error)
  }
  PlaygroundPage.current.finishExecution()
}
