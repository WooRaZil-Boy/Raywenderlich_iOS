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
}

//스토리보드의 테이블 뷰에서 프로토 타입 셀을 직접 만들어 쓸 수도 있지만, xib로 해당 항목에 대한 디자인을 따로 만들 수 있다.
//xib는 스토리보드와 거의 유사. 개별 스토리보드라고 생각하면 된다.
//xib는 nib(NeXT Interface Builder)로 컴파일 된다. 동일한 용어라고 생각해도 된다.

//최신 버전 iOS는 저 해상도(x1) 디바이스에서 실행할 수 없다. 따라서 이미지 파일은 x2, x3로 충분

//Editor - Canvas - Show Bounds Rectangles로 인터페이스 빌더에서 경계선을 볼 수 있다.

//이미지 뷰의 이미지를 로드하는 데에는 시간이 걸릴 수 있으므로, default 이미지를 넣어 주고 업데이트 하는 것이 좋다.

//Editor → Resolve Auto Layout Issues → Update Frames로 오토 레이아웃 프레임 업데이트
