/// Copyright (c) 2019 Razeware LLC
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

enum PhotoRecordState { //가능한 모든 상태를 나타낸다.
    case new, downloaded, filtered, failed
}

class PhotoRecord {
    let name: String
    let url: URL
    var state = PhotoRecordState.new
    var image = UIImage(named: "Placeholder") //default 이미지
    
    init(name:String, url:URL) {
        self.name = name
        self.url = url
    }
}

//현재 상태와 앱에 표시될 이미지를 나타낸다.




class PendingOperations {
    lazy var downloadsInProgress: [IndexPath: Operation] = [:]
    lazy var downloadQueue: OperationQueue =  {
        var queue = OperationQueue()
        queue.name = "Download queue" //name을 반드시 작성해야 할 필요는 없지만, 디버깅 시에 도움이 된다.
        queue.maxConcurrentOperationCount = 1 //큐에서 한 번에 처리할 수 있는 작업의 수를 정해 준다.
        //반드시 지정할 필요는 없다. 비워두면, 하드웨어에서 가능한 최대로 자동 설정한다.
        
        return queue
    }()
    
    lazy var filtrationsInProgress: [IndexPath: Operation] = [:]
    lazy var filtrationQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Image Filtration queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
}

//각 작업의 상태를 tracking하기 위한 클래스
//이 클래스에는 TableView의 각 행에 대한 다운로드와 필터작업을 tracking 하는 두 개의 Dictionary와 각 유형의 작업에 대한 queue가 포함된다.
//모든 변수는 lazy로 선언되었다. 처음 액세스할 때까지 초기화되지 않으므로 앱 성능을 향상 시킬 수 있다.




class ImageDownloader: Operation {
    let photoRecord: PhotoRecord //객체 참조 추가
    
    init(_ photoRecord: PhotoRecord) { //생성자
        self.photoRecord = photoRecord
    }
    
    override func main() { //Operation이 수행하는 작업 코드 작성
        if isCancelled { //Operation이 취소되었는 지 확인한다. 정기적으로 확인하는 것이 좋다.
            return
        }
        
        guard let imageData = try? Data(contentsOf: photoRecord.url) else { return }
        //이미지를 다운로드 한다.
        
        if isCancelled { //Operation이 취소되었는 지 확인한다. 정기적으로 확인하는 것이 좋다.
            return
        }
        
        if !imageData.isEmpty { //데이터가 있다면
            photoRecord.image = UIImage(data:imageData) //Record에 추가한다.
            photoRecord.state = .downloaded //상태를 downloaded로 변경한다.
        } else { //데이터가 없다면
            photoRecord.state = .failed //상태를 failed로 변경한다.
            photoRecord.image = UIImage(named: "Failed") //실패 이미지로 Record에 추가한다.
        }
    }
}

//추상화된 Operation 서브 클래스. 앞서 정의한 필요한 task 마다ㅏ Operation 서브 클래스를 생성한다.




class ImageFiltration: Operation {
    let photoRecord: PhotoRecord
    
    init(_ photoRecord: PhotoRecord) {
        self.photoRecord = photoRecord
    }
    
    override func main () {
        if isCancelled {
            return
        }
        
        guard self.photoRecord.state == .downloaded else {
            return
        }
        
        if let image = photoRecord.image,
            let filteredImage = applySepiaFilter(image) { //이미지에 필터를 적용한다.
            photoRecord.image = filteredImage
            photoRecord.state = .filtered
        }
    }
    
    func applySepiaFilter(_ image: UIImage) -> UIImage? { //이전 ListViewController 의 메서드와 동일하다.
        //isCancelled을 자주 확인해야 한다.
        guard let data = UIImagePNGRepresentation(image) else { return nil }
        let inputImage = CIImage(data: data)
        
        if isCancelled {
            return nil
        }
        
        let context = CIContext(options: nil)
        
        guard let filter = CIFilter(name: "CISepiaTone") else { return nil }
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(0.8, forKey: "inputIntensity")
        
        if isCancelled {
            return nil
        }
        
        guard let outputImage = filter.outputImage, let outImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        
        return UIImage(cgImage: outImage)
    }
}

//ImageDownloader와 유사하다.


