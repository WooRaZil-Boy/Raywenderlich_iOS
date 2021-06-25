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

struct CongratulationsView: View {
  let avatarSize: CGFloat = 120
  let userName: String
  
  // Add this property
  @ObservedObject
  var challengesViewModel = ChallengesViewModel()

  init(userName: String) {
    self.userName = userName
  }
  
  var body: some View {
//    EmptyView()
    VStack {
      Spacer() //추가
      Text("Congratulations!")
        .font(.title)
        .foregroundColor(.gray)
      ZStack {
        //ZStack을 사용하여 콘텐츠를 올린다.
        VStack(spacing: 0) { //맨 아래 레이어(먼저 추가)는 배경으로, 두 부분으로 나뉜다.
          Rectangle()
            .frame(height: 90)
            .foregroundColor(Color(red: 0.5, green: 0, blue: 0).opacity(0.2))
            //각각 90의 고정 높이와 다른 배경색을 가진다.
          Rectangle()
            .frame(height: 90)
            .foregroundColor(Color(red: 0.6, green: 0.1, blue: 0.1).opacity(0.4))
            //각각 90의 고정 높이와 다른 배경색을 가진다.
              
            //이 Rectangle들이 VStack의 높이를 결정한다.
        }
        Image(systemName: "person.fill")
          .resizable()
          .padding()
          .frame(width: avatarSize, height: avatarSize)
          .background(Color.white.opacity(0.5))
          .cornerRadius(avatarSize / 2, antialiased: true)
          .shadow(radius: 4)
          //사용자 아바타
        VStack() {
          Spacer() //텍스트를 맨 아래로 미는데 사용한다.
          Text(userName)
            .font(.largeTitle)
            .foregroundColor(.white)
            .fontWeight(.bold)
            .shadow(radius: 7)
        }
        .padding()
        //사용자 이름
      }
      .frame(height: 180)
      //전체 ZStack의 고정 높이
      Text("You’re awesome!")
        .fontWeight(.bold)
        .foregroundColor(.gray)
      Spacer() //Spcaer를 추가해 상단으로 민다.
      Button(action: {
        self.challengesViewModel.restart()
      }, label: {
        Text("Play Again")
      })
        .padding(.top)
    }
  }
}

struct CongratulationsView_Previews: PreviewProvider {
  static var previews: some View {
    CongratulationsView(userName: "Johnny Swift")
      .environmentObject(ChallengesViewModel())
  }
}
