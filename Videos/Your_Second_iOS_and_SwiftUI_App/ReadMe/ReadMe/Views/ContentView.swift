//
//  ContentView.swift
//  ReadMe
//
//  Created by youngho on 2021/01/18.
//

import SwiftUI

struct ContentView: View {
  @State var addingNewBook = false
//  @State var library = Library() //Refactor > Extract to Variable을 사용해 추출해낼 수 있다.
  @EnvironmentObject var library: Library
  //@State 대신 @EnvironmentObject를 사용한다.
  
  var body: some View {
    NavigationView {
      //NavigationView와 NavigationLink를 함께 사용해야 한다.
//      List(library.sortedBooks, id: \.self) { book in
        //⌘ + click으로 Embeded in List를 선택할 수 있다.
        //List에서는 id로 사용할 변수를 지정해 줘야 한다.
      List {
        //List와 ForEach를 비슷하게 생각하지만, List는 similar views를 보여주기 만을 위한 collection이 아니다.
        //List는 반복되지 않더라도, 어떠한 View도 row의 column으로 만들 수 있다.
        Button {
          addingNewBook = true
        } label: {
          Spacer()
          VStack (spacing: 6.0) {
            Image(systemName: "book.circle")
              .font(.system(size: 60))
            Text("Add New Book")
              .font(.title2)
          }
          Spacer()
        }
          .buttonStyle(BorderlessButtonStyle())
          .padding(.vertical, 8)
          .sheet(isPresented: $addingNewBook, content: NewBookView.init)
        
//        ForEach(library.sortedBooks) { book in //Book이 Identifiable을 준수하므로, id를 따로 지정해 줄 필요 없다.
//          //실제로, ForEach를 대신 사용하면, 컴파일은 되지만, 하나의 거대한 View만이 보여진다.
//          //따라서, ForEach를 사용한다면, List로 이를 감싸서 사용해야 한다.
//
//  //        BookRow(book: .init())
//          BookRow(book: book)
//        }
        
        switch library.sortStyle {
        case .title, .author:
          BookRows(data: library.sortedBooks, section: nil)
        case .manual:
          ForEach(Section.allCases, id: \.self) {
            SectionView(section: $0)
            //해당 경우에만 move할 수 있도록 한다.
          }
        }
      }
        .toolbar{
          ToolbarItem(placement: .navigationBarLeading) {
            Menu("Sort") {
              Picker("Sort Style", selection: $library.sortStyle) {
                ForEach(SortStyle.allCases, id: \.self) { sortStyle in
                  Text("\(sortStyle)".capitalized)
                }
              }
            }
          }
          ToolbarItem(content: EditButton.init) //우측 상단에 EditButton을 추가한다.
        }
        .navigationBarTitle("My Library") //title을 지정해 준다.
        //NavigationView가 아닌, 내부의 Link에 modifier를 연결해야 한다.
    }
    //⌘ + click으로 Group을 먼저 지정한 다음, Extract subview를 해야한다.
    //그렇지 않고 HStack에서 바로 Extract subview를 하려 하면, 하나의 View만 남기 때문에 해당 옵션이 보이지 않는다.
  }
}

private struct BookRows: DynamicViewContent {
  //BookRows가 onMove를 수행할 수 있도록 하려면, DynamicViewContent 유형이여야 한다.
  //DynamicViewContent를 준수하려면, data 변수를 구현해야 한다.
//  let books: [Book]
  let data: [Book]
  //여기서는 books를 data로 변경해 준다. Refactor를 사용하면 쉽게 변경할 수 있다.
  let section: Section?
  @EnvironmentObject var library: Library
  
  var body: some View {
    ForEach(data) {
      BookRow(book: $0)
    }
      .onDelete { indexSet in //multi delete는 아직 지원하지 않는다.
        library.deleteBooks(atOffsets: indexSet, section: section)
      }
  }
}

private struct BookRow: View {
  @ObservedObject var book: Book //state가 변경되는 값이 아니므로, 일반 변수로 사용한다.
//  @Binding var image: UIImage?
  @EnvironmentObject var library: Library
  
  var body: some View {
    NavigationLink(destination: DetailView(book: book)) {
      //NavigationView와 NavigationLink를 함께 사용해야 한다.
      HStack {
        Book.Image(uiImage: library.uiImages[book], title: book.title, size: 80, cornerRadius: 12)
        VStack(alignment: .leading) {
          TitleAndAuthorStack(book: book,
                              titleFont: .title2,
                              authorFont: .title3)
          if !book.microReview.isEmpty {
            Spacer()
            Text(book.microReview)
              .font(.subheadline)
              .foregroundColor(.secondary)
          }
        }
          .lineLimit(1)
        Spacer()
        BookmarkButton(book: book)
          .buttonStyle(BorderlessButtonStyle())
          //button style을 변경하여 색상이 적용되도록 한다.
      }
        .padding(.vertical, 8)
    }
  }
}

//해당 View를 ⌘ + click 하고, Extract subview를 사용하여 쉽게 subview를 생성할 수 있다.
//버그인 것 같은데, canvas의 preview가 활성화된 상태에서만 해당 Extract subview 옵션이 나타난다.

//해당 View를 ⌃ + ⌥ + click 하여 Attributes Inspector를 바로 pop-up으로 호출할 수 있다.

//⇧ + ⌘ + L 을 사용하여 Library 창을 열 수 있다.

//Asset Catalog에서 앱 전체에서 사용할 AccentColor를 지정해 줄 수 있다.

//dark 모드에서 주의해야 할 점은 PHPicker가 Light 모드로 호출된다는 것이다.
//이 때 accent color가 Light 모드에 맞춰 변경되며, 다시 Dark 모드로 돌아오지 않는 버그가 있다.

//⌃ + ⇧ 을 누른 상태로 화살표를 이동하여, 다중 라인을 선택할 수 있다.

private struct SectionView: View {
  let section: Section
  @EnvironmentObject var library: Library
  
  var title: String {
    switch section {
    case .readMe:
      return "Read Me!"
    case .finished:
      return "Finished!"
    }
  }
  
  var body: some View {
    if let books = library.manuallySortedBooks[section] {
      SwiftUI.Section(
        header:
          ZStack {
            Image("BookTexture")
              .resizable()
              .scaledToFit()
            Text(title)
              .font(.custom("American Typewriter", size: 24))
          }
            .listRowInsets(.init())
      ) {
        BookRows(data: books, section: section)
          .onMove { indices, newOffset in
            //BookRows가 onMove를 수행할 수 있도록 하려면, DynamicViewContent 유형이여야 한다.
            library.moveBooks(oldOffsets: indices, newOffset: newOffset, section: section)
          }
//          .moveDisabled(section == .none)
          //section이 .none 일때, move를 할 수 없다.
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .environmentObject(Library())
      .previewdInAllColorSchemes
  }
}
