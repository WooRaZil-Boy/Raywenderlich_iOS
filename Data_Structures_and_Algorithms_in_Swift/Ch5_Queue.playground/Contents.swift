//: Playground - noun: a place where people can play

import UIKit

var queue = QueueArray<Int>()

var queueBuffer = QueueRingBuffer<Int>(count: 5)
queueBuffer.enqueue(2)
queueBuffer.enqueue(3)

queueBuffer.enqueue(5)
print(queueBuffer.description)
queueBuffer.dequeue()
print(queueBuffer.description)
queueBuffer.dequeue()
print(queueBuffer.description)

var queueBuffer2 = queueBuffer
queueBuffer2.enqueue(6)
print("1: \(queueBuffer.description)")
print("2: \(queueBuffer2.description)")
//print(queueBuffer)
//print(queueBuffer.peek)

//
//queue.enqueue(1)
//queue.enqueue(3)
//queue.enqueue(4)
//
//var queue2 = queue
//
//print(queue)
//print(queue.description)
//
//queue.contains(5)
//queue.contains(3)
//queue.contains(1)
//
//queue2.enqueue(5)
//
////let array = [Int]
////array.make
//
//for person in queue {
//  print(person)
//}
//
//print(queue)
//print(queue2)
