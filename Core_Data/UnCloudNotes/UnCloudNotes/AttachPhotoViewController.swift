/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import CoreData

class AttachPhotoViewController: UIViewController {

  // MARK: - Properties
  var note : Note?
  lazy var imagePicker : UIImagePickerController = {
    let picker = UIImagePickerController()
    picker.sourceType = .photoLibrary
    picker.delegate = self
    self.addChildViewController(picker)
    return picker
  }()

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    addChildViewController(imagePicker)
    view.addSubview(imagePicker.view)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    imagePicker.view.frame = view.bounds
  }
}

// MARK: - UIImagePickerControllerDelegate
extension AttachPhotoViewController: UIImagePickerControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) { //피커에서 선택한 이미지를 가져온다.
    guard let note = note, let context = note.managedObjectContext else {
      return
    }
    
//    let attachment = Attachment(context: context) //managedObject로 ContextAttachment 생성 //v4에서 삭제
    let attachment = ImageAttachment(context: context) //v4
    //attachment는 note와 연관된 상태에서만 추가된다. 따라서 컨텍스트도 따로 생성할 것 없이 note의 것을 사용하면 된다.
    attachment.dateCreated = Date() //현재 시간
    attachment.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    //info는 원본이미지와 편집된 이미지가 있는 Dictionary. video가 선택되었을 때는 URL이 포함되어 있다.
    attachment.note = note //현재 노트
    attachment.caption = "New Photo" //캡션은 non-optional 이기 때문에 default 값을 지정해 준다.
    
    _ = navigationController?.popViewController(animated: true)
  }
}

// MARK: - UINavigationControllerDelegate
extension AttachPhotoViewController: UINavigationControllerDelegate {
}

// MARK: - NoteDisplayable
extension AttachPhotoViewController: NoteDisplayable {
}
