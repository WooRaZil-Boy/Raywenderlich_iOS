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
import MapKit

class FollowViewController: UIViewController {
  
  // MARK: Variables
  
  let session: TrackingSession
  var socket: WebSocket?
  
  // MARK: View Attributes
  
  let annotation = MKPointAnnotation()
  @IBOutlet weak var mapView: MKMapView!
  
  // MARK: Initializers
  
  init(session: TrackingSession) {
    self.session = session
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    mapView.addAnnotation(annotation)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    startSocket()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    socket?.close()
  }
  
  // MARK: Updates
  
  func startSocket() {
    //사용자가 Poster를 Observe 하려 한다면 응용 프로그램은 traking session id를 요구한다.
    //그 후 startSocket()를 호출해 Observer로 등록하고, Location을 업데이트 한다.
    let ws = WebSocket("ws://\(host)/listen/\(session.id)")
    //사용자가 입력한 tracking session id로 서버에 대한 WebSocket을 연다.
    
    ws.event.close = { [weak self] code, reason, clean in
      //WebSocket이 닫힐 때 호출되는 이벤트 핸들러
      self?.navigationController?.popViewController(animated: true)
    }
    
    ws.event.message = { [weak self] message in
      //WebSocket이 데이터를 수신할 때 호출되는 이벤트 핸들러
      guard let bytes = message as? [UInt8] else {
        fatalError("invalid data")
      }
      
      let data = Data(bytes: bytes)
      let decoder = JSONDecoder()
      
      do {
        let location = try decoder.decode(Location.self, from: data)
        //수신 된 메시지를 위치로 디코드
        self?.focusMapView(location: location)
        //수신된 위치를 지도에 표시
      } catch {
        print("decoding error: \(error)")
      }
    }
  }
  
  func focusMapView(location: Location) {
    let mapCenter = CLLocationCoordinate2DMake(location.latitude, location.longitude)
    annotation.coordinate = mapCenter
    let span = MKCoordinateSpanMake(0.1, 0.1)
    let region = MKCoordinateRegionMake(mapCenter, span)
    mapView.region = region
  }
}
