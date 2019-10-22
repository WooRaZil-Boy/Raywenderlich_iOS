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
    
    @ObservedObject var timer = TimeCounter()
    //ObservableObject 프로토콜을 준수하는 TimeCounter 클래스에 대한 데이터 종속성 선언
    //Combine에서는 TimeCounter publisher를 subscribing 했다라고 표현한다.
    
    func computeScore() -> Int {
        //Alert에서 사용할 score 계산
        let rDiff = rGuess - rTarget
        let gDiff = gGuess - gTarget
        let bDiff = bGuess - bTarget

        let diff = sqrt(rDiff * rDiff + gDiff * gDiff + bDiff * bDiff)
        //3차원 공간에서 두 점 사이의 거리

        return Int((1.0 - diff) * 100.0 + 0.5) //scaling
    }
    
    var body: some View {
        //Dart 모드로 preview 하기 위해서 NavigationView가 필요하다.
        VStack {
            HStack {
                VStack {
                    Color(red: rTarget, green: gTarget, blue: bTarget)
                    //랜덤한 색상이 업데이트 된다.
                    self.showAlert ? Text("R: \(Int(rTarget * 255.0))"
                        + " G: \(Int(gTarget * 255.0))"
                        + " B: \(Int(bTarget * 255.0))")
                        : Text("Match this color")
                    
                    //Showing conditional views
                    //명시적인 조건(explicit condition)에 따라 다르게 표시 된다.
                    //showAlert이 true가 되면, 해당 Text가 자동으로 바뀐다.
                    //선언형으로 구현되었기 때문에, 따로 메서드를 작성해 줄 필요 없이
                    //showAlert의 state가 변경되면 자동으로 동기화 된다.
                }
                
                VStack {
                    ZStack(alignment: .center) {
                        //Text가 중앙에 오도록 정렬
                        Color(red: rGuess, green: gGuess, blue: bGuess)
                        Text(String(timer.counter))
                            //타이머가 매초마다 counter를 업데이트 하며, UI도 업데이트 된다.
                            .padding(.all, 5)
                            .background(Color.white)
                            .mask(Circle())
                            .foregroundColor(.black)
                            //Dark mode에서는 흰색이 기본이 되어 배경색에 가려지기 때문에 지정해 준다.
                        //Using ZStack
                        //Color 위에 Text를 추가하는데, 이러한 경우에는 ZStack을 사용할 수 있다.
                        //Command-click을 선택해도, Embed in ZStack은 없다.
                        //Hstack이나, VStack을 선택하고, Z로 바꿔주면 된다.
                        //ZStack은 화면의 수직인 Stack이다. 순서에 신경 써줘야 한다.
                    }
                    
                    
                    Text("R: \(Int(rGuess * 255.0))"
                        + " G: \(Int(gGuess * 255.0))"
                        + " B: \(Int(bGuess * 255.0))")
                    //여기에서는 Guess 값을 read-only 로 사용하고,
                    //값을 직접 변경하지 않으므로 $ 접두사가 필요하지 않다.
                }
            }
            
            Button(action: {
                self.timer.killTimer() //timer 삭제
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
            
            VStack {
                ColorSlider(value: $rGuess, textColor: .red)
                ColorSlider(value: $gGuess, textColor: .green)
                ColorSlider(value: $bGuess, textColor: .blue)
            }.padding(.horizontal)
            //재사용 가능한 View로 대체한다.
            
            //Modifying reusable views
            //Command-click, Embed in VStack를 선택해 처리할 수 있다.
            //Canvas가 있어야 Embed in VStack 메뉴가 활성화된다.
            
            //padding()은 모든 View에 적용할 수 있는 modifier 이다.
            //3개의 Slider의 padding을 한 번에 처리 할 수 있다.
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
        
//        .environment(\.colorScheme, .dark)
        //Dark Mode를 기본으로 설정
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
//        ContentView()
        ContentView(rGuess: 0.5, gGuess: 0.5, bGuess: 0.5).frame(width: nil).previewLayout(.fixed(width: 568, height: 320))
        //width와 height를 지정해 가로로 preview를 본다.
        //568 x 320은 iPhone SE의 landscape 크기이다. //bit.ly/29Ce3Ip
        
        //매개변수 값을 넣어 초기화 한다.
       
//        .environment(\.colorScheme, .dark)
        //환경 변수를 설정해 준다.
    }
}

struct ColorSlider: View {
    @Binding var value: Double
    //UI에 따라 달라지는 값이지만, ColorSlider가 이 값을 소유하지 않기 때문에
    //@State 대신, @Binding을 써준다. source of truth는 하나여야 한다.
    //부모 View에서 초기 값을 가져와 변경한다.
    var textColor: Color
    
    var body: some View {
        HStack {
            Text("0").foregroundColor(textColor)
            Slider(value: $value)
            //gGuess 자체는 read-only 이다. 여기에 $를 붙여주면, read-write 로 사용할 수 있다.
            //Slider의 값을 변경하면서 색상을 업데이트 하려면 $를 붙여줘야 한다.
                .background(textColor) //배경색 추가
                .cornerRadius(10) //모서리 둥글게
            
            //Adding modifiers in the right order
            //순서대로 적용 되므로, background와 cornerRadius의 순서가 바뀌면, 다르게 적용된다.
            //cornerRadius를 먼저 적용하면, 모서리를 둥글게 할 객체가 없으므로 아무것도 적용되지 않는다.
            Text("256").foregroundColor(textColor)
        }
        //padding(.horizontal)을 각 Slider에 추가하는 것이 아니라 전체 Slider Stack에 추가해 준다.
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




//-----------------------------------------------------------------------------------
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




//-----------------------------------------------------------------------------------
//Chapter 3: Understanding SwiftUI
//SwiftUI는 선언적(declarative) UI와 선언적인 데이터 종속성을 사용한다.

//Why SwiftUI?
//Interface Builder와 StoryBoard는 UI를 쉽게 적용하고, 레이아웃 전환 segue를 설정할 수 있었다.
//그러나, IB는 코드로 복사하거나 편집하기 어려운 단점이 있었다.
//또한 IBAction이나 IBOutlet의 이름을 변경하면, 코드의 변경 사항이 표시되지 않아 앱이 중단되며
//segue, TableViewCell 등에서 문자열 식별자를 사용하지만, 이를 확인하는 것도 힘들었다.
//SwiftUI를 사용하면, IB나 StoryBoard를 사용하지 않고도, UI의 자세한 단계별 구조를 정의할 수 있다.
//코드와 함께 Canvas로 preview를 확인하며, 한 쪽을 변경하면, 다른 쪽도 동기화 된다.
//코드의 양도 UIKit으로 작성하는 것보다 훨씬 적어, 코드 관리와 디버그가 쉽다.
//SwiftUI는 UIKit과 동시에 사용할 수 있으며, 변환(SwiftUI <-> UIKit) 또한 매우 쉽다.
//SwiftUI API는 Cross-Platform이기 때문에, 여러 플랫폼에서 동일한 앱을 쉽게 개발할 수 있다.

//Declarative app development
//SwiftUI로 선언적인(declarative) 앱 개발을 할 수 있다. 이 개념을 사용하면, 빠른 앱 개발이 가능하다.
//선언적 앱 개발(declarative app development)은 (선언형 프로그래밍)
//UI의 View가 표시되는 방식과 View에 의존하는 데이터를 모두 선언한다.
//SwiftUI는 View가 나타날 때 이를 생성하고, 의존하는 데이터가 변경될 때마다 View를 업데이트 한다.
//View의 상태(state)가 View의 모습에 어떻게 영향을 미치는지,
//의존하는 데이터가 변경될 때, SwiftUI가 어떻게 반응해야 하는지 선언해야 한다.
//이런 특성은 반응형 프로그래밍과 비슷하다.
// • Views: 선언적 UI는 문자열 식별자 없이 코드와 동기화 된다. layout 과 navigation에 View를 사용하고,
//  데이터의 presentation 로직을 캡슐화 한다.
// • Data: 선언적 데이터 종속성은 데이터가 변경될 때 View를 업데이트 한다.
//  View의 state는 데이터에 따라 달라지므로, View가 데이터 변경에 반응하는 방식 또는 영향을 선언한다.
// • Navigation: 조건부 Subview는 Navigation을 대체할 수 있다.
// • Integration: SwiftUI를 UIKit 앱에 쉽게 통합할 수 있다. 반대도 마찬가지다.




//Getting started
//SwiftUI vs. UIKit
//UIKit 앱을 만드려면, StoryBoard에 여러 Lable, Button, Slider 등의 객체를 배치하고
//ViewController에 연결한 다음, UI와 변경 사항을 동기화 하는 코드를 메서드나 함수에 따로 작성한다.
//SwiftUI 앱을 만드려면, auto-layout constraint을 설정하는 것 보다 훨씬 쉽게 객체를 나열하고
//SubView에서 데이터 변경에 따라 어떻게 적용되는지 선언한다. SwiftUI는 데이터 종속성에 따라
//View의 상태와 일관성을 유지하므로, 작업의 순서에 따라 UI 객체를 업데이트 하는 것이 함께 구현된다.
//Canvas preview는 StoryBoard를 대체할 수 있고, SubView는 자체적으로 업데이트 되므로
//ViewController가 필요하지 않다. live preview를 사용하면 시뮬레이터를 사용할 일도 크게 줄어든다.

//Declaring views
//SwiftUI View는 UI의 일부이다. 작은 View를 결합해서 더 큰 View를 만든다.
//Text, Color와 같은 기본 View를 커스텀 뷰의 구성 요소로 사용할 수 있다.
//View는 툴바의 + 버튼을 눌러 추가할 수 있다. (Command-Shift-L: Library)
//첫 번째 탭에는 View, 두 번재 탭에는 Modifier가 있다.
//View는 UIKit에서 사용하던 컨트롤러들과 비슷하고, Modifier는 효과 등을 추가해 주는 객체이다.
//SwiftUI를 사용하면 재사용 가능한 작은 View를 만든 다음 특정 상황에 맞게 modifier를 사용할 수 있다.
//이때 SwiftUI는 효율적으로 데이터를 축소하므로, 성능 저하에 대한 걱정을 할 필요가 없다.




//Environment values
//accessibility, locale, calendar, color scheme 와 같은 환경 값은 전체 앱에 영향을 준다.
//사용자 디바이스의 이런 설정에서 발생할 수 있는 문제를 예상하고 해결해야 한다.
//EnvironmentValues 리스트 링크 : apple.co/2yJJk7T
//앱의 기본모드로 다크모드를 설정하려면, 앱의 최상위 View에 대한 환경 값을 설정해야 한다.

//Modifying reusable views
//이전에 ColorSlider에 각각 padding을 추가했다.
//하지만, 세 개의 slider에 각각 padding을 추기 보다, Stack에 포함하여 padding을 추가할 수 있다.
//padding()은 모든 View에 적용할 수 있는 modifier 이다.

//Adding modifiers in the right order
//SwiftUI는 modifier를 추가한 순서대로 적용한다. 따라서 순서에 따라 다른 효과를 나타낼 수 있다.

//Showing conditional views
//명시적인 조건(explicit condition)을 추가해 줄 수도 있다.
//조건을 만족하는 경우, 따로 메서드를 이용해 UI를 업데이트 시켜줄 필요없이 state에 따라 자동으로 업데이트 된다.

//Using ZStack
//score에 시간 점수를 추가하여, 빠르게 Hit Me! 버튼을 누를 수록 추가적인 점수를 준다.
//Color 위에 Text를 추가하는데, 이러한 경우에는 ZStack을 사용할 수 있다.
//ZStack은 화면의 수직인 Stack이다. ZStack에서 나중에 넣은 item이 더 높은 위치에 있게 된다(stack이니까).

//Debugging
//Live Preview 버튼을 Control-click 하거나 Right-click 하여 Debug Preview 선택해
//런타임 디버깅을 할 수 있다.
//아래 디버그 콘솔에서 Environment Overrides 버튼을 눌러서 UI디버깅을 할 수 있다.
//Dark mode를 적용해 보거나 Text 크기 변경 등을 디버깅해 볼 수 있다.




//Declaring data dependencies
//Guiding principles
//SwiftUI에는 앱에서 데이터를 관리하는 두 가지 원칙이 있다.
// • Data access = dependency: View에서 데이터를 읽으면,
//  해당 View에서 해당 데이터에 대한 종속성이 추가된다.
//  모든 View는 데이터 종속성(input 혹은 state) 함수이다.
// • Single source of truth: View가 읽는 모든 데이터에는 View가 소유하거나 View 외부에 있는
//  source of truth가 존재한다. 이것이 어디에 있든 관계 없이 항상 하나이어야 한다.
//  이 앱의 ColorSlider에서 @State룰 선언하지 않은 이유이다.
//  동기화 된 상태를 유지하는 중복된 source of truth가 될 수 있으므로, @Binding으로 선언했다.
//  View는 다른 View의 @State 변수에 의존한다.
//UIKit에서 ViewController는 Model과 View를 동기화된 상태로 유지한다.
//SwiftUI에서는 이러한 특성 때문에 ViewController가 필요하지 않다.

//Tools for data flow
//SwiftUI는 앱에서 data flow를 관리하는 데 도움이 되는 몇 가지 도구를 제공한다.
//Property wrapper로 변수의 성능을 향상 시킬 수 있다.
//특정 wrapper(@State, @Binding, @ObservedObject, @EnvironmentObject)는
//변수가 나타내는 데이터에 대한 View의 종속성을 선언한다.
// • @State: @State 변수는 View의 소유이다. @State var는 persistent storage에 할당 되기 때문에
//  값을 초기화해야 한다. @State 변수가 해당 View에서 소유되고 관리됨을 강조한다.
// • @Binding: @Binding 변수는 다른 View가 소유한 @State var에 대한 종속성을 선언한다.
//  해당 View는 $ 접두사를 사용해 이 상태 변수에 대한 바인딩을 다른 View에 전달한다.
//  수신 View에서 @Binding var는 데이터에 대한 참조이므로 초기화할 필요 없다.
//  @Binding 참조는 View가 데이터에 의존하는 모든 View의 state를 편집할 수 있게 한다.
// • @ObservedObject: @ObservedObject는 ObservedObject 프로토콜을
//  구현하는 참조 유형의 종속성을 선언한다. 데이터 변경을 위해, objectWillChange 속성을 구현해야 한다.
// • @EnvironmentObject: @EnvironmentObject는 공유 데이터(앱의 모든 View에서 표시되는 데이터)에
//  대한 종속성을 선언한다. 부모 View에서 자식 View와 손녀 View로 데이터를 전달할 때,
//  자식 View에서는 필요하지 않는 데이터를 간접적으로 전달하는 편리한 방법이다.
//일반적으로 재사용 View에서는 @State 변수를 사용하지 않는다.
//대신에 @Binding 변수 또는 @ObservedObject 변수를 사용한다.
//Button의 highlighted 속성과 같이, View가 데이터를 소유해야 하는 경우에만, @State var 를
//사용해야 한다. 해당 데이터가 부모 View 혹은 외부 소스에서 소유하는지 생각해야 한다.

//Observing a reference type object
//TimeCounter.swift를 따로 생성한다. 해당 객체를 SwiftUI에 통합할 수 있다.




//-----------------------------------------------------------------------------------
//Chapter 4: Integrating SwiftUI
//기존의 UIKit에 SwiftUI를 추가할 수 있고, 반대로 SwiftUI 앱에서 UIKit을 추가할 수 도 있다.
//또한, SwiftUI와 데이터를 교환하는 UIKit도 작성할 수 있다.
//이를 "호스팅(Hosting)이라 한다. UIKit 앱은 SwiftUI View를 호스팅 할 수 있고,
//SwiftUI 앱은 UIKit View를 호스팅 할 수 있다.




//Getting started
//UIKit으로 작성된 프로젝트가 있다. 여기에 SwiftUI View를 통합하려 한다.

//Targeting iOS 13
//SwiftUI는 iOS 13 이상 부터 지원되므로 UIKit 앱의 배포 대상이 iOS 13인지 확인해야 한다.




//Hosting a SwiftUI view in a UIKit project
//가장 쉬운 통합 방법은 기존 UIKit앱에서 SwiftUI View를 호스팅하는 것이다.
// 1. SwiftUI View 파일을 프로젝트에 추가한다.
// 2. RGBullsEye를 실행하는 Button을 추가한다.
// 3. Hosting Controller를 StoryBoard로 끌어서 Segue를 만든다.
// 4. Segue를 ViewController 코드의 @IBSegueAction에 연결하고 Hosting Controller의
//  rootView를 SwiftUI View의 인스턴스로 설정한다.
//ContentView.swift를 BullsEye 프로젝트로 drag-and-drop 한다.


