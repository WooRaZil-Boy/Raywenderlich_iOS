//
//  ViewController.swift
//  PackingList
//
//  Created by 근성가이 on 2017. 1. 7..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit

let itemTitles = ["Icecream money", "Great weather", "Beach ball", "Swim suit for him", "Swim suit for her", "Beach games", "Ironing board", "Cocktail mood", "Sunglasses", "Flip flops"]

class ViewController: UIViewController {
    //MARK: IB outlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var buttonMenu: UIButton!
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet weak var menuHeightConstraint: NSLayoutConstraint! //레이아웃 제약조건도 outlet이 될 수 있다.
    
    //MARK: further class variables
    var slider: HorizontalItemList!
    var isMenuOpen = false
    var items: [Int] = [5, 6, 7]
    
    //MARK: View Controller methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView?.rowHeight = 54.0
    }
    
    //MARK: class methods
    @IBAction func actionToggleMenu(_ sender: AnyObject) {
        isMenuOpen = !isMenuOpen
        
        titleLabel.superview?.constraints.forEach { constraint in //모든 제약조건을 oulet으로 하기엔 복잡하고, 코드로 추가하는 등 outlet을 연결할 수 없는 경우도 있다. //constraints 배열로 그 뷰에 존재하는 제약조건들을 모두 불러 올 수 있다.
//            print(" -> \(constraint.description)\n")
            if constraint.firstItem === titleLabel && constraint.firstAttribute == .centerX { //첫 번째 아이템이 titleLabel && 첫 조건 -> titleLabel.centerX
                constraint.constant = isMenuOpen ? -100.0 : 0.0 //constant속성은 NSLayoutConstraint의 변경 가능한 속성 //multiplier나 제약 조건 자체 등을 변경하고자 할 때는 새 조건을 추가해 줘야 한다.
                
                return
            }
            
            if constraint.identifier == "TitleCenterY" { //인터페이스 빌더에서 레이아웃 설정하는 부분에 identifier를 입력해 둔다.
                constraint.isActive = false //제약 조건을 제거한다. 다른 참조가 없는 경우 메모리에서 해제된다. //layoutIfNeeded가 필요하다.
                
                let newConstraint = NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: titleLabel.superview!, attribute: .centerY, multiplier: isMenuOpen ? 0.67 : 1.0, constant: 5.0) //제약조건을 코드로 생성 //오토 레이아웃 사용 전에 UIView에서 addConstraint로 제약조건을 코드로 추가할 수도 있다.
                newConstraint.identifier = "TitleCenterY"
                newConstraint.isActive = true
                
                return
            }
        }
        
        menuHeightConstraint.constant = isMenuOpen ? 200.0 : 60.0
        titleLabel.text = isMenuOpen ? "Select Item" : "Packing List"
        
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 10.0, options: .curveEaseIn, animations: { //레이아웃 제약조건도 애니메이션 적용이 가능 //위 조건을 클로저 안에 넣어서 해도 된다.
            let angle: CGFloat = self.isMenuOpen ? .pi / 4 : 0.0 //pi / 4 = 45도
            self.buttonMenu.transform = CGAffineTransform(rotationAngle: angle) //회전
            
            self.view.layoutIfNeeded() //제약 조건 등 기존 레이아웃에서 변경될 점이 있다면 변경
        })
        
        if isMenuOpen {
            slider = HorizontalItemList(inView: view)
            slider.didSelectItem = { index in
                print("add \(index)")
                self.items.append(index)
                self.tableView.reloadData()
                self.actionToggleMenu(self)
            }
            self.titleLabel.superview!.addSubview(slider)
        } else {
            slider.removeFromSuperview()
        }
    }
    
    func showItem(_ index: Int) {
        let imageView = UIImageView(image: UIImage(named: "summericons_100px_0\(index).png"))
        imageView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
        imageView.layer.cornerRadius = 5.0
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        
        let conX = imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor) //centerXAnchor :: 뷰의 수평 중심. 가운데 아래 -> 그냥 수평 레이아웃인 듯
        let conBottom = imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: imageView.frame.height) //bottomAnchor :: 하단 모서리. NSLayoutYAxisAnchor와만 결합 할 수 있다. -> 그냥 하단 레이아웃인 듯
        let conWidth = imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.33, constant: -50.0) //NSLayoutDimension와만 결합할 수 있다. -> 그냥 넓이 레이아웃인 듯
        let conHeight = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor) //정사각형이므로
        
        NSLayoutConstraint.activate([conX, conBottom, conWidth, conHeight]) //배열로 여러 제약조건 한 번에 연결할 수 있다.
        view.layoutIfNeeded() //여기서 한 번 레이아웃을 적용시키지 않으면 밑에 애니메이션 클로저가 시작될 때 반영이 되어 있지 않기 때문에 (0, 0)좌표에서 부터 시작하게 된다.
        
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.0, options: [], animations: { //옵션이 없으면 아예 프로퍼티를 지워놔도 된다.
            conBottom.constant = -imageView.frame.size.height / 2
            conWidth.constant = 0.0 //넓이에 높이가 연결되어 있으므로 넓이만 조절하면 높이는 자동으로 조절된다.
            
            self.view.layoutIfNeeded() //layoutIfNeeded() 호출 사이의 모든 제약 조건 변경 사항은 애니메이션의 일부가 된다.
        })
        
        UIView.animate(withDuration: 0.8, delay: 1.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.0, options: [], animations: {
            conBottom.constant = imageView.frame.size.height
            conWidth.constant = -50.0
            
            self.view.layoutIfNeeded()
        }, completion: { _ in
            imageView.removeFromSuperview()
        })
    }
}

//MARK: Table View methods
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        cell.accessoryType = .none
        cell.textLabel?.text = itemTitles[items[indexPath.row]]
        cell.imageView?.image = UIImage(named: "summericons_100px_0\(items[indexPath.row]).png")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showItem(items[indexPath.row])
    }
}

