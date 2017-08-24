//
//  LandscapeViewController.swift
//  StoreSearch
//
//  Created by 근성가이 on 2016. 12. 15..
//  Copyright © 2016년 근성가이. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var search: Search!
    private var firstTime = true //private로 선언하면 extension에서도 사용할 수 없다. //viewWillLayoutSubviews는 여러 번 호출 될 수 있기에 버튼들을 한 번만 만들기 위해 변수를 사용한다.
    private var downloadTasks = [URLSessionDownloadTask]()
    
    deinit {
        print("deinit \(self)")
        for task in downloadTasks {
            task.cancel()
        }
    }
    
    //MARK: - Get Buttons
    override func viewWillLayoutSubviews() { //뷰 컨트롤러가 스크린에 처음 나타날 때 호출된다. //viewDidLoad ()가 호출 될 때 뷰 컨트롤러의 뷰가 화면에 아직없고 뷰 계층 구조에 추가되지 않는다. viewDidLoad()가 완료된 후에야 ​​뷰가 실제 화면에 맞게 크기가 조정된다. //따라서 사이즈에 맞는 개수를 알아내기 위해서는 viewWillLayoutSubviews에서 해야 한다. //view의 최종 크기 즉, 뷰의 프레임 또는 경계를 사용하는 모든 계산의 유일한 안전한 장소는 viewWillLayoutSubviews()
        super.viewWillLayoutSubviews()
        
        scrollView.frame = view.bounds
        pageControl.frame = CGRect(x: 0, y: view.frame.size.height - pageControl.frame.size.height, width: view.frame.size.width, height: pageControl.frame.size.height)
        
        if firstTime {
            firstTime = false
            
            switch search.state {
            case .notSearchedYet:
                break
            case .loading:
                showSpinner()
            case .noResults:
                showNothingFoundLabel()
            case .results(let list):
                tileButtons(list)
            }
        }
    }
    
    private func tileButtons(_ searchResults: [SearchResult]) { //private로 선언하면 extension에서도 사용할 수 없다.
        var columnsPerPage = 5
        var rowsPerPage = 3
        var itemWidth: CGFloat = 96
        var itemHeight: CGFloat = 88
        var marginX: CGFloat = 0
        var marginY: CGFloat = 20
        let scrollViewWidth = scrollView.bounds.size.width
        
        switch scrollViewWidth {
        case 568: //4인치, (5, SE)
            columnsPerPage = 6
            itemWidth = 94
            marginX = 2
        case 667: //4.7인치, (6, 6s, 7)
            columnsPerPage = 7
            itemWidth = 95
            itemHeight = 98
            marginX = 1
            marginY = 29
        case 736: //5.5인치, (Plus)
            columnsPerPage = 8
            rowsPerPage = 4
            itemWidth = 92
        default: //480point, 3.5인치 //아이패드로 실행할 경우
            break
        }
        // TODO: more to come here
        
        let buttonWidth: CGFloat = 82
        let buttonHeight: CGFloat = 82
        let paddingHorz = (itemWidth - buttonWidth)/2
        let paddingVert = (itemHeight - buttonHeight)/2
        
        var row = 0
        var column = 0
        var x = marginX
        for (index, searchResult) in searchResults.enumerated() {
            let button = UIButton(type: .custom)
            downloadImage(for: searchResult, andPlaceOn: button)
            
            button.setBackgroundImage(#imageLiteral(resourceName: "LandscapeButton"), for: .normal)
            button.frame = CGRect(x: x + paddingHorz, y: marginY + CGFloat(row)*itemHeight + paddingVert, width: buttonWidth, height: buttonHeight)
            button.tag = 2000 + index
            button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
            
            scrollView.addSubview(button)
            
            row += 1
            if row == rowsPerPage {
                row = 0; x += itemWidth; column += 1
                if column == columnsPerPage {
                    column = 0; x += marginX * 2
                }
            }
        }
        
        let buttonsPerPage = columnsPerPage * rowsPerPage
        let numPages = 1 + (searchResults.count - 1) / buttonsPerPage //나눗셈에서 제수가 분모보다 작으면 0이 되므로 +1
        scrollView.contentSize = CGSize(width: CGFloat(numPages) * scrollViewWidth, height: scrollView.bounds.size.height) ////인테페이스 빌더에서 contentSize를 설정하는 방법이 없다. //스크롤 뷰에서 중요한 부분
        
        print("Number of pages: \(numPages)")
        
        pageControl.numberOfPages = numPages
        pageControl.currentPage = 0
    }
    
    private func downloadImage(for searchResult: SearchResult, andPlaceOn button: UIButton) {
        if let url = URL(string: searchResult.artworkSmallURL) {
            let downloadTask = URLSession.shared.downloadTask(with: url) { [weak button] url, response, error in //Strong reference 피하기 위해. self 뿐 아니라 이런 식으로 다른 객체를 weak으로 선언할 수 있다.
                if error == nil, let url = url, let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        if let button = button {
                            button.setImage(image, for: .normal)
                        }
                    }
                }
            }
            downloadTask.resume()
            downloadTasks.append(downloadTask) //다운로드 중 뷰 컨트롤러가 해제되면 다운로드 멈추기 위해 //버튼들을 생성하면서(for) downloadTaskrk 각자 진행되기 때문에 배열에 담아 한 번에 해제
        }
    }
    
    private func showSpinner() {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        spinner.center = CGPoint(x: scrollView.bounds.midX + 0.5, y: scrollView.bounds.midY + 0.5) //짝수로 맞춰주기 위해 0.5 각각 더해준다.
        spinner.tag = 1000
        view.addSubview(spinner)
        spinner.startAnimating()
    }
    
    private func hideSpinner() {
        view.viewWithTag(1000)?.removeFromSuperview()
    }
    
    private func showNothingFoundLabel() {
        let label = UILabel(frame: CGRect.zero)
        label.text = NSLocalizedString("Nothing Found", comment: "Nothing Found label")
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.clear
        
        label.sizeToFit() //사이즈 맞춘다. //다중 언어 지원할 때 유용
        
        var rect = label.frame
        rect.size.width = ceil(rect.size.width / 2) * 2 //올림. 짝수로 만들기 위해
        rect.size.height = ceil(rect.size.height / 2) * 2 //올림. 짝수로 만들기 위해
        label.frame = rect
        
        label.center = CGPoint(x: scrollView.bounds.midX, y: scrollView.bounds.midY)
        
        view.addSubview(label)
    }
    
    func searchResultsReceived() {
        hideSpinner()
        
        switch search.state {
        case .notSearchedYet, .loading:
            break
        case .noResults:
            showNothingFoundLabel()
        case .results(let list):
            tileButtons(list)
        }
    }
    
    func buttonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "ShowDetail", sender: sender)
    }
}

//MARK: - ViewLifeCycle
extension LandscapeViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //오토 레이아웃 해제 //제약조건 만들어 넣는 것보다 프레임 속성으로 조절하는 것이 편한 경우 오토레이아웃 설정 끄고 작업하면 된다.
        view.removeConstraints(view.constraints) //아무런 설정 없어도 인터페이스 빌더에서 자동으로 제약조건을 추가해 둔다. //따라서 오토 레이아웃 해제하기 위해서 설정한 제약조건 없어도 지워줘야 한다.
        view.translatesAutoresizingMaskIntoConstraints = true //오토 리사이징 변환 옵션. //오토 레이아웃은 true로 해도 실제로는 비활성화되지 않는다. translatesAutoresizingMaskIntoConstraints = true로 설정하면 UIKit이 수동 레이아웃 코드를 적절한 제약 조건으로 변환해 적용한다. //보통 오토 레이아웃 적용할 때 false //true로 하면 프레임 속성을 변경하여 뷰를 수동으로 배치하고 크기를 조정할 수 있다.
        
        pageControl.removeConstraints(pageControl.constraints)
        pageControl.translatesAutoresizingMaskIntoConstraints = true
        
        scrollView.removeConstraints(scrollView.constraints)
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        
        scrollView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "LandscapeBackground"))
        
        pageControl.numberOfPages = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//MARK: - UIScrollViewDelegate
extension LandscapeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.size.width
        let currentPage = Int((scrollView.contentOffset.x + width/2)/width) //scrollView.contentOffset.x는 전체 콘텐츠 가로 중 현재 보여지고 있는 좌측의 x 좌표
        pageControl.currentPage = currentPage
    }
    
    @IBAction func pageChanged(_ sender: UIPageControl) { //페이지 컨트롤러를 직접 탭해서 넘어가는 델리게이트는 따로 없어서 만들어 줘야 한다. //사용자가 페이지 컨트롤을 탭하면 currentPage 속성이 업데이트된다.
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
            self.scrollView.contentOffset = CGPoint(x: self.scrollView.bounds.size.width * CGFloat(sender.currentPage), y: 0) //scrollView.bounds.size.width는 스크롤 뷰의 본래 가로 크기 //틀의 크기.
        }, completion: nil)
    }
}

//MARK: - Navigations
extension LandscapeViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" { //아이폰
            if case .results(let list) = search.state {
                let detailViewController = segue.destination as! DetailViewController
                let searchResult = list[(sender as! UIButton).tag - 2000]
                detailViewController.searchResult = searchResult
                detailViewController.isPopUp = true //아이폰에서는 팝업으로 띄워줘야 한다.
            }
        }
    }
}

