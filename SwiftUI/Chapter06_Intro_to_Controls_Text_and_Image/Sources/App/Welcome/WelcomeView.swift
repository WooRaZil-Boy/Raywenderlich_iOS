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

struct WelcomeView: View {
    var body: some View {
//        Text("Welcome to Kuchi")
//          .font(.system(size: 30)) //폰트 크기
//          .bold() //굵기
//          .foregroundColor(.red) //색상
//          .lineLimit(2) //줄
//          .multilineTextAlignment(.leading) //정렬
      
//      Image(systemName: "table")
//        .resizable()
//        .frame(width: 30, height: 30)
////        .cornerRadius(30 / 2)
//        //모서리(corner)의 반경(반지름, radius)을 이미지 크기의 절반으로 설정한다.
//        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
//        //얇은 회색 테투리를 추가한다.
//        .background(Color(white: 0.9))
//        //밝은 회색 배경색을 추가한다.
//        .clipShape(Circle())
//        //원 모양으로 과도한 배경을 제거한다.
//        .foregroundColor(.red)
//        //전경색을 빨간색으로 설정한다.
      
      ZStack {
          Image("welcome-background", bundle: nil)
          //추가한 이미지
              .resizable()
              //크기를 조정한다. 기본적으로 SwiftUI는 가로 세로 비율에 대한 고려없이 모든 공간을 원하는 대로 사용하려한다.
//              .scaledToFit()
              //원본 비율로 부모 뷰에서 완전히 표시되도록 이미지를 최대화한다.
              .aspectRatio(1 / 1, contentMode: .fill)
              //비율을 1:1로 설정한다. contentMode를 .fill로 설정하면 이미지가 전체 상위 뷰를 채우므로, 이미지의 일부가 view의 경계를 넘어 확장된다.
              .edgesIgnoringSafeArea(.all)
              //safe area의 insets을 무시하고, 전체 상위에서 공간을 차지하도록 한다.
              //여기에서는 모든 가장자리를 무시하지만, .top, .bottom, .leading, .trailing, .vertical .horizontal와 같이 무시할 가장자리를 배열로 전달할 수 있다.
              //.vertical은 두 개의 수직 가장자리, .horizontal는 두 개의 수평 가장자리를 결합한 것이다.
              .saturation(0.5)
              //이미지의 채도를 줄인다.
              .blur(radius: 5)
              //블러를 추가한다.
              .opacity(0.08)
              //불투명도를 설정한다. 덜 두드러지게 된다.


            HStack {
                Image(systemName: "table")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                    .background(Color(white: 0.9))
                    .clipShape(Circle())
                    .foregroundColor(.red)

                VStack {
                    Text("Welcome to")
//                        .font(.system(size: 30))
                        .font(.headline)
                        .bold()
                        
                    Text("Kuchi")
//                        .font(.system(size: 30))
                        .font(.largeTitle)
                        .bold()
                }
                .foregroundColor(.red)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .padding(.horizontal)
            }
         }
      }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
