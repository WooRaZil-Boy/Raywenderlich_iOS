//
//  SearchResultCell.swift
//  StoreSearch
//
//  Created by IndieCF on 2018. 2. 27..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!
    var downloadTask: URLSessionDownloadTask? //이미지 다운로드 테스크
    
    //MARK: - ViewLifeCycle
    override func awakeFromNib() { //nib에서 로드 된 후, 테이블 뷰에 추가되기 전에 호출
        //init처럼 사용할 수 있다. 순서는 init?(coder)이후 awakeFromNib()이 실행된다.
        //init?(coder) 메서드를 작성해도 되지만, ViewLifeCycle 상 init 이후에 @IBOutlet에 메모리가 할당된다.
        //따라서 @IBOutlet을 이용해 값을 할당해 주고 싶다면 awakeFromNib()에서 코드를 작성해야 한다.
        //뷰 컨트롤러의 viewDidLoad()와 비슷한 메서드라고 생각할 수 있다.
        super.awakeFromNib() //항상 먼저 실행해 줘야 한다.
        
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 0.5)
        selectedBackgroundView = selectedView //selectedBackgroundView를 지정해 선택 시 효과를 지정해 줄 수 있다.
    }
    
    override func prepareForReuse() { //tableView delegate가 재사용할 셀을 준비
        //재사용 식별자 있는 경우 dequeueReusableCell(withIdentifier :)로 반환되기 전에 호출된다.
        super.prepareForReuse()
        
        downloadTask?.cancel()
        downloadTask = nil
        //테이블 뷰 셀은 재사용되므로, 이미지가 완전히 다운로드 되지 않은 경우에 스크롤을 하면 다른 이미지를 불러온다.
        //이런 경우, 이전 이미지 다운로드는 불필요하게 되므로 취소해야 한다.
        //작은 이미지이고, Wi-Fi 속도가 충분히 빨라 취소를 하지 않아도 큰 영향을 주진 않지만, 사소한 부분도 신경써야 한다.
    }
}

//MARK: - PublicMethods
extension SearchResultCell {
    func configure(for result: SearchResult) {
        //객체와 관련된 로직은 객체 안에서 해결하는 것이 바람직하다. //뷰 컨트롤러에 너무 많은 로직을 넣지 마라.
        //아래 코드를 viewController에서 처리할 수도 있지만, 여기서 처리하는 것이 더 깔끔하다.
        nameLabel.text = result.name
        
        if result.artistName.isEmpty { //아트스트 네임 없는 경우
            artistNameLabel.text = "Unknown"
        } else { //있는 경우
            artistNameLabel.text = String(format: "%@ (%@)", result.artistName, result.type)
            //C언어에서 주로 쓰이는 formatted string을 이용할 수 있다. %d : 정수, %f : 실수, %@ : 객체
        }
        
        artworkImageView.image = UIImage(named: "Placeholder") //default 이미지 //로드 완료 전까지 표시
        if let smallURL = URL(string: result.imageSmall) { //URL로 캐스팅
            downloadTask = artworkImageView.loadImage(url: smallURL) //이미지 추가하고 downloadTask    반환
        }
    }
}

//스토리보드의 테이블 뷰에서 프로토 타입 셀을 직접 만들어 쓸 수도 있지만, xib로 해당 항목에 대한 디자인을 따로 만들 수 있다.
//xib는 스토리보드와 거의 유사. 개별 스토리보드라고 생각하면 된다.
//xib는 nib(NeXT Interface Builder)로 컴파일 된다. 동일한 용어라고 생각해도 된다.

//최신 버전 iOS는 저 해상도(x1) 디바이스에서 실행할 수 없다. 따라서 이미지 파일은 x2, x3로 충분

//Editor - Canvas - Show Bounds Rectangles로 인터페이스 빌더에서 경계선을 볼 수 있다.

//이미지 뷰의 이미지를 로드하는 데에는 시간이 걸릴 수 있으므로, default 이미지를 넣어 주고 업데이트 하는 것이 좋다.

//Editor → Resolve Auto Layout Issues → Update Frames로 오토 레이아웃 프레임 업데이트

//iOS9 부터 HTTP로 다운로드 할 수 없고, 항상 HTTPS를 사용해야 한다.
//따라서, HTTP 주소로 접속해야 할 경우 Info.plist에 키를 추가해 줘야 한다.
//NSAppTransportSecurity(App Transport Security Settings) - NSAllowsArbitraryLoads(Allow Arbitrary Loads)
//이 설정을 할 경우, 모든 경우에 도메인에 관계없이 HTTP 주소로 연결할 수 있다.
//특정 주소의 HTTP를 사용할 경우, NSExceptionDomains에서 예외로 허용할 주소를 추가해 줘야 한다.


