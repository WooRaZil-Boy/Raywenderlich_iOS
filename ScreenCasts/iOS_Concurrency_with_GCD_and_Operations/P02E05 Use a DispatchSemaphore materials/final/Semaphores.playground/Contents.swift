// Copyright (c) 2020 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

import UIKit
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
//: # DispatchSemaphore
let group = DispatchGroup()
let queue = DispatchQueue.global(qos: .userInteractive)
let semaphore = DispatchSemaphore(value: 1)

// Simulate downloading group of images
//for i in 1...10 {
//  queue.async(group: group) {
//    semaphore.wait()
//    defer { semaphore.signal() }
//
//    print("Downloading image \(i)")
//
//    // Simulate a network wait
//    Thread.sleep(forTimeInterval: 3)
//
//    print("Image \(i) downloaded")
//  }
//}

// Really download group of images
let base = "https://wolverine.raywenderlich.com/books/con/image-from-rawpixel-id-"
let ids = [466881, 466910, 466925, 466931, 466978, 467028, 467032, 467042, 467052]
var images: [UIImage] = []

// DONE: Add semaphore argument to dataTask_Group
func dataTask_Group_Semaphore(with url: URL,
  group: DispatchGroup, semaphore: DispatchSemaphore,
  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
  semaphore.wait()
  group.enter()
  URLSession.shared.dataTask(with: url) { data, response, error in
    defer {
      group.leave()
      semaphore.signal()
    }
    completionHandler(data, response, error)
  }.resume()
}

for id in ids {
  guard let url = URL(string: "\(base)\(id)-jpeg.jpg") else { continue }
  // DONE: Call dataTask_Group_Semaphore
  dataTask_Group_Semaphore(with: url, group: group, semaphore: semaphore) {
    data, _, error in
    if error == nil, let data = data, let image = UIImage(data: data) {
      images.append(image)
    }
  }
}

group.notify(queue: queue) {
  print("All done!")
  images[0]
  PlaygroundPage.current.finishExecution()
}
