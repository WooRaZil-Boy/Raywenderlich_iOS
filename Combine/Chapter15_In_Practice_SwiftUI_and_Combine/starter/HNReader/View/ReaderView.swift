/// Copyright (c) 2019 Razeware LLC
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
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Combine
import SwiftUI

struct ReaderView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme //시스템 환경
    @EnvironmentObject var settings: Settings //custom 환경 주입
    
  @ObservedObject var model: ReaderViewModel
    //@ObservedObject를 사용해 의존 주입 대신, 모델과 연결해 상태가 변경될때마다 업데이트 된다.
  @State var presentingSettingsSheet = false //수정

  @State var currentDate = Date()
    private let timer = Timer.publish(every: 10, on: .main, in: .common)
        .autoconnect()
        .eraseToAnyPublisher()
  
  init(model: ReaderViewModel) {
    self.model = model
  }
  
  var body: some View {
    let filter = "Showing all stories"
    
    return NavigationView {
      List {
        Section(header: Text(filter).padding(.leading, -10)) {
          ForEach(self.model.stories) { story in
            VStack(alignment: .leading, spacing: 10) {
              TimeBadge(time: story.time)
              
              Text(story.title)
                .frame(minHeight: 0, maxHeight: 100)
                .font(.title)
              
              PostedBy(time: story.time, user: story.by, currentDate: self.currentDate)
              
              Button(story.url) {
                print(story)
              }
              .font(.subheadline)
//              .foregroundColor(Color.blue)
                .foregroundColor(self.colorScheme == .light ? .blue : .orange)
                //설정의 모드에 따라 리스트의 링크 색상이 바뀐다.
              .padding(.top, 6)
            }
            .padding()
          }
          // Add timer here
            .onReceive(timer) {
                print("Timer *****")
                self.currentDate = $0
            }
        }.padding()
      }
      // Present the Settings sheet here
        .sheet(isPresented: self.$presentingSettingsSheet, content: {
            SettingsView()
                .environmentObject(self.settings)
            //true일 때 view를 렌더링한다.
        })
      // Display errors here
        .alert(item: self.$model.error) { error in
            Alert(title: Text("Network error"),
                  message: Text(error.localizedDescription),
                  dismissButton: .cancel())
        }
      .navigationBarTitle(Text("\(self.model.stories.count) Stories"))
      .navigationBarItems(trailing:
        Button("Settings") {
          // Set presentingSettingsSheet to true here
            self.presentingSettingsSheet = true
        }
      )
    }
  }
}

#if DEBUG
struct ReaderView_Previews: PreviewProvider {
  static var previews: some View {
    ReaderView(model: ReaderViewModel())
  }
}
#endif
