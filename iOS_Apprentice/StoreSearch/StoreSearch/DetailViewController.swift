//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by 근성가이 on 2016. 12. 14..
//  Copyright © 2016년 근성가이. All rights reserved.
//

import UIKit
import MessageUI //MFMailComposeViewController 위해

class DetailViewController: UIViewController {
    enum AnimationStyle {
        case slide
        case fade
    }
    
    //MARK: - Properties
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!
    
    var searchResult: SearchResult! { //아이패드에서 검색 결과를 선택해 searchResult가 바뀌면 UI업데이트
        didSet {
            if isViewLoaded { //뷰가 로드 되었는지 UIKit 프로퍼티
                updateUI()
            }
        }
    }
    var downloadTask: URLSessionDownloadTask?
    var dismissAnimationStyle = AnimationStyle.fade
    var isPopUp = false
    
    required init?(coder aDecoder: NSCoder) { //스토리보드에서 객체 로드할 때
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom //커스텀 프레젠테이션 스타일 설정하지 않으면 델리게이트 설정했어도 기본값으로 된다.
        transitioningDelegate = self
    }
    
    deinit {
        print("deinit \(self)")
        downloadTask?.cancel()
    }
}

//MARK: - ViewLifeCycle
extension DetailViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
        popupView.layer.cornerRadius = 10
        
        if searchResult != nil {
            updateUI()
        }
        
        if isPopUp { //아이폰
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
            gestureRecognizer.cancelsTouchesInView = false
            gestureRecognizer.delegate = self
            view.addGestureRecognizer(gestureRecognizer)
            
            view.backgroundColor = UIColor.clear //그라디언트 뷰도 알파값이 있어서 둘다 그라디언트가 들어가면 곱해져 진해진다.
        } else { //아이패드
            view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "LandscapeBackground"))
            popupView.isHidden = true
        }
        
        if let displayName = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String { //infoPlist에서 설정한 앱의 현지화 이름
            title = displayName
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: - Methods
extension DetailViewController {
    @IBAction func close() {
        dismissAnimationStyle = .slide
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openInStore() {
        if let url = URL(string: searchResult.storeURL) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil) //AppDelegate는 UIApplication의 delegate
        }
    }
    
    func updateUI() {
        nameLabel.text = searchResult.name
        
        if searchResult.artistName.isEmpty {
            artistNameLabel.text = NSLocalizedString("Unknown", comment: "Unknown artist name")
        } else {
            artistNameLabel.text = searchResult.artistName
        }
        
        kindLabel.text = searchResult.kindForDisplay()
        genreLabel.text = searchResult.genre
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency //통화 스타일
        formatter.currencyCode = searchResult.currency //국가 코드 “USD” or “EUR”. 국가 통화 설정
        
        let priceText: String
        if searchResult.price == 0 {
            priceText = NSLocalizedString("Free", comment: "Price: Free")
        } else if let text = formatter.string(from: searchResult.price as NSNumber) {
            priceText = text
        } else {
            priceText = ""
        }
        
        priceButton.setTitle(priceText, for: .normal)
        
        if let largeURL = URL(string: searchResult.artworkLargeURL) {
            downloadTask = artworkImageView.loadImage(url: largeURL)
        }
        
        popupView.isHidden = false
    }
}

//MARK: - UIViewControllerTransitioningDelegate
extension DetailViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? { //뷰 전환시 표준 프레젠테이션컨트롤러 대신 지정된 컨트롤러 사용
        return DimmingPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? { //presented 될 때 뷰 컨트롤러에 애니메이션 추가
        return BounceAnimationController()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? { //dismissed 될 때 컨트롤러에 애니메이션 추가
        switch dismissAnimationStyle {
        case .slide:
            return SlideOutAnimationController()
        case .fade:
            return FadeOutAnimationController()
        }
    }
}

//MARK: - UIGestureRecognizerDelegate
extension DetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view === self.view //팝업 이외의 영역 터치 할 경우에만 true
    }
}

//MARK: - Navigations
extension DetailViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMenu" {
            let controller = segue.destination as! MenuViewController
            controller.delegate = self
        }
    }
}

//MARK: - MenuViewControllerDelegate
extension DetailViewController: MenuViewControllerDelegate {
    func menuViewControllerSendSupportEmail(_: MenuViewController) {
        dismiss(animated: true, completion: {
            if MFMailComposeViewController.canSendMail() {
                let controller = MFMailComposeViewController()
                controller.setSubject(NSLocalizedString("Support Request", comment: "Email subject")) //메일 제목
                controller.setToRecipients(["your@email-address-here.com"]) //메일 받을 주소
                controller.mailComposeDelegate = self
                controller.modalPresentationStyle = .formSheet
                self.present(controller, animated: true, completion: nil)
            }
        })
    }
}

//MARK: - MFMailComposeViewControllerDelegate
extension DetailViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}
