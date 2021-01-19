//
//  DetailView.swift
//  ReadMe
//
//  Created by youngho on 2021/01/18.
//

import SwiftUI

struct DetailView: View {
  @ObservedObject var book: Book
//  @Binding var image: UIImage?
  @EnvironmentObject var library: Library
  //image 대신 Library를 참조한다.
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack(spacing: 16.0) {
        BookmarkButton(book: book)
        TitleAndAuthorStack(book: book,
                            titleFont: .title,
                          authorFont: .title2)
      }
      ReviewAndImageStack(book: book, image: $library.uiImages[book])
    }
      .padding()
  }
}

struct DetailView_Previews: PreviewProvider {
  static var previews: some View {
    DetailView(book: .init())
      .environmentObject(Library())
      .previewdInAllColorSchemes
  }
}
