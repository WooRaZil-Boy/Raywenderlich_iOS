//
//  ColorUISlider.swift
//  RGBullsEye
//
//  Created by 근성가이 on 2020/10/24.
//  Copyright © 2020 Razeware. All rights reserved.
//

import SwiftUI

struct ColorUISlider: UIViewRepresentable {
  class Coordinator: NSObject {
    var parent: ColorUISlider
    
    init(_ parent: ColorUISlider) {
      self.parent = parent
    }
    
    @objc func updateColorUISlider(_ sender: UISlider) {
      parent.value = Double(sender.value)
    }
  }
  
  var color: UIColor
  @Binding var value: Double
  
  //coordinator가 있다면 반드시 구현해야 한다.
  func makeCoordinator() -> ColorUISlider.Coordinator {
    Coordinator(self)
  }

  //UIViewRepresentable의 필수 구현 메서드
    func makeUIView(context: Context) -> UISlider {
      let slider = UISlider(frame: .zero)
      slider.thumbTintColor = color
      slider.value  = Float(value)
      
      slider.addTarget(context.coordinator, action: #selector(Coordinator.updateColorUISlider(_:)), for: .valueChanged)

      return slider
    }

    func updateUIView(_ uiView: UISlider, context: Context) {
      uiView.value = Float(self.value)
    }
}

struct ColorUISlider_Previews: PreviewProvider {
    static var previews: some View {
        ColorUISlider(color: .red, value: .constant(0.5))
          .previewLayout(.sizeThatFits)

    }
}
