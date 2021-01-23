//
//  ContentView.swift
//  AlignmentGuides
//
//  Created by youngho on 2021/01/23.
//

import SwiftUI

struct ContentView: View {
  var body: some View {
    VStack(alignment: .trailing) {
      LabelView(title: "Hello", color: .green)
//        .alignmentGuide(.leading) { _ in 30 }
//        .alignmentGuide(HorizontalAlignment.center) { _ in 30 }
        .alignmentGuide(.trailing) { _ in 90 }
      LabelView(title: "World", color: .yellow)
//        .alignmentGuide(.leading) { _ in 90 }
//        .alignmentGuide(HorizontalAlignment.center) { _ in 30 }
        .alignmentGuide(.trailing) { _ in 30 }
      LabelView(title: "There", color: .red)
    }
  }
}

//https://swiftui-lab.com/alignment-guides/

struct LabelView: View {
  let title: String
  let color: Color
  
  var body: some View {
    Text(title).foregroundColor(.black)
      .padding(20)
      .frame(width: 200, height: 50)
      .background(RoundedRectangle(cornerRadius: 8).fill(color).opacity(0.5))
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
