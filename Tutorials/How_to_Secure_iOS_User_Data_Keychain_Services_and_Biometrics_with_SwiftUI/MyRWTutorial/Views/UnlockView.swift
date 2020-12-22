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

// swiftlint:disable multiple_closures_with_trailing_closure
struct UnlockView: View {
  @State var password = ""
  @State var passwordError = false
  @State var showPassword = false
  @Binding var noteLocked: Bool
  @Binding var showModal: Bool
  @ObservedObject var noteData: NoteData

  var body: some View {
    VStack(alignment: .leading) {
      Text("Enter Password")
        .font(.title)
      Text("Enter password to unlock note")
        .font(.subheadline)
      HStack {
        Group {
          if showPassword {
            TextField("Password", text: $password)
          } else {
            SecureField("Password", text: $password)
          }
        }
        Button(
          action: {
            self.showPassword.toggle()
          }) {
          if showPassword {
            Image(systemName: "eye.slash")
          } else {
            Image(systemName: "eye")
              .padding(.trailing, 5.0)
          }
        }
      }.modifier(PasswordField(error: passwordError))
      HStack {
        if passwordError {
          Text("Incorrect Password")
            .padding(.leading)
            .foregroundColor(.red)
        }
        Spacer()
        Button("Unlock") {
          if !self.noteData.validatePassword(self.password) {
            self.passwordError = true
          } else {
            self.noteLocked = false
            self.showModal = false
          }
        }.padding()
      }
    }.padding()
  }
}

struct ToggleLock_Previews: PreviewProvider {
  static var previews: some View {
    UnlockView(noteLocked: .constant(false), showModal: .constant(true), noteData: NoteData())
  }
}
