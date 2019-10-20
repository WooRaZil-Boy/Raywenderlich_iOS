//
//  ContentView.swift
//  RGBullsEye
//
//  Created by 근성가이 on 2019/10/20.
//  Copyright © 2019 근성가이. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    let rTarget = Double.random(in: 0..<1)
    let gTarget = Double.random(in: 0..<1)
    let bTarget = Double.random(in: 0..<1)
    //유저가 맞춰야하는 값. 변경되지 않으므로 상수.
    
    @State var rGuess: Double
    @State var gGuess: Double
    @State var bGuess: Double
    //값이 변경될 때 UI를 업데이트하는 변수는 @State로 이를 선언해 줘야 한다.
    //여기서 직접 값을 입력해 초기화 할 수도 있다.
    //선언만 한 경우에는, ContentView가 초기화 될 때 해당 매개 변수를 초기화 해줘야 한다.
    //SceneDelegate의 scene(_:willConnectTo:options:) 에서도 매개변수를 입력해 줘야 한다.
    
    @State var showAlert = false //직접 초기화
    //Alert을 호출할 때 사용하는 Bool
    
    func computeScore() -> Int { //Alert에서 사용할 score 계산
        let rDiff = rGuess - rTarget
        let gDiff = gGuess - gTarget
        let bDiff = bGuess - bTarget
        
        let diff = sqrt(rDiff * rDiff + gDiff * gDiff + bDiff * bDiff)
        //3차원 공간에서 두 점 사이의 거리
        
        return Int((1.0 - diff) * 100.0 + 0.5) //scaling
    }
    
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Color(red: rTarget, green: gTarget, blue: bTarget)
                    //랜덤한 색상이 업데이트 된다.
                    Text("Match this color")
                }
                
                VStack {
                    Color(red: rGuess, green: gGuess, blue: bGuess)
                     Text("R: \(Int(rGuess * 255.0))"
                        + " G: \(Int(gGuess * 255.0))"
                        + " B: \(Int(bGuess * 255.0))")
                    //여기에서는 Guess 값을 read-only 로 사용하고,
                    //값을 직접 변경하지 않으므로 $ 접두사가 필요하지 않다.
                }
            }
            
            Button(action: {
                self.showAlert = true
                //클로저 내부 이므로, self 를 사용해야 한다.
            }) {
                //Button은 UIButton과 마찬가지로 Action과 Label이 있다.
                //하지만, Button action에서 Alert을 만들면 실행이 되지 않는다.
                //대신 ContentView의 subView 중 하나로 Alert을 작성해야 한다.
                //Bool 타입의 @State 변수를 추가해 해당 변수가 true가 될 때 Alert을 호출한다.
                Text("Hit Me!")
            }.alert(isPresented: $showAlert) {
                Alert(title: Text("Your Score"), message: Text(String(computeScore())))
                //Alert에는 기본 OK 버튼이 포함되어 있다.
            }.padding() //패딩 추가
            
            
            
            
            //Creating the button and slider
            //Library 를 계속 활성화 시켜 놓으려면, + 버튼을 Option-click 하면 된다.
            //Button을 Canvas 영역에 Drag and drop 해도 되지만, 코드 영역에 적용할 수도 있다.
            //Slider도 같은 방법으로 추가한다.
            
            ColorSlider(value: $rGuess, textColor: .red)
            ColorSlider(value: $gGuess, textColor: .green)
            ColorSlider(value: $bGuess, textColor: .blue)
            
            //재사용 가능한 View로 대체한다.
        }
        
        //Creating the target color block
        //Text를 Command-click 하면, 해당 부분이 선택되면서, 추가 메뉴가 활성화 된다.
        //여기서, Embed in VStack를 선택하면, VStack으로 해당 부분을 감싸게 된다.
        //Canvas의 preview에서도 같은 방법으로 사용 가능하다.
        //Text의 String을 변경하는 것을 코드에서 해도 되지만,
        //Canvas에서 Command-click 하여, Show SwiftUI Inspectord에서 변경해도 된다.
        //우측 Inspector 바에 표시되는 것과 같다.
        
        //도구모음에서 + 버튼을 선택해서 라이브러리를 열 수 있다.
        //필요한 객체를 검색해 drag 해서 Canvas에 drop한다.
        //코드로 직접 입력해도 된다.
        //Interface Builder에서는 여러 객체를 drag 한 다음 다중 선택하여 Stack에 포함할 수 있었지만,
        //SwiftUI Embed는 단일 객체에서만 작동한다.
        
        //SwiftUI에서는 최상위 Body에서 두 개 이상의 View를 가질 수 없다.
        
        //Creating the guess color block
        //이전에 생성한 Stack의 오른쪽에 비슷한 형태의 Stack을 생성한다(HStack을 최상위로 사용).
        //코드를 작성할 수도 있지만, VStack를 Command-click 해, Embed in HStack로 중첩한다.
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
//        ContentView()
        ContentView(rGuess: 0.5, gGuess: 0.5, bGuess: 0.5).frame(width: nil).previewLayout(.fixed(width: 568, height: 320))
        //width와 height를 지정해 가로로 preview를 본다.
        //568 x 320은 iPhone SE의 landscape 크기이다. //bit.ly/29Ce3Ip
        
        //매개변수 값을 넣어 초기화 한다.
    }
}

struct ColorSlider: View {
    @Binding var value: Double
    //ColorSlider가 이 값을 소유하지 않기 때문에 @State 대신, @Binding을 써준다.
    //부모 View에서 초기 값을 가져와 변경한다.
    var textColor: Color
    
    var body: some View {
        HStack {
            Text("0").foregroundColor(textColor)
            Slider(value: $value)
            //gGuess 자체는 read-only 이다. 여기에 $를 붙여주면, read-write 로 사용할 수 있다.
            //Slider의 값을 변경하면서 색상을 업데이트 하려면 $를 붙여줘야 한다.
            Text("256").foregroundColor(textColor)
        }.padding(.horizontal)
    }

    //추출할 객체에서 Command-click을 하고, Extract Subview를 선택해 따로 추출할 수 있다.
}

//DEBUG에서 ContentView를 보여준다.
//Chapter 1: Introduction
//SwiftUI는 Swift를 사용해 모든 Apple 플랫폼의 UI 인터페이스를 구축하는 혁신적이고 매우 간단한 방법이다.
//2019년에 발표된 SwiftUI는 UIKit과 AppKit를 사용해 앱 UI를 새로 만들 수있는 새로운 방법이다.
//SwiftUI는 단순하고 강력한 크로스 플랫폼 도구이다.
//가장 중요한 것 중 하나는 SwiftUI가 선언적 특성이라는 것이다.
//그동안 개발자들은 상태 관리 문제와 복잡한 코드를 다루는 명령형 프로그래밍 모델을 사용해 왔다.
//또한, UIKit 혹은 AppKit 프레임 워크를 SwiftUI 코드와 통합 할 수도 있다.




//Chapter 2: Getting Started
//Getting started
//슬라이더를 움직혀 현재 색상의 RGB 값을 맞추는 게임을 만든다.

//Creating a new SwiftUI project
//SwiftUI를 사용하려면, 새 프로젝트를 생성할 때, User Interface에서 SwiftUI를 선택하면 된다.
//SwiftUI로 프로젝트를 생성하면, AppDelegate.swift 와 SceneDelegate.swift 가 생성된다.
//SceneDelegate.swift 에는 UIHostingController를 생성하는 코드가 있다.
//앱이 시작되면, ContentView.swift에 정의된 인스턴스가 보여진다. View protocol을 준수하는 구조체이다.

//Previewing your ContentView
//우측의 창에서 preview를 확인할 수 있다. Resume 버튼을 누르면 새로고침을 한다.
//preview가 보이지 않는다면, Editor Options 버튼를 눌러, Canvas를 선택하면 된다(macOS 10.15 이상).
//버튼을 누르는 대신, Option-Command-P 단축키를 사용할 수도 있다.

//Previewing in landscape
//현재까지는 landscape로 preview를 보는 방법이 없다. 가로로 보려면 width와 height를 지정해야 한다.
//Layout에서 Canvas on Bottom을 눌러 preview를 하단으로 옮길 수도 있다.




//Creating your UI
//SwiftUI 앱에서는 StoryBoard 나 ViewController가 없다. ContentView.swift에서 이를 대신한다.
//StoryBoard와 비슷하게 필요한 객체를 drag and drop해 UI를 만들 수 있고, 모두 자동으로 동기화된다.
//SwiftUI는 선언적이다(declarative). UI의 모양을 선언하면, SwiftUI는 이를 효율적인 코드로 변환한다.
//Apple은 코드를 쉽게 읽을 수 있도록 필요한 만큼의 View를 생성하도록 권유한다.
//매개 변수화되어 재사용 가능한 View가 권장된다. 코드를 함수로 추출하는 것과 비슷하게 작업할 수 있다.

//Some SwiftUI vocabulary
// • Canvas and Minimap : mac 10.15, Xcode 11 이후 부터 추가되었다.
// • Container views : HStack 이나 VStack 를 사용하여 SwiftUI에서 앱의 스택 UI를 쉽게 만들 수 있다.
//    이외에도 ZStack 이나 Group 등을 사용할 수 있다.
//Container view 외에도, Text, Button, Slider와 같은 UIKit 객체들에 대한 SwiftUI View가 있다.
//툴바의 + 버튼로 SwiftUI View의 Library를 확인할 수 있다.
//UIKit 객체에 속성을 설정하는 대신 Modifier를 사용해, 색상, 글꼴, 패딩 등을 추가해 줄 수 있다.

//Creating the target color block
//SwiftUI에서는 최상위 Body에서 두 개 이상의 View를 가질 수 없다.
//따라서, container view(여기서는 VStack, vertical stack) 안에 View를 배치해야 한다.

//Creating the guess color block
//해당 부분의 코드를 Command-click 해서, 쉽게 Stack을 중첩할 수 있다.

//Creating the button and slider
//두 Stack 밑에 Button과 Slider를 포함하는 Container가 필요하다.




//Updating the UI
//SwiftUI에서 일반적인 상수와 변수를 사용할 수 있다.
//값이 변경될 때 UI를 업데이트하는 변수는 @State로 이를 선언해 줘야 한다.
//SwiftUI에서 @State 변수가 변경되면, View는 body를 다시 설정한다.
//이 앱에서는 오른쪽의 추축 부분의 Slider 값이 @State로 선언되어야 한다.

//Using @State variables
//선언만 한 경우에는, ContentView가 초기화 될 때 해당 매개 변수를 초기화 해줘야 한다.
//SceneDelegate의 scene(_:willConnectTo:options:) 에서도 매개변수를 입력해 줘야 한다.

//Updating the Color views
//이전에 설정한 @State 변수로 해당 값을 지정해 준다.




//Making Reusable Views
//Slider는 기본적으로 동일하므로, 하나의 Slider를 정의한 다음 재사용하는 것이 좋다.

//Making the red slider
//하나의 Slider를 먼저 만든다. Slider 양쪽에 최소값과 최대값을 나타내는 Text가 필요하고,
//이를 하나로 감싸는 HStack이 필요하다.

//Bindings
//$ 접두사를 붙여 변수를 사용하면, read-write로 값을 사용하게 된다.
//기본적으로 그냥 사용하면, read-only 이다.

//Extracting subviews
//추출할 객체에서 Command-click을 하고, Extract Subview를 선택해 따로 추출할 수 있다.
//Refactor ▸ Extract to Function 과 동일하지만, SwiftUI View에 적용된다.

//Live Preview
//시뮬레이터를 실행할 필요 없이 Canvas에서 오른쪽 아래 모서리에서 live preview 버튼을 눌러서
//바로 preview에서 앱을 실행해 볼 수 있다.
//Slider의 값이 변경될 때마다 SwiftUI View가 자동으로 업데이트 된다.
//반면, UIKit은 모든 코드를 Slider Action에 넣어 작업한다.
//SwiftUI에서는 @State 변수로 이를 구현한다. View는 일련의 event가 아닌 state에 따라 업데이트 된다.

//Presenting an Alert
//SwiftUI에서 Button의 Alert은, subView에 붙여서 사용한다.


