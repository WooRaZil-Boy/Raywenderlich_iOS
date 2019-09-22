//
//  ContentView.swift
//  RGBullsEye
//
//  Created by 근성가이 on 22/09/2019.
//  Copyright © 2019 근성가이. All rights reserved.
//

import SwiftUI

struct ContentView: View { //View를 구현하는 구조체
    let rTarget = Double.random(in: 0..<1) //0 ~ 1 사이의 랜덤 Double 값
    let gTarget = Double.random(in: 0..<1)
    let bTarget = Double.random(in: 0..<1)
    
    @State var rGuess: Double
    @State var gGuess: Double
    @State var bGuess: Double
    //SwiftUI에서 일반적인 상수와 변수를 사용할 수 있지만, 값이 변경될 때 마다 UI를 업데이트 해야 하는 경우에는 @State 변수로 선언한다.
    //초기값을 지정해 줄 수도 있지만, 그냥 선언을 하면, 초기화할 때 값을 줘야 한다.
    
    @State var showAlert = false
    //Alert 호출을 위한 변수
    
    func computeScore() -> Int {
        let rDiff = rGuess - rTarget
        let gDiff = gGuess - gTarget
        let bDiff = bGuess - bTarget
        let diff = sqrt(rDiff * rDiff + gDiff * gDiff + bDiff * bDiff)
        //3차원에서 두 점 사이의 거리
        
        return Int((1.0 - diff) * 100.0 + 0.5)
    }
    
    var body: some View {
        VStack {
            HStack {
                // Target color block
                VStack {
                    Rectangle() //사각형 View. 기본 색상은 foreground.
                        .foregroundColor(Color(red: rTarget, green: gTarget, blue: bTarget, opacity: 1.0)) //색상 지정
                    Text("Match this color") //TextView
                }
                
                // Guess color block
                VStack {
                  Rectangle()
                        .foregroundColor(Color(red: rGuess, green: gGuess, blue: bGuess, opacity: 1.0))
                    HStack {
                        Text("R: \(Int(rGuess * 255.0))")
                        Text("G: \(Int(gGuess * 255.0))")
                        Text("B: \(Int(bGuess * 255.0))")
                        //여기서는 변수의 값을 변경하지 않으므로, $ 접두사가 필요하지 않다.
                    }
                }
                //변경하고, build를 다시할 필요 없이, preview의 resume을 선택해(Option-Command-P ) 새로고침할 수 있다.
                //Commnad-Click을 선택해 여러 가지 작업을 쉽게 할 수 있다.
                //Tutorial에서는 Embed in HStack, Embed in VStack을 선택해서 바로 처리할 수 있다.
            }
            
            //직접 코드를 치치 않고, Storyboard 에서 처럼 + 버튼을 눌러, Library를 연 다음, 필요한 View를 추가해 줄 수 있다.
            
            Button(action: { //Button은 UIButton처럼 Action과 Label을 가지고 있다.
                //여기서는 Button을 눌렀을 때, Alert을 보여주는 것이 목적이지만,
                //여기서 직접 Alert을 선언해 코드로 구현하면 작동하지 않는다.
                //대신에, ContentView의 subview 중 하나로 Alert을 만든 후에, @State 변수(Bool)을 추가한다.
                //그 후에, true 값이 설정되면, alert이 호출되도록 한다.
                self.showAlert = true //클로저이므로 self를 써줘야 한다.
            }) {
                Text("Hit Me!")
            }
            .alert(isPresented: $showAlert) { //$showAlert 이 true일 때 호출 된다.
                Alert(title: Text("Your Score"), message: Text("\(computeScore())"))
                //OK 버튼이 Alert에 기본적으로 포함된다.
            }

            VStack { //View를 재사용한다.
                ColorSlider(value: $rGuess, textColor: .red)
                ColorSlider(value: $gGuess, textColor: .green)
                ColorSlider(value: $bGuess, textColor: .blue)
            }
        }
    }
}

struct ColorSlider : View {
    @Binding var value: Double
    //새로운 @State 변수를 사용하는 것이 아니라, 그 값을 바인딩해서 사용하므로 @Binding 으로 선언한다.
    var textColor: Color
    
    var body: some View { //body 변수에 SwiftUI에 대한 코드를 작성한다.
        HStack {
            Text("0")
                .foregroundColor(textColor)
            Slider(value: $value) //@State 변수 사용
            //rGuess 자체는 read-only 이다. $rGuess 로 사용하면, read-write로 바인딩 된다.
            //유저가 slider 값을 변경하면, 해당 값을 가져와 UI를 업데이트 하는데 사용한다.
            Text("255")
                .foregroundColor(textColor)
        }
            .padding() //padding을 추가한다. 패딩 값을 지정해 줄 수도 있다.
            //Command-Click으로 HStack을 선택한 후, Extract Subview으로 반복되는 코드를 따로 함수로 만들 수 있다.
            //Refactor ▸ Extract to Function 과 동일하다.
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(rGuess: 0.5, gGuess: 0.5, bGuess: 0.5)
        //선언된 변수에 대한 초기값이 필요하다.
    }
}

//SwiftUI를 사용해면, Interface Builder 혹은 스토리보드를 대체하여 UI 레이아웃을 만들 수 있다.
//IBAction, IBOutlet 에서 발생하는 앱 충돌을 없앤다.
//또한 segue 혹은 cell 에서 문자열 식별자를 직접 확인해 보기 힘들었지만, WYSIWYG 편집기로 더 쉽고 빠르게 UI를 확인 가능하다.
//SwiftUI와 코드를 나란히 볼 수 있다. 한 쪽을 변경하면, 나머지 쪽도 항상 동기화 되므로, 문자열 식별자를 잘못 인식하지 않는다.
//또한 코드의 양이 UIKit으로 작성하는 보다 훨씬 줄어든다.
//SwiftUI는 UIKit을 대체하지 않는다. SwiftUI와 UIKit을 동시에 사용 가능하다.
//macOS에서는 SwiftUI iOS 앱을 실행 할 수 없다(이 기능은 Catalyst).하지만, SwiftUI API는 플랫폼 간에
//일관적으로 적용되므로, 동일한 소스 코드를 각 플랫폼에 적용하여 멀티 플랫폼 앱을 더 쉽게 개발할 수 있다.




//Getting Started
//Xcode 11 이상에서 SwiftUI를 사용할 수 있다. 프로젝트를 생성할 때, User Interface에서 SwiftUI를 선택한다.

//앱이 시작하면 이 화면에서 정의된 window 인스턴스가 보여진다.
//바뀐 코드를 빌드하는 대신 코드 우측에서 미리보기(canvas)로 바로 UI 변경을 확인할 수 있다(macOS 10.15 이상).




//Outlining Your UI
//Main.storyboard가 없다. SwiftUI로 UI를 작성하면, preview로 UI를 확인할 수 있다.
//SwiftUI로 UI를 선언하면, 내부적으로 효율적인 코드로 변환한다.
//재사용 가능하도록 매개변수화된 View를 필요한 만큼 사용하도록 권장된다.
//실제로 View를 작성하기 전에 대략적인 모습의 Outlet을 그려보는 것이 좋다.




//Filling in Your Outline
//이전에 작성한 대략적인 Outlet에 실제로 적용할 View들을 차례대로 적용시킨다.




//Using @State Variables
//SwiftUI에서 일반적인 상수와 변수를 사용할 수 있지만, 값이 변경될 때 마다 UI를 업데이트 해야 하는 경우에는 @State 변수로 선언한다.
//SceneDelegate에서도 해당 View를 초기화해 사용하므로 초기화하는 코드를 추가해 줘야 한다.




//Making Reusable Views
//preview의 resume 단축키는 Option-Command-P 이다.
//preview의 디바이스 오른쪽 아래 모서리에 live preview를 클릭하면 시뮬레이터에서 실행되는 것처럼 테스트해 볼 수 있다.




//Presenting an Alert
//SwiftUI를 사용하면, 디바이스 방향에 따라 UI가 자동으로 최적화된다.
