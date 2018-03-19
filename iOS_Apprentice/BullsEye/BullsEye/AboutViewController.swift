//
//  AboutViewController.swift
//  BullsEye
//
//  Created by 근성가이 on 2017. 12. 26..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit

//파일을 생성할 때, Cocoa Touch Class로 생성하면, 기본적인 메서드등의 코드들이 default로 들어가 있다.
//일반 Swift 파일로 생성하면, 빈 스위프트 파일이 된다.

class AboutViewController: UIViewController {
    @IBOutlet weak var webView: UIWebView! //WKWebView로 바뀜

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = Bundle.main.url(forResource: "BullsEye", withExtension: "html") {
            //Bundle.main으로 이 어플리케이션의 정보, 샌드박스등을 가져올 수 있다.
            if let htmlData = try? Data(contentsOf: url) {
                let baseURL = URL(fileURLWithPath: Bundle.main.bundlePath)
                webView.load(htmlData, mimeType: "text/html", textEncodingName: "UTF-8", baseURL: baseURL)
            }
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close() {
        dismiss(animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
