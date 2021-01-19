//
//  NewBookView.swift
//  ReadMe
//
//  Created by youngho on 2021/01/18.
//

import SwiftUI

struct NewBookView: View {
  @ObservedObject var book = Book(title: "", author: "")
  @State var image: UIImage? = nil
  @EnvironmentObject var library: Library
  //@ObservedObject로 사용할 수도 있지만 동일한 object가 반복된다면, @EnvironmentObject를 사용하는 것이 좋다.
  //@EnvironmentObject를 사용하면, 앱의 어느 곳에서나 사용가능하도록 binding 된다.
  @Environment(\.presentationMode) var presentationMode
  //keyPaht로 지정하여 type을 유추할 수 있으므로, type을 따로 지정해 줄 필요 없다.
  //presentationMode는 현재 View가 presented 인지 여부를 알려준다.
  
  var body: some View {
    NavigationView { //ToolBar를 추가하기 위해 필요하다.
      VStack(spacing: 24) {
        TextField("Title", text: $book.title)
        TextField("Author", text: $book.author)
        ReviewAndImageStack(book: book, image: $image)
      }
        .padding()
        .navigationBarTitle("Got a new book?")
        .toolbar {
          ToolbarItem(placement: .status) { //.bottomBar를 사용하면 좌측정렬된다.
            Button("Add to Library") {
              library.addNewBook(book, image: image)
              presentationMode.wrappedValue.dismiss() //현재 View를 dismiss한다.
            }
              .disabled(
                [book.title, book.author].contains(where: \.isEmpty)
                //title과 author 중 하나라도 비어 있다면, 해당 Button이 disabled 상태가 된다.
              )
          }
        }
    }
  }
}

struct NewBookView_Previews: PreviewProvider {
  static var previews: some View {
    NewBookView()
      .environmentObject(Library())
  }
}
