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
import SystemConfiguration

class ViewController: UIViewController {
    private let reachability = SCNetworkReachabilityCreateWithName(nil, "www.raywenderlich.com")
    //네트워크가 사용 가능한지 여부를 알기 위해 실제 DNS에 존재하는 Host 명을 기입해서 연결 테스트를 해야 한다(IPv4, IPv6 모두 가능하다).
    //실제 해당 Domain 서버로 연결 상 부하는 발생하지 않으며 네트워크 연결 상태만 확인한다.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.checkReachable()
    }
    
    private func checkReachable()
    {
        var flags = SCNetworkReachabilityFlags() //네트워크 노드 이름 또는 주소의 연결 가능성을 나타내는 플래그
        SCNetworkReachabilityGetFlags(self.reachability!, &flags)
        //네트워크 구성을 사용해 지정된 네트워크에 연결할 수 있는지 확인한다. T/F를 반환한다.
        //&flag로 포인터를 매개 변수로 입력해 줘야 한다. 지정된 네트워크에 대한 연결 가능성에 대한 정보를 채워 넣는다.
        
        if (isNetworkReachable(with: flags)) //단순히 SCNetworkReachabilityGetFlags를 호출했을 때 T/F로 판단할 수도 있다.
            //하지만, SCNetworkReachabilityFlags의 정보로 상세한 상태를 알 수 있다.
        {
            print (flags)
            if flags.contains(.isWWAN) {
                self.alert(message:"via mobile",title:"Reachable")
                return
            }
            
            self.alert(message:"via wifi",title:"Reachable")
        }
        else if (!isNetworkReachable(with: flags)) {
            self.alert(message:"Sorry no connection",title: "unreachable")
            print (flags)
            return
        }
    }
    
    
    private func isNetworkReachable(with flags: SCNetworkReachabilityFlags) -> Bool {
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        let canConnectAutomatically = flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)
        let canConnectWithoutUserInteraction = canConnectAutomatically && !flags.contains(.interventionRequired)
        return isReachable && (!needsConnection || canConnectWithoutUserInteraction)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension UIViewController
{
    func alert(message: String, title: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        
        DispatchQueue.main.async  {
               self.present(alertController, animated: true, completion: nil)
        }
    }
}

//많은 앱이 네트워크를 사용하지만, 디바이스가 네트워크에 연결되어 있지 않은 경우도 생각해야 한다.
//네트워크를 사용하는 function 전에 반드시 네트워크가 사용 가능한 상태인지 확인해 줘야 한다.

//1. SCNetworkReachabilityCreateWithName 로 테스트할 도메인을 설정한다.
//2. SCNetworkReachabilityFlags 네트워크에 연결 가능한지 값을 저장하는 플래그를 생성한다.
//3. SCNetworkReachabilityGetFlags 로 해당 네트워크에 연결 가능한지 검사한다.




//Reachability.swift 에는 오픈소스로 제작된 Reachability 코드가 있다. https://github.com/ashleymills/Reachability.swift
//이를 사용한 코드는 ReachabilityViewController에서 구현

