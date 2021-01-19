//
//  BookViews.swift
//  ReadMe
//
//  Created by youngho on 2021/01/18.
//

import SwiftUI

struct BookmarkButton: View {
  @ObservedObject var book: Book
  //ObservableObject의 변경되는 값을 받아온다.
  
  var body: some View {
    let bookmark = "bookmark"
    Button {
      book.readMe.toggle()
    } label: {
      Image(systemName: book.readMe ? "\(bookmark).fill" : bookmark)
        .font(.system(size: 48, weight: .light))
    }
    //해당 Button은 state에 따라 UI를 업데이트하는데, Book을 struct로 사용하면 변수를 변경할 수 없기 때문에 class로 바꿔준다.
  }
}

struct TitleAndAuthorStack: View {
  let book: Book //state가 변경되는 값이 아니므로, 일반 변수로 사용한다.
  let titleFont: Font
  let authorFont: Font
  
  var body: some View {
    VStack(alignment: .leading) {
      //Attributes Inspector에서 해당 option을 설정해 줄 수도 있다.
      Text(book.title)
        .font(titleFont)
      Text(book.author)
        .font(authorFont)
        .foregroundColor(.secondary)
    }
  }
}

extension Book {
  struct Image: View {
    let uiImage: UIImage?
    let title: String
    var size: CGFloat?
    let cornerRadius: CGFloat
    
    var body: some View {
      if let image = uiImage.map(SwiftUI.Image.init) {
        //UIImage를 mapping하여 SwiftUI.Image를 생성한다.
        image
          .resizable()
          .scaledToFill()
          .frame(width: size, height: size)
          .cornerRadius(cornerRadius)
      } else {
        let symbol = SwiftUI.Image(title: title) ?? .init(systemName: "book")
          //SwiftUI의 Image와 해당 struct의 이름이 같기 때문에 SwiftUI를 붙여줘야 한다.
          //코드 가독성을 위해 예약어를 class나 struct의 이름으로 사용할 경우 위와 같이 쓸 수 있다.
          //책의 title의 첫글자로 image를 생성하고, 첫글자가 없거나 이모지인 경우 system image를 생성한다.
        symbol
          .resizable() //이미지 크기 조절
          .scaledToFit()
          .frame(width: size, height: size)
          //frame에 nil을 입력하면 크기로 view가 지정된다.
          .font(Font.title.weight(.light))
          .foregroundColor(.secondary)
      }
    }
  }
}

struct Book_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      HStack {
        BookmarkButton(book: .init())
        BookmarkButton(book: .init(readMe: false))
        TitleAndAuthorStack(book: .init(), titleFont: .title, authorFont: .title2)
      }
      
      Book.Image(title: Book().title)
      Book.Image(title: "")
      Book.Image(title: "📖")
    }
      .previewdInAllColorSchemes
  }
}

extension Image {
  init?(title: String) {
    //Failable Initializer 초기화가 실패할 수 있다.
    //여기서는 character를 가져올 수 없는 title도 있으므로, init?로 선언한다.
    //optional로 반환되며, String으로 형변환할 때, 변환할 수 없는 경우 nil이 되는 것을 생각하면 된다.
    guard let character = title.first,
          case let symbolName = "\(character.lowercased()).square", //title의 첫 글자를 이미지로 생성한다.
          UIImage(systemName: symbolName) != nil else {
        //이모지의 경우에는 character를 가져오지만, 이에 해당하는 system image를 가져오지 못한다.
        //이 경우를 확인하려면, UIImage를 사용해야 한다.
      return nil
    }
    
    self.init(systemName: symbolName)
  }
}

extension Book.Image {
  /// A preview Image.
  init(title: String) {
    self.init(uiImage: nil, title: title, cornerRadius: .init())
    //cornerRadius를 .init()로 주면 zero로 들어간다.
  }
}

extension View {
  var previewdInAllColorSchemes: some View {
    ForEach(ColorScheme.allCases, id: \.self, content: preferredColorScheme)
    //ColorScheme은 CaseIterable과 Hashable을 준수한다.
  }
}
