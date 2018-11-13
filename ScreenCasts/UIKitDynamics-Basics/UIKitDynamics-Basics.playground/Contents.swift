import UIKit

import PlaygroundSupport

let view = UIView(frame: CGRect(x: 0, y: 0, width: 600, height: 600)) //parent view
view.backgroundColor = UIColor.lightText
PlaygroundPage.current.liveView = view

let whiteSquare = UIView(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
whiteSquare.backgroundColor = UIColor.white
view.addSubview(whiteSquare)

let orangeSquare = UIView(frame: CGRect(x: 400, y: 100, width: 100, height: 100))
orangeSquare.backgroundColor = UIColor.orange
view.addSubview(orangeSquare)

let animator = UIDynamicAnimator(referenceView: view)
animator.addBehavior(UIGravityBehavior(items: [orangeSquare]))
//Dybanic Animator는 animation view 들을 subview로 가지고 있는 reference view가 있어여 한다.
//addBehavior로 중력을 추가해 준다.

let boundaryCollision = UICollisionBehavior(items: [whiteSquare, orangeSquare])
boundaryCollision.translatesReferenceBoundsIntoBoundary = true
animator.addBehavior(boundaryCollision)
//충돌 후, 멈출 수 있는 속성을 추가해 준다.

let bounce = UIDynamicItemBehavior(items: [orangeSquare])
//UIDynamicItemBehavior로 직접 설정해 줄 수도 있다.
bounce.elasticity = 0.6
bounce.density = 200
bounce.resistance = 2
animator.addBehavior(bounce)

animator.setValue(true, forKey: "debugEnabled")
//디버그를 위해 외곽선을 추가해 준다.

//UIKit Dynamic은 iOS9부터 새로운 동작이 추가되었다. UIKit Dynamic은 2D animation system으로 생각하면 된다.
//중력 등의 물리 법칙을 캡슐화해 간단히 구현할 수 있다.
//Animator는 reference view를 가지고 있으며, animation view들은 모두 reference view의 sub view가 된다.
//Assistant editor에서 움직임을 확인할 수 있다.
