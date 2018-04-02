import Foundation

public func example(of description: String, action: () -> Void) {
  print("\n--- Example of:", description, "---")
  action()
} //캡슐화 메서드
//단순히 Example of를 출력하고 클로저를 실행한다.
