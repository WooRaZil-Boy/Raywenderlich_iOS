/// Copyright (c) 2020 Razeware LLC
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
import LocalAuthentication

func getBiometricType() -> String {
  let context = LAContext()
  
  _ = context.canEvaluatePolicy(
    .deviceOwnerAuthenticationWithBiometrics,
    error: nil)
  switch context.biometryType {
  case .faceID:
    return "faceid"
  case .touchID:
    // In iOS 14 and later, you can use "touchid" here
    return "lock"
  case .none:
    return "lock"
  @unknown default:
    return "lock"
  }
}

// swiftlint:disable multiple_closures_with_trailing_closure
struct ToolbarView: View {
  @Binding var noteLocked: Bool
  @ObservedObject var noteData: NoteData
  @Binding var setPasswordModal: Bool
  @State private var showUnlockModal: Bool = false
  @State private var changePasswordModal: Bool = false
  
  func tryBiometricAuthentication() {
    let context = LAContext()
    var error: NSError?
    //LAContext 객체를 사용하여, 생체 인증에 access한다.
    //이는 user interaction에서 biometrics을 수집하고 device의 Secure Enclave와 통신한다.
    //LocalAuthentication은 Swift보다 오래되었으며, NSError와 같은 Objective-C 패턴을 사용한다.
    
    if context.canEvaluatePolicy(
        .deviceOwnerAuthenticationWithBiometrics,
        error: &error) {
      //먼저 authentication이 사용 가능한지 확인한다.
      //.deviceOwnerAuthenticationWithBiometrics는 생체 인증을 요청한다.
      
      let reason = "Authenticate to unlock your note."
      context.evaluatePolicy(
//        .deviceOwnerAuthenticationWithBiometrics,
        .deviceOwnerAuthentication,
        localizedReason: reason) { authenticated, error in
        //사용자에게 인증을 사용하려는 이유를 이유를 설명한다.
        //evaluationPolicy(_:localizedReason:reply:)를 호출하면 인증을 요청한다.
        //현재 device에서 사용 가능한 Face ID 또는 Touch ID 인증을 수행한다.
        //이 호출은 반환될 때 block을 실행한다.
        
        DispatchQueue.main.async {
          //block에서는 이 코드를 실행하고 UI를 변경하므로, 변경 내용이 UI 스레드에서 실행되어야 한다.
          if authenticated {
            //인증에 성공하면, note를 잠금 해제로 설정한다.
            //인증에 대한 추가 정보는 없다. 오로지 성공과 실패 여부만 알 수 있다.
            self.noteLocked = false
          } else {
            //인증에 실패하면, block에 발생한 error를 출력한다.
            if let errorString = error?.localizedDescription {
              print("Error in biometric policy evaluation: \(errorString)")
            }
            self.showUnlockModal = true
            //showUnlockModal 상태를 true로 설정한다. 이렇게 하면, app이 수동 password 동작으로 돌아가게 된다.
          }
        }
      }
    } else {
      //초기 확인에 실패한다면, 생체 인증을 사용할 수 없다는 의미이다.
      if let errorString = error?.localizedDescription {
        print("Error in biometric policy evaluation: \(errorString)")
      }
      showUnlockModal = true
      //수신된 erorr를 출력한 다음, unlock view를 표시한다. 다시 말해, 대체 인증을 제공한다.
      
      //일부 device에는 인증이 없거나, user가 설정하지 않았을 수 있다. 그리고 때때로 인증이 실패할 수도 있다.
      //실패 이유가 무엇이든, 항상 user에게 생체 인증없이도 app을 사용할 수 있는 적절한 방법을 제공해야 한다.
    }
  }

  var body: some View {
    HStack {
      #if DEBUG
      Button(
        action: {
          print("App reset.")
          self.noteData.noteText = ""
          self.noteData.updateStoredPassword("")
        }, label: {
          Image(systemName: "trash")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 25.0, height: 25.0)
        })
      #endif

      Color.clear
        .sheet(isPresented: $setPasswordModal) {
          SetPasswordView(
            title: "Set Note Password",
            subTitle: "Enter a password to protect this note.",
            noteLocked: self.$noteLocked,
            showModal: self.$setPasswordModal,
            noteData: self.noteData
          )
        }

      Spacer()

      Button(
        action: {
          self.changePasswordModal = true
        }) {
        Image(systemName: "arrow.right.arrow.left")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 25.0, height: 25.0)
      }
      .disabled(noteLocked || noteData.isPasswordBlank)
      .sheet(isPresented: $changePasswordModal) {
        SetPasswordView(
          title: "Change Password",
          subTitle: "Enter new password",
          noteLocked: self.$noteLocked,
          showModal: self.$changePasswordModal,
          noteData: self.noteData)
      }

      Button(
        action: {
          if self.noteLocked {
            // Biometric Authentication Point
//            self.showUnlockModal = true
            self.tryBiometricAuthentication() //생체 인증 사용하도록 변경
          } else {
            self.noteLocked = true
          }
        }) {
        // Lock Icon
//        Image(systemName: noteLocked ? "lock" : "lock.open")
        Image(systemName: noteLocked ? getBiometricType() : "lock.open")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 25.0, height: 25.0)
      }
      .sheet(isPresented: $showUnlockModal) {
        if self.noteData.isPasswordBlank {
          SetPasswordView(
            title: "Enter Password",
            subTitle: "Enter a password to protect your notes",
            noteLocked: self.$noteLocked,
            showModal: self.$changePasswordModal,
            noteData: self.noteData)
        } else {
          UnlockView(noteLocked: self.$noteLocked, showModal: self.$showUnlockModal, noteData: self.noteData)
        }
      }
    }
    .frame(height: 64)
  }
}

struct ToolbarView_Previews: PreviewProvider {
  static var previews: some View {
    ToolbarView(noteLocked: .constant(true), noteData: NoteData(), setPasswordModal: .constant(false))
  }
}




