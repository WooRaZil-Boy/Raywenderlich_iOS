//
//  AboutViewController.swift
//  BullsEye
//
//  Created by 근성가이 on 2016. 10. 22..
//  Copyright © 2016년 근성가이. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = Bundle.main.url(forResource: "BullsEye", withExtension: "html") { //메인 번들에 BullsEye.html이 있으면
            if let htmlData = try? Data(contentsOf: url) { //그 파일에서 데이터 불러오기
                let baseURL = URL(fileURLWithPath: Bundle.main.bundlePath) //메인 번들 패스
                webView.load(htmlData, mimeType: "text/html", textEncodingName: "UTF-8", baseURL: baseURL) //불러오기
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
}
