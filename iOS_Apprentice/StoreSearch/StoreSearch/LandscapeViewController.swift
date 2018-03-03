//
//  LandscapeViewController.swift
//  StoreSearch
//
//  Created by IndieCF on 2018. 3. 2..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView! //스크롤 뷰를 추가해, 가로, 세로로 스크롤하면서 화면 보다 많은 콘텐츠를 표현할 수 있다.
    //UITableView도 UIScrollView에서 확장된 것
    @IBOutlet weak var pageControl: UIPageControl!
    
    var searchResults = [SearchResult]()
    private var firstTime = true //private는 이 객체(LandscapeViewController) 내에서만 사용 가능하다.
    //다른 객체에서는 사용하거나 불러올 수 없다. 가능한 한 객체 내부에 숨기고, 외부에 최소한으로만 연결할 수 있도록 해야한다.
    private var downloads = [URLSessionDownloadTask]() //세로모드로 돌아갈 때 취소하기 위해

    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.removeConstraints(view.constraints) //제약조건 해제
        //이 뷰 컨트롤러에서는 제약조건을 추가하는 것보다 프레임 속성을 직접 조작하는 것이 편리하다.
        //따라서 제약조건을 해제하고, 기본 변환 옵션을 변경해 오토 레이아웃을 비활성화한다.
        view.translatesAutoresizingMaskIntoConstraints = true //기본 변환 옵션 변경 //오토 레이아웃 비활성화
        //오토 리사이징 마스크가 오토 레이아웃 제약조건으로 변환되는지 여부 결정
        //오토 리사이징은 오토 레이아웃이 도입 되기 전에 사용하던 방법. 모든 뷰는 오토리사이징 마스크를 가지고 있다.
        //기본적으로 iOS는 오토 리사이징 마스크와 일치하는 제약조건을 만들어 뷰에 추가한다.
        //오토 레이아웃을 사용하면, 프레임을 직접 변경할 필요없다. 제약조건을 작성하여 뷰의 위치를 간접적으로 이동할 수 있다.
        //하지만 코드로 프레임을 수정하면, 기존 제약 조건과 충돌을 일으키고 문제가 발생할 수 있다.
        
        //실제로 오토 레이아웃이 비활성화된 것은 아니다. translatesAutoresizingMaskIntoConstraints이 true인 경우,
        //UIKit은 수동 레이아웃 코드를 제약조건으로 변환한다. 이전에 제약 조건을 해제하는 것은 새로 추가되는 제약 조건들과 충돌하기 때문이다.
        //코드로 만든 모든 뷰는 default로 true //인터페이스 빌더에서 만든 뷰는 default로 false
        
        pageControl.removeConstraints(pageControl.constraints)
        pageControl.translatesAutoresizingMaskIntoConstraints = true
        
        scrollView.removeConstraints(scrollView.constraints)
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        
        scrollView.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
        //타일로 사용가능한 이미지를 색상으로 배경 이미지처럼 사용한다. //UIColor를 사용하는 모든 곳에서 사용할 수 있다.
        
        pageControl.numberOfPages = 0 //default로 0설정. 검색 결과 없을 때 //페이지 컨트롤이 보여지지 않는다.
        //스토리 보드, 스크롤 뷰에서 Paging Enabled를 체크해야 페이지 컨트롤를 사용할 수 있다.
    }
    
    override func viewWillLayoutSubviews() { //뷰의 좌표, 크기가 변경될 때, 하위 뷰의 위치를 조절하기 전에 호출
        //화면이 처음 나타날 때, 뷰 컨트롤러의 레이아웃 단계로 UIKit에 의해 호출된다. 초기 뷰 프레임을 코드로 변경하기 좋다.
        //viewWillLayoutSubviews()는 여러 번 호출될 수 있다(가로 화면이 다시 세로로 돌아갈 때도 호출 된다).
        super.viewWillLayoutSubviews() //기본 default 값은 빈 메서드
        
        scrollView.frame = view.bounds //스크롤 뷰는 전체 뷰 크기 만큼
        pageControl.frame = CGRect(x: 0, y: view.frame.size.height - pageControl.frame.size.height, width: view.frame.size.width, height: pageControl.frame.size.height) //페이지 컨트롤은 특정 하단 위치에
        //bounds : 자체의 view 위치와 크기 //frame : 상위 뷰 안에서의 view 위치와 크기
        //http://zeddios.tistory.com/203
        
        if firstTime { //한 번만 실행하기 위해
            firstTime = false
            tileButtons(searchResults) //버튼 추가
            //이 메서드 호출 코드를 viewDidLoad()에서 실행하지 않는 이유는 viewDidLoad()가 실행되었을 때,
            //화면은 아직 불려지지 않았고 뷰 계층 구조에 추가되지 않았기 때문이다.
            //viewDidLoad() 종료 이후에 view는 실제 화면에 맞춰 크기가 조정된다.
            //뷰의 frame, bounds를 사용하는 코드는 viewDidLoad()에서 실행하면 안 된다(할 순 있지만 올바른 결과를 보장 못한다).
            //viewWillLayoutSubviews()가 뷰의 frame, bounds를 사용해 계산을 하기 안전한 메서드이다.
        }
    }
    
    deinit {
        print("deinit \(self)")
        for task in downloads {
            task.cancel() //LandscapeViewController가 할당 해제될 때 다운로드 중이거나 대기중인 이미지 모두 취소
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: - Private Methods
extension LandscapeViewController {
    private func tileButtons(_ searchResults: [SearchResult]) {
        var columnsPerPage = 5
        var rowsPerPage = 3
        var itemWidth: CGFloat = 96 //그리드 가로
        var itemHeight: CGFloat = 88 //그리드 세로
        var marginX: CGFloat = 0
        var marginY: CGFloat = 20
        let viewWidth = scrollView.bounds.size.width
        
        //그리드에 들어갈 요소의 수, 페이지, 그리드의 크기를 계산해야 한다.
        switch viewWidth {
        case 568: //568 (4인치)
            columnsPerPage = 6
            itemWidth = 94
            marginX = 2
        case 667: //667 (4.7인치)
            columnsPerPage = 7
            itemWidth = 95
            itemHeight = 98
            marginX = 1
            marginY = 29
        case 736: //736 (5.5인치)
            columnsPerPage = 8
            rowsPerPage = 4
            itemWidth = 92
        default: //480 (3.5인치) 기본값 그대로
            break
        }
        //하드 코딩 외에 적절한 공식으로 맞춰 줄 수도 있다.
        
        //Button size
        let buttonWidth: CGFloat = 82 //그리드 안의 버튼 가로
        let buttonHeight: CGFloat = 82 //그리드 안의 버튼 세로
        let paddingHorz = (itemWidth - buttonWidth)/2
        let paddingVert = (itemHeight - buttonHeight)/2
        
        //Add the buttons
        var row = 0
        var column = 0
        var x = marginX
        for (_, result) in searchResults.enumerated() { //enumerated로 요소와 인덱스를 모두 가져올 수 있다.
            //enumerated로 튜플 형태로 요소와 인덱스를 가져오며, 사용하지 않을 때에는 와일드카드로 표시할 수도 있다.
            //index는 디버깅 때 사용
            let button = UIButton(type: .custom) //버튼 생성
            button.setBackgroundImage(UIImage(named: "LandscapeButton"), for: .normal)
            downloadImage(for: result, andPlaceOn: button)
            button.frame = CGRect(x: x + paddingHorz, y: marginY + CGFloat(row) * itemHeight + paddingVert, width: buttonWidth, height: buttonHeight)
            //코드로 버튼을 생성할 경우에는 frame을 꼭 지정해줘야 한다. CGRect에 사용하는 속성은 모두 CGFloat이다.
            
            scrollView.addSubview(button) //스크롤 뷰에 추가
            
            row += 1
            if row == rowsPerPage { //행이 한 페이지 내의 마지막에 도달하면
                row = 0; x += itemWidth; column += 1 //다음 행으로 넘어가면서 다른 값들은 초기화한다.
                //세미 콜론으로 한 줄에 여러 줄의 코드를 쓸 수 있다.
                
                if column == columnsPerPage { //열이 한 페이지 내 마지막에 도달하면
                    column = 0; x += marginX * 2 //열을 초기화하고 마진 추가
                }
                
            }
        }
        
        let buttonsPerPage = columnsPerPage * rowsPerPage //한 페이지에 들어갈 버튼들의 수
        let numPages = 1 + (searchResults.count - 1) / buttonsPerPage //총 필요한 페이지 수
        //페이지를 통해 단순 스크롤이 아닌 페이징을 구현한다. //정수 값을 정수로 나누면 항상 정수가 된다.
        scrollView.contentSize = CGSize(width: CGFloat(numPages) * viewWidth, height: scrollView.bounds.size.height)
        //contentSize : 실제 콘텐츠의 크기
        //콘텐츠 크기가 스크롤 뷰 bounds보다 큰 경우 스크롤 가능하다.
        //스토리 보드에서는 contentSize를 설정할 수 없다. 코드로 직접 입력해야 한다.
        
        print("Number of pages: \(numPages)")
        
        pageControl.numberOfPages = numPages //페이지 컨트롤의 페이지 수 설정
        pageControl.currentPage = 0 //현재 페이지 설정
        //delegate에서 페이징에 대한 알림을 받아 처리해야 한다.
    }
    
    private func downloadImage(for searchResult: SearchResult, andPlaceOn button: UIButton) {
        //아직 이전 세로의 테이블 뷰에서 다운로드하고 캐시하지 않은 경우에, 이미지를 다운로드 받아야 한다.
        //이전에 비슷한 메서드가 있었지만, 여기에서는 UIButton에 추가하는 것이기에 다시 만들어 줘야 한다.
        if let url = URL(string: searchResult.imageSmall) { //60 크기 이미지 url 링크
            let task = URLSession.shared.downloadTask(with: url) { [weak button] url, response, error in
                //이미지 다운로드 중에 다시 세로 모드로 돌아간다면 따로 취소하지 않는 이상 이미지 다운로드는 계속 진행된다.
                //따라서 [weak button]으로 캡쳐 리스트를 만들어 놓지 않으면, strong reference가 생길 수 있다.
                //weak으로 캡쳐해 놓으면, LandscapeViewController가 할당 해제 될때 button도 할당 해제 된다.
                //따라서 그 경우에는 클로저 안의 button.setImage(image, for: .normal)도 건너 뛴다.
                if error == nil, let url = url, let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    DispatchQueue.main.async { //UI 업데이트 이므로 메인 스레드에서 실행되어야 한다.
                        if let button = button {
                            button.setImage(image, for: .normal)
                        }
                    }
                }
            }
            
            task.resume() //다운로드 실행
            downloads.append(task) //task 저장
        }
    }
}

//MARK: - Actions
extension LandscapeViewController {
    @IBAction func pageChanged(_ sender: UIPageControl) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
            //curveEaseInOut : 느리게 시작한 후 빨라지게
            self.scrollView.contentOffset = CGPoint(x: self.scrollView.bounds.size.width * CGFloat(sender.currentPage), y: 0)
            //페이지 컨트롤을 누른 경우 페이지 업데이트
        }, completion: nil)
    }
}

//MARK: - UIScrollViewDelegate
extension LandscapeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) { //스크롤 된 후 실행
        //페이징을 직접 계산해 줘야 한다.
        let width = scrollView.bounds.size.width //스크롤 뷰의 가로 크기
        let page = Int((scrollView.contentOffset.x + width / 2) / width)
        //contentOffset는 컨텐츠 뷰의 원점이 스크롤 뷰의 원점에서 오프셋 된 지점
        //페이지의 절반을 초과하면 스크롤 뷰가 다음 페이지로 이동
        
        pageControl.currentPage = page //페이징
    }
}

//segue 없이 장치의 회전을 감지해 코드로 뷰 컨트롤러를 인스턴스화한다. //생성 시, Storyboard ID로 해당 뷰 컨트롤러를 찾는다.

//UIScrollView 대신 UICollectionView를 사용하여 더 간편하게 구현할 수 있다.
