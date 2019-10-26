//
//  ContentView.swift
//  TVBullsEye
//
//  Created by 근성가이 on 2019/10/26.
//  Copyright © 2019 근성가이. All rights reserved.
//

import SwiftUI
import Game //Game 모듈을 가져온다.

struct ContentView: View {
    @ObservedObject var game = BullsEyeGame()
    
    @State var currentValue = 50.0
    @State var valueString: String = ""
    @State var showAlert = false
    
    var body: some View {
        VStack {
            Text("Guess the number:")
            TextField("1-100", text: $valueString, onEditingChanged: { _ in
                self.currentValue = Double(self.valueString) ?? 50.0
                //해당 String을 Double로 변환하여, currentValue를 가져온다.
            })
                //tvOS에서는 Sldier가 없기 때문에, 추측값을 입력하는 TextField를 만든다.
                .frame(width: 150.0)
            HStack {
                Text("0")
                GeometryReader { geometry in
                    ZStack {
                        Rectangle()
                            .frame(height: 8.0)
                        Rectangle()
                            .frame(width: 8.0, height: 30.0)
                            .offset(x: geometry.size.width * (CGFloat(self.game.targetValue)/100.0 - 0.5), y: 0.0)
                    }
                    //값을 수평선에 중첩된 marker(사각형)으로 표시한다.
                }
                Text("100")
            }
            .padding(.horizontal)
            
            Button(action: {
                self.showAlert = true
                self.game.checkGuess(Int(self.currentValue))
            }) {
                Text("Hit Me!")
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Your Score"), message: Text(String(game.scoreRound)), dismissButton: .default(Text("OK"), action: {
                    self.game.startNewRound()
                    self.valueString = ""
                    //빈 String으로 재설정 하는 것을 제외하곤 iOS와 동일하다.
                }))
            }
            .padding()
            HStack {
                Text("Total Score: \(game.scoreTotal)")
                Text("Round: \(game.round)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//Creating a tvOS BullsEye app
//tvOS도 비슷한 방법으로 만들면 된다. 하지만, tvOS에는 Slider가 없다. 이를 다른 방식으로 구현해야 한다.
//새로운 tvOS 프로젝트를 생성한다. tvOS ▸ Single View App을 선택하고,
//SwiftUI User Interface를 선택한다. Game 패키지를 가져오고,
//app target의 Frameworks, Libraries and Embedded Content 세션에서 Game패키지를 추가해 준다.
//Slider 대신 TextField에서 값을 입력 받아 표시해 주는 것으로 변경한다.

//Using the tvOS simulator
//시뮬레이터를 Keyboard Connected 메시지가 뜬다.
//키보드의 위, 아래 버튼을 눌러 초점을 이동한다.
//Hardware 메뉴에서 Show Apple TV Remote(Shift-Command- R)를 눌러 리모컨을 사용해도 된다.
