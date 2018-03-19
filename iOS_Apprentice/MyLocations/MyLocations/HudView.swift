//
//  HudView.swift
//  MyLocations
//
//  Created by 근성가이 on 2018. 2. 19..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import UIKit

class HudView: UIView { //Heads-Up Display : HUD - 시간이 필요한 작업(다운로드 등)에 진행률을 표시
    var text = ""
    
    class func hud(inView view: UIView, animated: Bool) -> HudView { //convenience constructor
        //convenience constructor는 항상 class 메서드이다. 특정 인스턴스가 아닌 클래스 전체에서 작동.
        let hudView = HudView(frame: view.bounds) //인스턴스 생성 //UIView에서 상속된 생성자 //상위 뷰와 같은 크기
        hudView.isOpaque = false //true로 하면 완전 불투명. false로 하면, 다른 뷰와 합성된다.
        
        view.addSubview(hudView) //상위 뷰의 밑으로 삽입(여기선 네비게이션 컨트롤러이므로 전체 화면을 커버).
        view.isUserInteractionEnabled = false //HudView가 표시되는 동안, 화면과 상호작용을 하지 않도록
        //isUserInteractionEnabled를 false로 설정하면, 뷰의 모든 터치와 이벤트가 먹히지 않는다.
        
        hudView.show(animated: animated) //애니메이션과 함께 나타나기
        
        return hudView
    } //사용 시 HudView.hud(inView: parentView, animated: true)등으로 hudView를 생성한다.
    //convenience constructor 대신 직접 HudView(frame: )을 통해 생성해도 되지만, convenience constructor로 편의성을 높여준다.
    
    override func draw(_ rect: CGRect) { //UIKit에서 뷰를 다시 그릴 때마다 호출
        //draw의 default는 아무 기능이 없는 빈 메서드이다.
        //Core Graphics, UIKit등을 사용해 뷰를 그리는 클래스는 이 draw 메서드를 재정의하고 해당 코드를 구현해야 한다.
        //iOS의 모든 기능은 이벤트 기반이라 뷰는 UIKit의 요청이 있지 않는 한 화면에 아무것도 그리지 않는다.
        //즉, draw 메서드를 직접 호출해선 안된다. 대신에 setNeedDisplay()를 통해 메시지를 보내고 UIKit이 draw()를 실행한다.
        //보통의 경우, 표준 UI 구성요소는 view의 프로퍼티가 수정될 때마다 내부적으로 setNeedsDisplay()가 트리거되서 자동으로 업데이트 된다.
        //커스텀 view를 만드는 경우, 자체적으로 draw 메소드를 구현하고, 변경되는 경우에 setNeedsDisplay()를 "명시적으로" 호출해야 한다.
        //비슷하게 레이아웃 명시적으로 업데이트 하는 경우, layoutSubViews()를 구현하고 setNeedsLayout()를 호출해야 한다.
        //http://zeddios.tistory.com/359
        let boxWidth: CGFloat = 96
        let boxHeight: CGFloat = 96
        let boxRect = CGRect(x: round((bounds.size.width - boxWidth) / 2), y: round((bounds.size.height - boxHeight) / 2), width: boxWidth, height: boxHeight) //가운데 정렬, 96 x 96
        //round를 사용하는 이유는 몫이 소수로 되는 것을 방지하기 위해서이다. - 이미지가 흐릿해 지는 것을 방지??
        let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10) //10px의 둥근 모서리 있는 사각형 그린다.
        
        UIColor(white: 0.3, alpha: 0.8).setFill() //80% 불투명한 어두운 회색
        roundedRect.fill() //채우기
        
        //Draw checkmark
        if let image = UIImage(named: "Checkmark") { //이미지 불러오기
            //UIImage의 init(name: )은 Failable initializers이다. 이미지의 이름이 없거나 이미지 파일이 유효하지 않은 경우 nil을 반환.
            //따라서 이미지 사용 전에 unwrap 해준다.
            let imagePoint = CGPoint(x: center.x - round(image.size.width / 2), y: center.y - round(image.size.height / 2) - boxHeight / 8) //가운데 정렬 //세로는 텍스트 들어갈 자리 빼고.
            image.draw(at: imagePoint) //해당 위치에 이미지 그리기
        }
        
        //Draw the text //보통 UILabel을 하위 view로 추가하지만, 간단한 경우 직접 텍스트를 그릴 수 있다.
        let attribs = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16), NSAttributedStringKey.foregroundColor: UIColor.white] //그릴 텍스트의 속성값 //16pt 시스템 글꼴 흰색
        let textSize = text.size(withAttributes: attribs) //속성을 넣어 텍스트의 크기를 구한다.
        let textPoint = CGPoint(x: center.x - round(textSize.width / 2), y: center.y - round(textSize.height / 2) + boxHeight / 4) //텍스트를 그릴 위치
        text.draw(at: textPoint, withAttributes: attribs) //해당 위치에 텍스트 그리기
    }
    
    //MARK: - Public methods
    func show(animated: Bool) {
        if animated {
            alpha = 0
            transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            //애니메이션 시작 전 초기 상태 설정. alpha 0으로 투명하게. 1.3배 크게.
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: { //애니메이션 설정.
                self.alpha = 1
                self.transform = CGAffineTransform.identity //원래의 크기
                //애니메이션 완료 후의 상태. alpha 1로 불투명하게. 원래의 폭과 높이로 축소
            }, completion: nil)
        }
    }
    
    func hide() { //navigationController.view를 상위 뷰로 hudView가 나타날 경우, 뷰 컨트롤러가 전환되도 navigationController는 그대로 있기 때문에 hudView가 남아 있다.
        superview?.isUserInteractionEnabled = true //화면과 상호작용하도록
        removeFromSuperview() //상위 뷰에서 제거
    }
}
