/// Copyright (c) 2021 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI

struct KuchiTextStyle: TextFieldStyle {
  public func _body(
    configuration: TextField<Self._Label>) -> some View {
      return configuration
        .padding(EdgeInsets(top: 8, leading: 16,
                            bottom: 8, trailing: 16))
        .background(Color.white)
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(lineWidth: 2)
            .foregroundColor(.blue)
        )
        .shadow(color: Color.gray.opacity(0.4),
                radius: 3, x: 1, y: 2)
      //custom style을 적용시킨다.
  }
}
//Custom textField style

struct RegisterView: View {
//  @State var name: String = ""
  //userManager로 대체
  @EnvironmentObject var userManager: UserManager
  @ObservedObject var keyboardHandler: KeyboardFollower
  
  init(keyboardHandler: KeyboardFollower) {
    self.keyboardHandler = keyboardHandler
  }
  
  var body: some View {
//    ZStack {
//      WelcomeBackgroundImage()
//      VStack {
//        WelcomeMessageView()
//        TextField("Type your name...", text: $name)
//      }
//    }
    //ZStack을 사용하면, 배경 이미지가 .fill로 채워져 TextField가 제대로 표현되지 않는다.
    
    VStack {
      Spacer()
      WelcomeMessageView()
//      TextField("Type your name...", text: $name)
      
//        .padding(EdgeInsets(top: 8, leading: 16,
//                            bottom: 8, trailing: 16))
//        .background(Color.white)
//        .overlay(
//          RoundedRectangle(cornerRadius: 8)
//            .stroke(lineWidth: 2)
//            .foregroundColor(.blue)
//        )
//        .shadow(color: Color.gray.opacity(0.4),
//                radius: 3, x: 1, y: 2)
      
//        .textFieldStyle(KuchiTextStyle())
        //생성한 custom textField style로 대체한다.
      
//      ModifiedContent(
//        content: TextField("Type your name...", text: $name),
//        modifier: BorderedViewModifier()
//      )
      
//      TextField("Type your name...", text: $name)
      TextField("Type your name...", text: $userManager.profile.name)
        .bordered()
        //extension 사용

//      Button(action: self.registerUser) {
//        Text("OK")
//      }
      
      HStack {
        Spacer()
        //Spacer를 사용하여 pseudo-right-alignment 방식으로 Text를 오른쪽으로 밀어넣는다.
        Text("\(userManager.profile.name.count)") //Text는 name 속성의 문자 수이다.
          .font(.caption)
          .foregroundColor(userManager.isUserNameValid() ? .green : .red)
          //요효성 검사를 통과하면 녹색, 그렇지 않으면 빨간색이 된다.
          .padding(.trailing)
      }
      .padding(.bottom)
      //OK 버튼에서 약간의 간격을 추가한다.
      
      HStack {
        Spacer()
        //왼쪽에 간격을 추가하고, toggle을 오른쪽으로 밀어 정렬하려면 Spacer가 필요하다.
          
        Toggle(isOn: $userManager.settings.rememberUser) {
        //$userManager.settings.rememberUser에 바인딩된 Toggle을 생성한다.
          Text("Remember me") //구성 요소 자체 앞에 표시되는 label
            .font(.subheadline)
            .foregroundColor(.gray)
            //label의 기본 스타일을 변경한다.
        }
        .fixedSize()
        //toggle이 이상적인 크기를 선택하도록 한다.
        //이것이 없으면, toggle은 사용가능한 모든 공간을 차지하면서 수평으로 확장하려 한다.
      }
      
      Button(action: self.registerUser) {
        HStack {
        //label 매개변수는 여러 하위 view를 반환할 수 있다.
        //여기서는 HStack를 사용하여 view를 가로로 그룹화한다.
        //이를 생략하면, 두 components가 수직으로 배치된다.
        Image(systemName: "checkmark") //checkmark 아이콘을 추가한다.
          .resizable()
          .frame(width: 16, height: 16, alignment: .center)
          //아이콘을 가운데 정렬하고, 16 x 16 사이즈로 한다.
        Text("OK")
          .font(.body)
          //글꼴을 .body 유형으로 변경한다.
          .bold()
          //글꼴을 굵게 한다.
        }
      }
      .bordered()
      //bordered 수정자를 적용하여 모서리가 둥근 파란색 테두리를 추가한다.
      .disabled(!userManager.isUserNameValid())
      //해당 경우 disabled 된다.
      
      Spacer()
    }
    .padding(.bottom, keyboardHandler.keyboardHeight)
    .edgesIgnoringSafeArea(
      keyboardHandler.isVisible ? .bottom : [])
    .padding()
    .background(WelcomeBackgroundImage())
  }
}

struct RegisterView_Previews: PreviewProvider {
  static let user = UserManager(name: "Ray")
  
  static var previews: some View {
//    RegisterView()
//    RegisterView(keyboardHandler: KeyboardFollower())
    RegisterView(keyboardHandler: KeyboardFollower())
      .environmentObject(user)
  }
}

// MARK: - Event Handlers
extension RegisterView {
  func registerUser() {
//    print("Button triggered")
//        userManager.persistProfile()
    
    if userManager.settings.rememberUser {
    //user가 선택한 기억 여부를 확인한다.
      userManager.persistProfile()
      //yes 인 경우, profile을 계속 유지한다.
    } else {
      userManager.clear()
      //no 인 경우, user defaults를 제거한다.
    }
      
    userManager.persistSettings()
    userManager.setRegistered()
    //설정을 저장하고, 등록된 user를 표시한다.
  }
}
