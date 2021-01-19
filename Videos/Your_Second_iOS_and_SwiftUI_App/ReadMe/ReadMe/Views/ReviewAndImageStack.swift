//
//  ReviewAndImageStack.swift
//  ReadMe
//
//  Created by youngho on 2021/01/18.
//

import SwiftUI
import class PhotosUI.PHPickerViewController

struct ReviewAndImageStack: View {
  @ObservedObject var book: Book
  @Binding var image: UIImage?
  @State var showingImagePicker = false
  @State var showingAlert = false
  
  var body: some View {
    VStack {
      Divider()
        .padding(.vertical)
      TextField("Review...", text: $book.microReview)
      Divider()
        .padding(.vertical)
      Book.Image(uiImage: image, title: book.title, cornerRadius: 16)
        .scaledToFit()
      
      let updateButton =
        Button("Update Image...") { //trailing closure로 쓸 수도 있다.
          showingImagePicker = true
        }
        .padding()
      
      if image != nil {
        HStack {
          Spacer()
          Button("Delete Image") { //trailing closure로 쓸 수도 있다.
            showingAlert = true
          }
          Spacer()
          updateButton
          Spacer()
        }
      } else {
        updateButton
      }
      
      Spacer()
    }
      .sheet(isPresented: $showingImagePicker) {
        PHPickerViewController.View(image: $image)
      }
      .alert(isPresented: $showingAlert) {
        .init(title: .init("Delete image for \(book.title)?"),
              primaryButton: .destructive(.init("Delete")) {
                //trailling closure로 쓸 수 있다.
                image = nil
              },
              secondaryButton: .cancel())
      }
      //Text 등의 타입이 명확할 때, .init로 사용할 수 있다.
  }
}

struct ReviewAndImageStack_Previews: PreviewProvider {
  static var previews: some View {
    ReviewAndImageStack(book: .init(), image: .constant(nil))
      .padding(.horizontal)
      .previewdInAllColorSchemes
  }
}
