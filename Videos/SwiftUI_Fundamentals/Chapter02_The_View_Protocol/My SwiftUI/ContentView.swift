//
//  ContentView.swift
//  My SwiftUI
//
//  Created by youngho on 2021/01/19.
//

import SwiftUI

struct ContentView: View {
  //View protocol은 유일한 요구사항인 body를 반드시 구현해야 한다.
  var body: some View {
    //definition을 보면, @ViewBuilder라는 property wrapper를 확인할 수 있다.
    //associatedtype 으로 View를 준수하는 type으로 선언해야 한다.
    //SwiftUI 에서 특징을 가진 뷰를 정의할 때 @ViewBuilder를 사용하며, 이를 사용해 Custom Component를 만들 수도 있다.
    //https://velog.io/@budlebee/SwiftUI-ViewBuilder
    
    //some View를 사용하면 Generic과 반대로 반환되는 유형을 유추하고, 컴파일러는 이를 수행할 수 있다.
    //세부 구현사항을 숨기고 View의 인테페이스만 노출할 수 있다. 구체적인 구현은 차후에 변경할 수 있는 유연성을 제공한다.
    //참고: Combine의 eraseToAnyPublisher()
    //https://usinuniverse.bitbucket.io/blog/some.html
    //https://stackoverflow.com/questions/56433665/what-is-the-some-keyword-in-swiftui
    //https://jcsoohwancho.github.io/2019-08-24-Opaque-Type-%EC%82%B4%ED%8E%B4%EB%B3%B4%EA%B8%B0/
    VStack {
      //VStack 없이 Image와 Text를 그대로 사용하면, 각각을 나타내는 2개의 preview가 canvas에 표시된다.
      Image(systemName: "swift")
      Text("Howdy, world!")
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  //PreviewProvider가 반드시 미리보기하는 View의 이름을 따를 필요는 없지만, 보통은 그렇게 해 준다.
  static var previews: some View {
    ContentView()
  }
}
