//
//  ContentView.swift
//  My SwiftUI
//
//  Created by youngho on 2021/01/19.
//

import SwiftUI

struct ContentView: View {
  var body: some View {
    VStack {
      Image(systemName: "swift")
        .resizable() //resizable은 Image를 반환하기 때문에 View를 반환하는 다른 modifier와의 순서에 유의해야 한다.
        .frame(width: 100.0, height: 100.0)
        //Attributes Inspector에서 값을 지정해도 코드에 반영된다.
        .padding()
        .background(Color.orange)
        .padding([.leading, .bottom, .trailing])
        //같은 modifiers를 사용하더라도, 순서에 따라 결과가 달라질 수 있다.
      Text("Howdy, world!")
        .fontWeight(.bold)
        .kerning(5.0)
        .padding()
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
