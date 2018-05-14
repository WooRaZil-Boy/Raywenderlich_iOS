public struct RingBuffer<T> {
  
  private var array: [T?] = []
  private var readIndex = 0 //read 포인터
  private var writeIndex = 0 //write 포인터
  
  public init(count: Int) {
    array = Array<T?>(repeating: nil, count: count)
  }
  
  public var first: T? {
    return array[readIndex]
  }
  
  public mutating func write(_ element: T) -> Bool {
    if !isFull {
      array[writeIndex % array.count] = element
      writeIndex += 1
      return true
    } else {
      return false
    }
  }
  
  public mutating func read() -> T? {
    if !isEmpty {
      let element = array[readIndex % array.count]
      readIndex += 1
      return element
    } else {
      return nil
    }
  }
  
  private var availableSpaceForReading: Int {
    return writeIndex - readIndex
  }
  
  public var isEmpty: Bool {
    return availableSpaceForReading == 0
  }
  
  private var availableSpaceForWriting: Int {
    return array.count - availableSpaceForReading
  }
  
  public var isFull: Bool {
    return availableSpaceForWriting == 0
  }
}

extension RingBuffer: CustomStringConvertible {
  
  public var description: String {
    var result = "["
    var index = readIndex
    
    while index != (writeIndex % array.count) {
      
      if let value = array[index] {
        result += "\(value) "
      }
      
      if index == array.count - 1 {
        index = 0
      } else {
        index += 1
      }
    }
    
    result += "]"
    
    return result
  }
}

//링 버퍼는 순환 버퍼라고도 한다. 고정된 크기를 배열을 사용하며, 끝에 제거할 항목이 더 이상 없을 때, 처음부터 다시 접근한다. p.59
//링 버퍼에는 read와 write 두개의 참조가 있다.
//read 포인터는 큐의 앞을 가리킨다. dequeue할 때마다 read 포인터가 가리키는 객체는 하나씩 뒤로 이동한다(삭제하지 않고 포인터만 뒤로 이동).
//write 포인터는 다음 사용 가능한 슬롯을 가리킨다. enqueue할 때마다 write 포인터가 가리키는 객체는 하나씩 뒤로 이동한다.
//write 포인터가 버퍼의 끝에 도달한 상태에서 enqueue를 한다면, write 포인터는 버퍼의 가장 앞으로 이동하게 된다(링, 순환).
//read 포인터와 write 포인터가 같은 위치에 있으면, 큐가 비어 있는 것이다.
//https://github.com/raywenderlich/swift-algorithm-club/tree/master/Ring%20Buffer
