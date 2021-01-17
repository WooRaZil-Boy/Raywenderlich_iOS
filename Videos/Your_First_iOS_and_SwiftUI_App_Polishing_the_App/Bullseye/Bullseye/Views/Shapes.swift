//
//  Shapes.swift
//  Bullseye
//
//  Created by youngho on 2021/01/17.
//

import SwiftUI

struct Shapes: View {
  @State private var wideShapes = true
  
  var body: some View {
    VStack {
      if !wideShapes {
        Circle()
  //        .inset(by: 10.0) //양 방향으로 inset이 들어가기 때문에 절반을 지정해준다.
  //        .stroke(Color.blue, lineWidth: 20.0)
          .strokeBorder(Color.blue, lineWidth: 20.0) //위의 Modifier를 합친 것과 같다.
          .frame(width: 200, height: 100)
          .transition(.opacity)
      }
      RoundedRectangle(cornerRadius: 20.0)
        .fill(Color.blue)
        .frame(width: wideShapes ? 200 : 100, height: 100)
      Capsule()
        .fill(Color.blue)
        .frame(width: wideShapes ? 200 : 100, height: 100)
      Ellipse()
        .fill(Color.blue)
        .frame(width: wideShapes ? 200 : 100, height: 100)
      Button(action: {
        withAnimation { //각각의 shape에 적용할 필요없이, 해당 변경과 함께 모든 shape의 애니메이션이 적용된다.
          wideShapes.toggle()
        }
      }, label: {
        Text("Animate!")
      })
    }
      .background(Color.green)
  }
}

struct Shapes_Previews: PreviewProvider {
  static var previews: some View {
    Shapes()
  }
}
