// Copyright (c) 2020 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

import UIKit
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
//: # DispatchGroup Waiting
//: You can make the current thread wait for a dispatch group to complete.
//:
//: __DANGER__ This is a synchronous call on the __current__ queue, so will block it. You cannot have anything in the group that needs to use the current queue, otherwise you'll deadlock.
let group = DispatchGroup()
let queue = DispatchQueue.global(qos: .userInitiated)

queue.async(group: group) {
  print("Start task 1")
  // DONE: Sleep for 4 seconds
  sleep(4)
  print("End task 1")
}

queue.async(group: group) {
  print("Start task 2")
  // DONE: Sleep for 1 second
  sleep(1)
  print("End task 2")
}

group.notify(queue: DispatchQueue.global()) {
  // DONE: Announce completion, stop playground page
  print("All tasks completed at last!")
  PlaygroundPage.current.finishExecution()
}
//: The tasks continue to run, even if the wait times out.
// DONE: Wait for 5 seconds, then for 3 seconds
if group.wait(timeout: .now() + 3) == .timedOut {
  print("I got tired of waiting.")
} else {
  print("All the tasks have completed.")
}
