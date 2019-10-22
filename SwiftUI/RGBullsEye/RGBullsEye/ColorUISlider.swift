//
//  ColorUISlider.swift
//  RGBullsEye
//
//  Created by 근성가이 on 2019/10/22.
//  Copyright © 2019 근성가이. All rights reserved.
//

import SwiftUI
import UIKit //추가

struct ColorUISlider: UIViewRepresentable {
    //UIViewRepresentable 프로토콜을 구현한다.
    //UIViewControllerRepresentable 처럼 make와 update를 구현해야 한다.
    
    class Coordinator: NSObject {
        //SwiftUI View인 ColorUISlider의 데이터와 UIKit의 UISlider 데이터가
        //동기화되도록 하는 coordinator
        var value: Binding<Double>
        //@State 변수 값에 대한 참조를 받기 때문에 @Binding
        
        init(value: Binding<Double>) { //초기화 할 때 Binding 한다.
            self.value = value
        }
        
        @objc func valueChanged(_ sender: UISlider) {
            //해당 Coordinator가 UISlider 이벤트의 target이 된다.
            self.value.wrappedValue = Double(sender.value)
        }
    }
    //UIViewRepresentable 프로토콜에서 makeCoordinator()를 구현 한다.
    
    var color: UIColor //SwiftUI의 Color는 View이고, UIColor는 아니다.
    //UIColor로 SwiftUI의 Color를 생성할 수 있다.
    @Binding var value: Double
    //UISlider(Float)와 SwiftUI의 Slider(Double) 자료형 타입이 다르다.
    //@State를 참조하는 @Binding
    
    func makeCoordinator() -> ColorUISlider.Coordinator {
        Coordinator(value: $value)
        //ColorUISlider의 value에 바인딩 된 Coordinator가 만들어진다.
        //ContentView의 색상 값 중 하나에 바인딩 된다.
        //Coordinator를 사용해 UIKit 클래스가 SwiftUI의 값을 얻는다.
    }
    
    func makeUIView(context: Context) -> UISlider {
        let slider = UISlider(frame: .zero)
        slider.thumbTintColor = color
        //thumbTintColor는 UISlider에만 있다. SwiftUI의 Slider에는 없다.
        slider.value = Float(value)
        //UISlider(Float)와 SwiftUI의 Slider(Double) 자료형 타입이 다르다.
        
        //이 외에도 minimumTrackTintColor, maximumTrackTintColor 등의 속성이 있다.
        
        slider.addTarget(context.coordinator, action: #selector(Coordinator.valueChanged(_:)), for: .valueChanged)
        //UIKit의 addTarget(_:action:for:)를 사용하여,
        //UISlider을 Coordinator.valueChanged(_:)에 연결한다.
        //Coordinator.valueChanged(_:) 는 UIKit의 UISlider에 들어오는 데이터로
        //SwiftUI View인 ColorUISlider의 값을 업데이트 한다.
        
        return slider
    }
    
    func updateUIView(_ view: UISlider, context: Context) {
        view.value = Float(self.value)
        //UISlider(Float)와 SwiftUI의 Slider(Double) 자료형 타입이 다르다.
    }
}

struct ColorUISlider_Previews: PreviewProvider {
    static var previews: some View {
        ColorUISlider(color: .red, value: .constant(0.5))
    }
}

//Conforming to UIViewRepresentable
//새 파일을 생성한다. iOS ▸ User Interface ▸ SwiftUI View 를 선택한다.
//UIViewRepresentable 프로토콜을 구현한다.
//UIViewControllerRepresentable 처럼 make와 update를 구현해야 한다.

//Updating the UIView from SwiftUI
//UIKit에서만 구현할 수 있는 속성들이 있는 경우, 이를 사용해 SwiftUI View를 만든다.

//Coordinating data between UIView and SwiftUI view
//UISlider(Float)와 SwiftUI의 Slider(Double) 자료형 타입이 다르다.
//SwiftUI View인 ColorUISlider의 데이터와 UIKit의 UISlider 데이터가 동기화되도록
//coordinator를 생성해 줘야 한다.

