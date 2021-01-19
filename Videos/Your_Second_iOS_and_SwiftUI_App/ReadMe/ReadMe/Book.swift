//
//  Book.swift
//  ReadMe
//
//  Created by youngho on 2021/01/18.
//

import Combine

class Book: Codable, ObservableObject { //state 변경을 위해 struct에서 class로 변경하다.
  //ObservableObject를 준수하면, 해당 class의 인스턴스를 관찰하고 값이 변경될 때 view를 update할 수 있다.
  //cf. @ObservedObject : ObservableObject를 구독하고, 값이 변경될 때마다 view를 update한다.
  //Dictionary의 key가 되기 위해서는 Hashable을 준수해야 한다.
  //Hashable은 Uniquely Identifiable로 생각하면 된다.
  @Published var title: String
  @Published var author: String
  @Published var microReview: String //@Published의 값이 변경될 때 emit하여 View를 update한다.
  @Published var readMe: Bool
  //여기에서는 Book의 모든 변수들의 type이 Hashable을 준수하기 때문에 Book도 Hashable을 준수한다(struct 일 때).
  //⌃ + ⇧ 을 누른 상태로 화살표를 이동하여, 다중 라인을 선택하여 반복되는 구문을 쉽게 교체할 수 있다.
  
  init(title: String = "Title", author: String = "Author", microReview: String = "", readMe: Bool = true) {
    self.title = title
    self.author = author
    self.microReview = microReview
    self.readMe = readMe
  }
}

//class로 변경하면서, Hashable을 준수하기 위한 코드를 추가해줘야 한다.
extension Book: Hashable, Identifiable {
  //Identifiable는 Hashable을 준수한다.
  func hash(into hasher: inout Hasher) {
//    hasher.combine(ObjectIdentifier(self))
    hasher.combine(id) //Identifiable을 준수하면 이와 같이 쓸 수 있다.
  }
}

extension Book: Equatable {
  static func == (lhs: Book, rhs: Book) -> Bool {
    lhs === rhs
  }
}
