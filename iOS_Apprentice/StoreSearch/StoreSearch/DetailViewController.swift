//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by 근성가이 on 2018. 3. 1..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!
    
    var searchResult: SearchResult!
    var downloadTask: URLSessionDownloadTask? //이미지 다운로드 테스크

    //MARK: - ViewLifeCycle
    required init?(coder aDecoder: NSCoder) { //스토리보드에서 뷰 컨트롤러 로드할 때 호출된다.
        super.init(coder: aDecoder)
        
        modalPresentationStyle = .custom //modal로 표시되는 컨트롤러의 스타일 지정
        transitioningDelegate = self
        //transition animator, interactive controller,custom presentation controller의 delegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.tintColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1) //틴트 컬러 통일 //스토리보드에서 지정해 줄 수도 있다.
        popupView.layer.cornerRadius = 10 //모서리가 둥글게 만든다.
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
        //delegate에서 true를 반환하면 close()를 실행
        gestureRecognizer.cancelsTouchesInView = false //제스처가 인식될 때 터치가 뷰로 전달되는 지 여부
        //default는 true. //true로 하면 하위 객체들이 제스처를 인식하지 못한다.
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        //스토리 보드에서 탭 제스처를 추가해 줄 수도 있다.
        
        if searchResult != nil { //let _ = searchResult으로 옵셔널을 풀 수도 있다.
            updateUI() //터치한 셀의 정보 업데이트
        }
    }
    
    deinit { //이외에도 클로저의 [weak self]를 확인하기 위해 deinit를 사용해 보는 것이 좋다.
        print("deinit \(self)")
        downloadTask?.cancel() //이미지를 다운로드하기 전에 팝업을 닫으면 이미지 다운로드를 취소한다.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: - HelperMethods
extension DetailViewController {
    func updateUI() {
        nameLabel.text = searchResult.name
        
        if searchResult.artistName.isEmpty { //비어 있는 경우
            artistNameLabel.text = "Unknown"
        } else {
            artistNameLabel.text = searchResult.artistName
        }
        
        kindLabel.text = searchResult.type
        genreLabel.text = searchResult.genre
        
        //Show price
        let formatter = NumberFormatter() //DateFormatter처럼 숫자를 텍스트로 바꿔주는 NumberFormatter
        //String(format:)에서 %f등을 써서 변환할 수도 있지만, 단순 숫자가 아닌 통화 등의 처리가 필요할 때는 NumberFormatter를 사용하는 것이 좋다.
        formatter.numberStyle = .currency //숫자 스타일
        formatter.currencyCode = searchResult.currency //통화코드 //USD, EUR...
        
        let priceText: String
        if searchResult.price == 0 {
            priceText = "Free"
        } else if let text = formatter.string(from: searchResult.price as NSNumber) {
            //formatter에 실제 숫자를 입력해야 변환할 수 있다. 따라서 NSNumber으로 캐스팅 후 문자열로 변환
            priceText = text
        } else {
            priceText = ""
        }
        
        priceButton.setTitle(priceText, for: .normal)
        
        //Get image
        if let largeURL = URL(string: searchResult.imageLarge) {
            downloadTask = artworkImageView.loadImage(url: largeURL) //이미지 추가하고 downloadTask    반환
        }
    }
}

//MARK:- Actions
extension DetailViewController {
    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openInStore() {
        if let url = URL(string: searchResult.storeURL) {
            UIApplication.shared.open(url, options: [:]) //UIApplication.shared.open으로 링크를 열 수 있다.
            //모든 앱에는 UIApplication가 있으며, 앱 전반의 기능을 처리한다.
        }
    }
}

//MARK: - UIViewControllerTransitioningDelegate
extension DetailViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationController(presentedViewController: presented, presenting: presenting)
        //해당 뷰 컨트롤러가 표시될 때, DimmingPresentationController 사용
        //이 메서드를 구현하지 않거나 nil을 반환하면 기본 프레젠테이션 컨트롤러를 사용한다.
        //presented : 표시되는 뷰 컨트롤러
        //presenting : 표시되는 뷰 컨트롤러를 이전의 컨트롤러(부모 뷰 컨트롤러이거나 마지막 표시된 뷰 컨트롤러인 경우가 많다.)
    }
}

//MARK: - UIGestureRecognizerDelegate
extension DetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        //닫기 버튼이 15x15로 매우 작아 터치하기 힘들다. //배경(팝업 외부)를 누를 때 화면을 닫는다.
        return touch.view === self.view //터치한 뷰가 배경 뷰일 경우에만 true를 반환 //팝업 내에선 false
        //=== 로 두 변수가 동일한 객체를 참조하는지 판별한다. //==는 같은 값을 가지고 있는 지 판별.
        //여기서는 === 를 쓰나 ==를 쓰나 동일한 결과를 가진다.
    }
}

//스토리보드에서 Label에 Autoshrink를 지정해 줄 수 있다. 텍스트 길이에 맞게 글꼴 크기를 줄일 수 있다.

//Assets.xcassets에서 stretchable images를 설정할 수 있다. 가격 버튼처럼, 유동적인 크기를 가져야 하는 이미지에 적용한다. p.919
//stretchable images를 적용할 경우, 이미지의 크기가 같은지 확인해 볼 것
//이미지의 색을 포토샵에서 바꿀 수도 있지만, Assets.xcassets에서 Render As를 Template Image으로 설정해 지정해줄 수도 있다.
//Template Image로 설정하면, 원본의 색을 제거한다. 이후, 스토리보드나 코드로 색을 지정해 준다.
