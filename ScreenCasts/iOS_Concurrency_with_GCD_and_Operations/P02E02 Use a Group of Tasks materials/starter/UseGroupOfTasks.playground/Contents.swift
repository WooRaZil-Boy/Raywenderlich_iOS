// Copyright (c) 2020 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

import UIKit
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
//: # Use Group of Tasks
let userQueue = DispatchQueue.global(qos: .userInitiated)
let numberArray = [(0,1), (2,3), (4,5), (6,7), (8,9)]

//: ## Creating a group
print("=== Group of sync tasks ===\n")
// TODO: Create slowAddGroup

//: ## Dispatching to a group
// TODO: Loop to add slowAdd tasks to group



//: ## Notification of group completion
//: Will be called only when every task in the dispatch group has completed
let mainQueue = DispatchQueue.main
// TODO: Call notify method





