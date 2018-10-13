//
//  ReachabilityViewController.swift
//  Reachability
//
//  Created by 근성가이 on 03/10/2018.
//  Copyright © 2018 Material Cause LLC. All rights reserved.
//

import UIKit
import SystemConfiguration

class ReachabilityViewController: UIViewController {
    private let reachability = Reachability()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setReachabilityNotifier()
    }

    private func setReachabilityNotifier () {
     //declare this inside of viewWillAppear
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do {
            try reachability.startNotifier()
            
        } catch {
            print("could not start reachability notifier")
        }
    }

    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            print("Reachable via WiFi")
        case .cellular:
            print("Reachable via Cellular")
        case .none:
            print("Network not reachable")
        }
        
        self.reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability) //옵저버 제거
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//많은 앱이 네트워크를 사용하지만, 디바이스가 네트워크에 연결되어 있지 않은 경우도 생각해야 한다.




//Reachability.swift 에는 오픈소스로 제작된 Reachability 코드가 있다. https://github.com/ashleymills/Reachability.swift


