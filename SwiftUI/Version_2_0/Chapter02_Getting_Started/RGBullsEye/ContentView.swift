//
//  ContentView.swift
//  RGBullsEye
//
//  Created by 근성가이 on 2020/09/12.
//  Copyright © 2020 geunseong-gai. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    let rTarget = Double.random(in: 0..<1)
    let gTarget = Double.random(in: 0..<1)
    let bTarget = Double.random(in: 0..<1)
    @State var rGuess: Double
    @State var gGuess: Double
    @State var bGuess: Double
    //값이 변경될 때마다 UI가 업데이트 되는 변수를 @State로 선언한다.
    
    @State var showAlert = false
    
    func computeScore() -> Int {
        let rDiff = rGuess - rTarget
        let gDiff = gGuess - gTarget
        let bDiff = bGuess - bTarget
        let diff = sqrt((rDiff * rDiff + gDiff * gDiff + bDiff * bDiff) / 3.0)
        
        return lround((1.0 - diff) * 100.0)
    }
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Color(red: rTarget, green: gTarget, blue: bTarget)
                    Text("Match this color")
                }
                VStack {
                    Color(red: rGuess, green: gGuess, blue: bGuess)
                     Text("R: \(Int(rGuess * 255.0))"
                        + " G: \(Int(gGuess * 255.0))"
                        + " B: \(Int(bGuess * 255.0))")
                }
            }
            
            Button(action: { self.showAlert = true }) {
                Text("Hit Me!")
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Your Score"), message: Text(String(computeScore())))
            }
            .padding()
            
            ColorSlider(value: $rGuess, textColor: .red)
            ColorSlider(value: $gGuess, textColor: .green)
            ColorSlider(value: $bGuess, textColor: .blue)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(rGuess: 0.5, gGuess: 0.5, bGuess: 0.5) //초기화 필요
            .previewLayout(.fixed(width: 568, height: 320)) //iPhone SE
            //고정된 크기(가로)로 preview. 아직 정식으로 가로 모드 preview를 지원하지 않는다.
    }
}

struct ColorSlider: View { //재사용 뷰
    @Binding var value: Double
    //ColorSlider가 해당 데이터를 소유하지 않기 때문에 @State 대신 @Binding을 사용한다.
    var textColor: Color
    
    var body: some View {
        HStack {
            Text("0")
                .foregroundColor(textColor)
            Slider(value: $value)
            Text("255")
                .foregroundColor(textColor)
        }
        .padding(.horizontal)
    }
}
