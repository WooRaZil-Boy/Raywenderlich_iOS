/// Copyright (c) 2018 Razeware LLC
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

import UIKit
import SwiftyJSON
import Alamofire

class ViewController: UIViewController {

  // MARK: - IBOutlets
  @IBOutlet var takePictureButton: UIButton!
  @IBOutlet var imageView: UIImageView!
  @IBOutlet var progressView: UIProgressView!
  @IBOutlet var activityIndicatorView: UIActivityIndicatorView!

  // MARK: - Properties
  private var tags: [String]?
  private var colors: [PhotoColor]?

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    if !UIImagePickerController.isSourceTypeAvailable(.camera) {
      takePictureButton.setTitle("Select Photo", for: .normal)
    }
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    imageView.image = nil
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    if segue.identifier == "ShowResults",
      let controller = segue.destination as? TagsColorsViewController {
      controller.tags = tags
      controller.colors = colors
    }
  }

  // MARK: - IBActions
  @IBAction func takePicture(_ sender: UIButton) {
    let picker = UIImagePickerController()
    picker.delegate = self
    picker.allowsEditing = false

    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      picker.sourceType = .camera
    } else {
      picker.sourceType = .photoLibrary
      picker.modalPresentationStyle = .fullScreen
    }

    present(picker, animated: true)
  }
}

// MARK: - UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
    guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
      print("Info did not have the required UIImage for the Original Image")
      dismiss(animated: true)
      return
    }

    imageView.image = image

    takePictureButton.isHidden = true
    progressView.progress = 0.0
    progressView.isHidden = false
    activityIndicatorView.startAnimating()
    //upload 버튼을 숨기고, progress view와 activity view를 표시한다.
    
    upload(image: image,
           progressCompletion: { [weak self] percent in
            self?.progressView.setProgress(percent, animated: true)
            //upload되는 동안, progress handler를 업데이트된 백분율로 호출한다.
            //이는 progress bar의 progress indicator를 업데이트한다.
           }, completion: { [weak self] tags, colors in
            self?.takePictureButton.isHidden = false
            self?.progressView.isHidden = true
            self?.activityIndicatorView.stopAnimating()
            
            self?.tags = tags
            self?.colors = colors
            //upload가 완료되면, completion handler가 실행되어 controls를 원래 state로 되돌린다.
            
            self?.performSegue(withIdentifier: "ShowResults", sender: self)
            //마지막으로 스토리보드는 upload가 완료되거나, 성공적으로 완료되지 않을 때 결과 화면으로 이동한다.
            //user interface는 오류 조건에 따라 변경되지 않는다.
           })
    
    dismiss(animated: true)
  }
}

extension ViewController {
  func upload(image: UIImage,
              progressCompletion: @escaping (_ percent: Float) -> Void,
              completion: @escaping (_ tags: [String]?, _ colors: [PhotoColor]?) -> Void) {
    guard let imageData = UIImageJPEGRepresentation(image, 0.5) else {
      //upload 중인 image를 Data 인스턴스로 변환한다.
      print("Could not get JPEG representation of UIImage")
      return
    }
    
    Alamofire.upload(multipartFormData: { multipartFormData in
      //Imagga의 content endpoint로 보내기 위해, JPEG data blob(imageData)을 MIME multipart request로 변환한다.
      multipartFormData.append(imageData,
                               withName: "imagefile",
                               fileName: "image.jpg",
                               mimeType: "image/jpeg")
    },
//    to: "http://api.imagga.com/v1/content",
//    headers: ["Authorization": "Basic xxx"],
    with: ImaggaRouter.content,
    encodingCompletion: { encodingResult in
      switch encodingResult {
      case .success(let upload, _, _):
        upload.uploadProgress { progress in
          progressCompletion(Float(progress.fractionCompleted))
        }
        upload.validate()
        upload.responseJSON { response in
          guard response.result.isSuccess,
                let value = response.result.value else {
            print("Error while uploading file: \(String(describing: response.result.error))")
            completion(nil, nil)
            return
          }
          //upload가 성공적으로 완료되었는지, result에 value가 있는지 확인한다.
          //그렇지 않은 경우에는 error를 출력하고 completion handler를 호출한다.

          let firstFileID = JSON(value)["uploaded"][0]["id"].stringValue
          //SwiftyJSON을 사용하여, response에서 firstFileID를 검색한다.
          print("Content uploaded with ID: \(firstFileID)")
          
//          completion(nil, nil)
          //completion handler를 호출하여 UI를 update한다.
          //이 시점에서는 다운로드한 tags나 colors이 없으므로 데이터없이 간단하게 호출하면 된다.
          
//          self.downloadTags(contentID: firstFileID) { tags in
//            completion(tags, nil)
//          }
          
          self.downloadTags(contentID: firstFileID) { tags in
            self.downloadColors(contentID: firstFileID) { colors in
              //이미지 업로드, 태그 다운로드, 색상 다운로드 작업 중첩
              completion(tags, colors)
            }
          }
        }
      case .failure(let encodingError):
        print(encodingError)
      }
    })
  }
  
  func downloadTags(contentID: String, completion: @escaping ([String]?) -> Void) {
//    Alamofire.request("http://api.imagga.com/v1/tagging",
//                        parameters: ["content": contentID],
//                        headers: ["Authorization": "Basic xxx"])
      //upload 후 받은 id를 URL parameters 콘텐츠로 하여 tagging 엔드포인트에 대해 HTTP GET request를 수행한다.
      //Basic xxx를 실제 authorization header로 바꾼다.
    Alamofire.request(ImaggaRouter.tags(contentID))
      .responseJSON { response in
        guard response.result.isSuccess,
              let value = response.result.value else {
          //response가 success 인지, result에 value가 있는지 확인한다.
          //그렇지 않은 경우에는 error를 출력한 후 completion handler를 호출한다.
          print("Error while fetching tags: \(String(describing: response.result.error))")
                    completion(nil)
          return
        }
        
        let tags = JSON(value)["results"][0]["tags"].array?.map { json in
          //SwiftyJSON을 사용하여 response에서 tags 배열을 검색한다.
                json["tag"].stringValue
                //tags 배열의 각 dictionary 객체에 대해 반복하여 tag key와 value를 검색한다.
        }
        
        completion(tags)
        //서비스로부터 받은 tags를 전달하는 completion handler를 호출한다.
      }
  }
  
  func downloadColors(contentID: String, completion: @escaping ([PhotoColor]?) -> Void) {
//    Alamofire.request("http://api.imagga.com/v1/colors",
//                      parameters: ["content": contentID],
//                      headers: ["Authorization": "Basic xxx"])
      //upload 후 받은 id를 URL parameters 콘텐츠로 하여 colors 엔드포인트에 대해 HTTP GET request를 수행한다.
      //Basic xxx를 실제 authorization header로 바꾼다.
    Alamofire.request(ImaggaRouter.colors(contentID))
      .responseJSON { response in
        guard response.result.isSuccess,
              let value = response.result.value else {
          //response가 success 인지, result에 value가 있는지 확인한다.
          //그렇지 않은 경우에는 error를 출력한 후 completion handler를 호출한다.
          print("Error while fetching tags: \(String(describing: response.result.error))")
                    completion(nil)
          return
        }
        
        let photoColors = JSON(value)["results"][0]["info"]["image_colors"].array?.map { json in
          //SwiftyJSON을 사용하여 response에서 image_colors 배열을 검색한다.
          PhotoColor(red: json["r"].intValue,
                     green: json["g"].intValue,
                     blue: json["b"].intValue,
                     colorName: json["closest_palette_color"].stringValue)
          //image_colors 배열의 각 dictionary 객체에 대해 반복하여 PhotoColor 객체로 변환한다.
          //이 객체는 RGB 형식의 color와 문자열의 name을 가지고 있다.
        }
        
        completion(photoColors)
        //서비스로부터 받은 photoColors를 전달하는 completion handler를 호출한다.
      }
  }
}







