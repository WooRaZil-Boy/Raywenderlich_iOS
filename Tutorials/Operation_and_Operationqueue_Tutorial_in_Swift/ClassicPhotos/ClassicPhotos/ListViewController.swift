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
import CoreImage

let dataSourceURL = URL(string:"http://www.raywenderlich.com/downloads/ClassicPhotosDictionary.plist")!

class ListViewController: UITableViewController {
//  lazy var photos = NSDictionary(contentsOf: dataSourceURL)! //웹에서 처음 request되었을 때 사진 목록을 로드한다.
    var photos: [PhotoRecord] = []
    let pendingOperations = PendingOperations()
    //Operation을 사용하도록 교체
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Classic Photos"
    
    fetchPhotoDetails()
  }
  
  // MARK: - Table view data source

  override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
    return photos.count
  }
  
//  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//    let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
//    let rowKey = photos.allKeys[indexPath.row] as! String
//
//    var image : UIImage?
//
//    guard let imageURL = URL(string:photos[rowKey] as! String),
//      let imageData = try? Data(contentsOf: imageURL) else {
//        return cell
//    }
//
//    let unfilteredImage = UIImage(data:imageData) //웹에서 이미지 다운로드
//    image = self.applySepiaFilter(unfilteredImage!) //세피아 필터 적용
//
//    // Configure the cell...
//    cell.textLabel?.text = rowKey
//    if image != nil {
//      cell.imageView?.image = image!
//    }
//
//    return cell
//  }
  
  // MARK: - image processing

  func applySepiaFilter(_ image:UIImage) -> UIImage? {
    let inputImage = CIImage(data:UIImagePNGRepresentation(image)!)
    let context = CIContext(options:nil)
    let filter = CIFilter(name:"CISepiaTone")
    filter?.setValue(inputImage, forKey: kCIInputImageKey)
    filter!.setValue(0.8, forKey: "inputIntensity")

    guard let outputImage = filter!.outputImage,
      let outImage = context.createCGImage(outputImage, from: outputImage.extent) else {
        return nil
    }
    return UIImage(cgImage: outImage)
  }
}

//메인 스레드의 작업을 concurrency로 옮겨, concurrency가 동시에 여러 작업 스트림(스레드)를 실행하도록 한다.
//이렇게 처리하면, 작업 중에 UI가 계속 반응한다.
//iOS에서 concurrency를 처리하는 방법 중 하나는 Operation 과 OperationQueue를 사용하는 것이다.




//Getting Started
//이 앱의 목표는 필터링된 이미지를 TableView에 표시하는 것이다. 이미지는 인터넷에서 다운로드 되어, 필터링 된 이후 TableView에 표시된다.




//A First Try
//처음 start 버전은 스크롤 할 때마다 인터넷에서 이미지를 다운로드하며, 다운로드가 끝날 때까지 앱이 멈춘다.
//웹에서 이미지를 로드하고 세피아 필터링을 적용하는 모든 작업이 메인 스레드에서 처리되기 때문이다.
//메인스레드는 사용자와 상호작용을 처리하는데, 과도한 작업(이미지 로드, 필터링)을 처리하도록 했기 때문에 앱의 반응을 멈추게 된다.
//Debug navigator (Command-7) 을 사용해, 앱이 실행되는 동안 CPU와 메모리의 사용량을 측정해 볼 수 있다.
//여기서 Thread 1이 메인 스레드이다.




//Tasks, Threads and Processes
// • Task : 수행해야할 작업
// • Thread : 운영체제에서 제공하는 매커니즘으로 단일 응용 프로그램 내에서 여러 명령어 세트가 동시에 작동할 수 있다.
// • Process : 여러 스레드로 구성될 수 있는 코드의 실행 가능한 청크
//Foundation의 Thread를 직접 사용할 수 있지만, 여러 스레드를 나눠 관리하는 것은 어려운 작업이다.
//Operation과 OperationQueue는 여러 스레드를 처리하는 프로세스를 단순화한 상위 수준의 클래스이다.
//프로세스는 여러 스레드의 실행을 포함할 수 있으며, 각 스레드는 한 번에 하나씩 여러 작업을 수행할 수 있다.
//메인 스레드는 UI 인터페이스와 관련된 작업을 하고, 보조 스레드는 파일 읽기, 네트워크 액세스 등과 같이 느리고 오래 걸리는 작업을 담당하는 경우가 많다.




//Operation vs. Grand Central Dispatch (GCD)
//GCD는 iOS와 macOS의 멀티 코어 하드웨어에서 concurrency를 지원하기 위한 체계적이고 포괄적인 시스템이다.
//Operation과 OperationQueue는 GCD의 최상위에 위치한 클래스이다.
//Apple은 최상위의 추상화 객체를 사용하고, 필요한 경우에 더 낮은 수준의 객체를 사용할 것을 권장한다.
//GCD와 Operation을 어떤 경우에 사용하면 좋을 지에 대한 비교는 다음과 같다.
// • GCD : concurrency 작업 단위를 나타내는 간단한 방법이다. 이 작업 단위(UOW)는 개발자가 아닌 시스템이 관리한다.
//  블록 사이에 의존성을 추가하는 것은 복잡하며, 취소 일시 중단 시에 개발자가 추가적인 작업을 해줘야 한다.
// • Operation : GCD에 비해 약간의 오버헤드가 추가되지만, 다양한 작업간에 의존성을 추가하고, 재사용, 취소, 일시 중단할 수 있다.
//이 앱에서는 사용자가 이미지를 스크롤한 경우 특정 이미지에 대한 작업을 취소할 수 있는 기능이 필요하기 때문에, Operation이 필요하다.
//작업이 background thread에서 처리된다 하더라도, 큐에 대기중인 스레드가 여러 개 있다면 성능이 저하된다.




//Refined App Model
//현재 프로그램의 병목현상을 제거하려면, UI 상호작용에 응답하는 스레드, 데이터 소스 및 이미지 다운로드 전용 스레드, 이미지 필터링 스레드가 필요하다.
//새로운 앱 모델에서는 앱이 메인 스레드에서 시작하여 빈 TableView를 로드한다. 동시에 두 번째 스레드로 데이터 소스를 다운로드 한다.
//데이터 소스가 다운로드 되면 TableView가 이를 로드한다. 이 작업은 UI를 포함하고 있기 때문에 메인 스레드에서 실행되어야 한다.
//이 시점에서 TableView는 얼마나 많은 행이 필요하고, 표시해야 하는 이미지의 URL을 알고 있지만, 실제 이미지는 아직 없는 상태이다.
//모든 이미지가 필요한 것이 아니므로, 모든 이미지를 한 번에 다운로드 하는 것이 아니라 현재 보여지는 행에 대한 이미지만 다운로드 하는 것이 좋다.
//따라서 먼저 TableView에 어떤 행이 보이는지 알아내고 다운로드를 시작한다. 이미지 필터링 작업은 이미지가 완전히 다운로드 되기 전에 시작할 수 없다.
//따라서 처리 대기중인 필터링 되지 않은 이미지가 있을 때까지 앱에서 이미지 필터링 작업을 시작해서는 안 된다.
//이를 처리하기 위해, 이미지 다운로드 여부, 필터링 여부를 tracking해야 한다.
//각 작업의 상태와 유형을 tracking해야 하므로, 사용자가 스크롤 할 때 각 작업을 취소, 일시 중지 또는 다시 시작할 수 있도록 해야 한다.




extension ListViewController {
    func fetchPhotoDetails() {
        let request = URLRequest(url: dataSourceURL)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true //status 창에 download spinner 가 보이도록 한다.
        
        let task = URLSession(configuration: .default).dataTask(with: request) { data, response, error in
            //URLSession이 background 스레드의 이미지 property List를 다운로드하는 dataTask를 생성한다.

            let alertController = UIAlertController(title: "Oops!", message: "There was an error fetching photo details.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(okAction)
            //오류 발생 시 사용할 UIAlertController
            
            if let data = data {
                do {
                    let datasourceDictionary = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [String: String]
                    //request가 성공하면, property List로 Dictionary를 만든다.
                    //이미지 파일명을 key로 사용하고, URL을 value로 사용한다.
                    
                    for (name, value) in datasourceDictionary {
                        let url = URL(string: value)
                        if let url = url {
                            let photoRecord = PhotoRecord(name: name, url: url)
                            self.photos.append(photoRecord)
                        }
                    }
                    //저장한 값으로 PhotoRecord를 생성해 배열에 추가한다.
                    
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        self.tableView.reloadData()
                    }
                    //메인 스레드에서 TableView를 다시 로드하고 이미지를 표시한다.
                } catch {
                    DispatchQueue.main.async {
                        self.present(alertController, animated: true, completion: nil)
                        //오류가 발생하면 AlertConroller를 표시한다. 메인 스레드에서 실행되어야 한다.
                    }
                }
            }
            
            if error != nil {
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.present(alertController, animated: true, completion: nil)
                    //오류가 발생하면 AlertConroller를 표시한다. 메인 스레드에서 실행되어야 한다.
                }
            }
        }
        
        task.resume() //다운로드 작업을 실행한다.
    }
}

//extension ListViewController {
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
//
//        if cell.accessoryView == nil {
//            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
//            cell.accessoryView = indicator
//        }
//        let indicator = cell.accessoryView as! UIActivityIndicatorView
//        //UIActivityIndicatorView로 사용자에게 피드백을 전달한다.
//
//        let photoDetails = photos[indexPath.row] //indexPath로 해당 데이터 소스의 객체를 가져온다.
//
//        cell.textLabel?.text = photoDetails.name
//        cell.imageView?.image = photoDetails.image
//        //cell에 데이터를 설정한다.
//
//        switch photoDetails.state { //state에 따라 작업을 처리한다.
//        case .filtered:
//            indicator.stopAnimating()
//        case .failed:
//            indicator.stopAnimating()
//            cell.textLabel?.text = "Failed to load"
//        case .new, .downloaded:
//            indicator.startAnimating()
//            startOperations(for: photoDetails, at: indexPath)
//        }
//
//        return cell
//    }
//}

extension ListViewController {
    func startOperations(for photoRecord: PhotoRecord, at indexPath: IndexPath) {
        switch photoRecord.state { //사진의 state에 따라 작업을 처리한다.
        case .new:
            startDownload(for: photoRecord, at: indexPath) //다운로드
        case .downloaded:
            startFiltration(for: photoRecord, at: indexPath) //필터링
        default:
            NSLog("do nothing")
        }
    }
    //다운로드와 필터링은 따로 구현된다. 이미지를 다운로드 하는 동안 유저가 스크롤을 멈춰 아직 필터를 적용하지 않았을 가능성이 있기 때문이다.
    //다시 스크롤을 하면, 다운로드 없이 필터링만 적용할 수 있다.
    
    func startDownload(for photoRecord: PhotoRecord, at indexPath: IndexPath) {
        guard pendingOperations.downloadsInProgress[indexPath] == nil else { return }
        //해당 indexPath로 downloadsInProgress의 작업이 있는지 확인한다. //nil 이어야(작업이 없어야) 한다.
        
        let downloader = ImageDownloader(photoRecord) //인스턴스 생성
        
        downloader.completionBlock = { //작업이 완료되면 실행되는 completionBlock.
            if downloader.isCancelled { //completionBlock은 작업이 취소된 경우에도 실행되므로 취소 여부를 확인해야 한다.
                return
            }
            
            DispatchQueue.main.async { //UI 업데이트는 메인 스레드에서 진행해야 한다.
                self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
        
        pendingOperations.downloadsInProgress[indexPath] = downloader //tracking을 위한 작업 추가
        pendingOperations.downloadQueue.addOperation(downloader) //작업을 큐에 추가한다.
        //추가하고 나면, queue에서 일정을 관리한다.
    }
    
    func startFiltration(for photoRecord: PhotoRecord, at indexPath: IndexPath) { //startDownload와 유사하다.
        guard pendingOperations.downloadsInProgress[indexPath] == nil else { return }
        
        let filter = ImageFiltration(photoRecord)
        filter.completionBlock = {
            if filter.isCancelled {
                return
            }
            
            DispatchQueue.main.async {
                self.pendingOperations.filtrationsInProgress.removeValue(forKey: indexPath)
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
        
        pendingOperations.filtrationsInProgress[indexPath] = filter
        pendingOperations.filtrationQueue.addOperation(filter)
    }
}




//Fine Tuning
//현재까지 구현한 코드에서는 TableView에서 스크롤할 때, off screen cell은 계속 다운로드 및 필터링한다.
//빠르게 스크롤하면, 이 작업들을 확인해 볼 수 있다. 이상적으로는 off screen cell의 필터링을 취소하고, 표시된 cell의 우선 순위를 지정해 줘야 한다.
//cancel을 활용한다.
extension ListViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
        
        if cell.accessoryView == nil {
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            cell.accessoryView = indicator
        }
        let indicator = cell.accessoryView as! UIActivityIndicatorView
        //UIActivityIndicatorView로 사용자에게 피드백을 전달한다.
        
        let photoDetails = photos[indexPath.row] //indexPath로 해당 데이터 소스의 객체를 가져온다.
        
        cell.textLabel?.text = photoDetails.name
        cell.imageView?.image = photoDetails.image
        //cell에 데이터를 설정한다.
        
        switch photoDetails.state { //state에 따라 작업을 처리한다.
        case .filtered:
            indicator.stopAnimating()
        case .failed:
            indicator.stopAnimating()
            cell.textLabel?.text = "Failed to load"
        case .new, .downloaded:
            indicator.startAnimating()
            if !tableView.isDragging && !tableView.isDecelerating { //이 부분만 새로 추가
                //TableView가 스크롤 되지 않은 경우에만 작업을 operation을 시작한다.
                //실제로는 UIScrollView에서 작동한다.
                startOperations(for: photoDetails, at: indexPath)
            }
        }
        
        return cell
    }
}

extension ListViewController {
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) { //스크롤을 시작하면,
        suspendAllOperations() //모든 작업 일시 중단
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate { //감속이 아니라면 (TableView 드래그를 중지했음을 의미)
            loadImagesForOnscreenCells() //보이는 cell에 대하여 작업
            resumeAllOperations() //일시 중단된 작업 다시 시작
        }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) { //TableView 스크롤 중지
        loadImagesForOnscreenCells()
        resumeAllOperations()
    }
}

extension ListViewController {
    func suspendAllOperations() { //일시 정지
        pendingOperations.downloadQueue.isSuspended = true
        pendingOperations.filtrationQueue.isSuspended = true
    }
    
    func resumeAllOperations() { //재개
        pendingOperations.downloadQueue.isSuspended = false
        pendingOperations.filtrationQueue.isSuspended = false
    }
    
    func loadImagesForOnscreenCells() {
        if let pathsArray = tableView.indexPathsForVisibleRows { //현재 보이는 모든 행의 indexPath를 배열로 반환한다.
            var allPendingOperations = Set(pendingOperations.downloadsInProgress.keys) //진행중인 다운로드
            allPendingOperations.formUnion(pendingOperations.filtrationsInProgress.keys) //진행중인 필터링
            //합집합으로 합친다.
            
            var toBeCancelled = allPendingOperations //취소할 작업의 indexPaths
            let visiblePaths = Set(pathsArray) //현재 보이는 indexPaths
            toBeCancelled.subtract(visiblePaths) //차집합으로 취소해야할 indexPaths(off screen cell)만 남겨둔다.
            
            var toBeStarted = visiblePaths
            toBeStarted.subtract(allPendingOperations)
            //보이는 indexPaths에서 진행중인 작업 indexPath를 차집합으로 빼서 다시 재개해야하는 indexPath를 가져온다.
            
            for indexPath in toBeCancelled { //취소할 대상 반복
                if let pendingDownload = pendingOperations.downloadsInProgress[indexPath] {
                    pendingDownload.cancel()
                }
                pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
                if let pendingFiltration = pendingOperations.filtrationsInProgress[indexPath] {
                    pendingFiltration.cancel()
                }
                pendingOperations.filtrationsInProgress.removeValue(forKey: indexPath)
            }
            //참조를 제거한다.
            
            for indexPath in toBeStarted { //다시 재개해야 하는 대상 반복
                let recordToProcess = photos[indexPath.row]
                startOperations(for: recordToProcess, at: indexPath)
            }
        }
    }
}




//Where to Go From Here?
//Operation과 OperationQueue를 사용해 코드를 효율적으로 유지보수할 수 있지만, 중첩된 멀티 스레딩 코드를 남발하면 관리하기 힘들어 질 수 있다.
//작업 이후, 테스트와 함께 Instruments로 성능 측정이 필요하다.
//여기서 다루지 않은 Operation의 유용한 작업은 종속성이다. 하나 이상의 다른 Operation에 종속성을 줄 수 있다.
//이 Operation은 종속된 모든 Operation이 완료되기 전까지 시작하지 않는다.

//// MyDownloadOperation is a subclass of Operation
//let downloadOperation = MyDownloadOperation()
//// MyFilterOperation  is a subclass of Operation
//let filterOperation = MyFilterOperation()
//
//filterOperation.addDependency(downloadOperation)

//종속성을 제거하려면 다음과 같이 사용한다.
//filterOperation.removeDependency(downloadOperation)





