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

struct CardView: View {
  typealias CardDrag = (_ card: FlashCard,
                        _ direction: DiscardedDirection) -> Void

  let dragged: CardDrag
  let flashCard: FlashCard
  
  @State var revealed = false
  @State var offset: CGSize = .zero
  @GestureState var isLongPressed = false
  
  init(
    _ card: FlashCard,
    onDrag dragged: @escaping CardDrag = {_,_  in }
  ) {
    self.flashCard = card
    self.dragged = dragged
  }
  
    var body: some View {
      let drag = DragGesture()
        .onChanged { self.offset = $0.translation }
        //drag하는 동안 각 움직임이 기록되면, onChanged 이벤트가 발생한다.
        //user의 drag motion과 일치하도록, offset속성(x, y 좌표)을 수정한다.
        //예를 들어, user가 좌표 공간 (0, 0)에서 드래그하기 시작했고 여전히 (200, -100)에서 드래그 중 일때
        //onChanged가 trigger된 경우 offset은 x 축이 200만큼 증가하고 y 축은 100만큼 감소한다.
        //기본적으로 이는 component가 user 손가락의 움직임과 일치하도록, 화면의 오른쪽 위로 이동한다는 것을 의미한다.
        .onEnded {
          if $0.translation.width < -100 {
            self.offset = .init(width: -1000, height: 0)
            self.dragged(self.flashCard, .left)
          } else if $0.translation.width > 100 {
            self.offset = .init(width: 1000, height: 0)
            self.dragged(self.flashCard, .right)
          } else {
            self.offset = .zero
          }
        //onEnded 이벤트는 user가 드래그를 중지할 때, 일반적으로 screen에서 손가락을 떼면 발생한다.
        //이 시점에서 user가 card를 어느 direction으로 드래그 했고, decision으로 간주될 만큼 충분히 멀리 드래그했는지(decision을 기록하고 card를 discard)
        //또는 아직 decision되지 않은 것으로 간주하는지(card를 원래 좌표로 재설정) 판단한다.
        //user가 드래그하는 동안 left 또는 right을 선택했는지 여부에 대한 decision markers로
        //-1000과 1000을 사용하고 있으며, 해당 decision은 드래그된 closure로 전달된다.
        }
      
      let longPress = LongPressGesture()
        .updating($isLongPressed) { value, state, transition in
          state = value
        }
        .simultaneously(with: drag)

      
      return ZStack { //drag gesture 위해 return 추가
        Rectangle()
          .fill(Color.red)
          .frame(width: 320, height: 210)
          .cornerRadius(12)
        VStack {
          Spacer()
          Text(flashCard.card.question)
            .font(.largeTitle)
            .foregroundColor(.white)
          if self.revealed {
            Text(flashCard.card.answer)
              .font(.caption)
              .foregroundColor(.white)
          }
          Spacer()
        }
      }
      .shadow(radius: 8)
      .frame(width: 320, height: 210)
      .animation(.spring())
      .offset(self.offset)
//      .gesture(drag)
      .gesture(longPress)
      .scaleEffect(isLongPressed ? 1.1 : 1)
      .gesture(TapGesture()
        .onEnded({
          withAnimation(.easeIn, {
            self.revealed = !self.revealed
          })
        })
      )
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        let card = FlashCard(
          card: Challenge(
            question: "Apple",
            pronunciation: "Apple",
            answer: "Omena"
          )
        )
        return CardView(card)
    }
}




