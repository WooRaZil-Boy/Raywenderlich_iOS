//
//  ViewController.swift
//  RxDataSources
//
//  Created by 근성가이 on 2018. 4. 18..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
//import RxDataSources

class ViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        //RxCocoa에 바인딩 하더라도, 필요한 경우 일반 delegate와 dataSource가 필요한 경우가 있다.
        //이미 RxCocoa에 바인딩한 상태에서 delegate를 추가하려면
        //tableView.rx.setDelegate(myDelegateObject)를 사용하면 된다.
        //직접 tableView.delegate = self 식으로 지정하면 오류가 날 수 있으므로 반드시 setDelegate를 이용한다.
//        tableView.rx.setDataSource(self) //dataSouece도 같은 식으로 지정해 줄 수 있다.
        
//        bindTableView()
        bindMyModel()
        
        
    }
}

extension ViewController {
    func bindTableView() {
        let cities = Observable.of(["Lisbon", "Copenhagen", "London", "Madrid", "Vienna"])
        
        cities
            .bind(to: tableView.rx.items) { (tableView: UITableView, index: Int, element: String) in //tableView.rx.items는 Observable<[String]>과 같이
                //observable sequence에서 작동하는 바인딩하는 함수.
                //바인딩은 시퀀스를 구독하고, ObserverType 객체를 만든다.
                //따로 dataSource나 delegate를 설정해 줄 필요 없다.
                //observable에 새로운 새로운 요소배열이 전달되면 binding이 알아서 tableView reloads 한다.
                //각 항목의 셀을 가져 오려면 RxCocoa는 다시 로드 할 행의 세부 정보(및 날짜)와 함께 클로저를 호출한다.
                let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
                cell.textLabel?.text = element
                
                return cell
            }
            .disposed(by: disposeBag)
        
        tableView.rx
            .modelSelected(String.self) //didSelectRowArIndexPath의 래퍼
            //모델 객체를 선택할 때마다 Observable을 반환한다.
            //itemSelected()는 선택한 항목의 IndexPath를 전송한다.
            //modelSelected(), modelDeselected(), itemSelected(), itemDeselected() : 항목 선택/해제
            //accessoryButton() : 액세서리 버튼에서 선택
            //itemInseted(), itemDeleted(), itemMoved() : edit mode에서 이벤트
            //willDisplayCell(), didEndDisplayingCell()
            .subscribe(onNext: { model in //구독
                print("\(model) was selected")
            })
            .disposed(by: disposeBag)
    }
    
    func bindMyModel() {
        enum MyModel {
            case text(String)
            case pairOfImages(UIImage, UIImage)
        }
        //Multiple cell을 활용할 때는 enum을 활용하는 것이 좋다.
        //enum의 observable에 바인딩하는 동안 필요한 여러가지 셀을 처리할 수 있다.
        
        let textCell = UINib(nibName: "TextCell", bundle: nil)
        let imagesCell = UINib(nibName: "ImagesCell", bundle: nil)
        
        tableView.register(textCell, forCellReuseIdentifier: "titleCell")
        tableView.register(imagesCell, forCellReuseIdentifier: "pairOfImagesCell")
        //tableView에 TableViewCell 연결
        
        let observable = Observable<[MyModel]>.just([
                .text("Paris"),
                .pairOfImages(UIImage(named: "EiffelTower.jpg")!, UIImage(named:
                    "LeLouvre.jpg")!),
                .text("London"),
                .pairOfImages(UIImage(named: "BigBen.jpg")!, UIImage(named:
                    "BuckinghamPalace.jpg")!)
            ])

        observable
            .bind(to: tableView.rx.items) { (tableView: UITableView, index: Int, element: MyModel) in //tableView.rx.items는 Observable<[MyModel]>과 같이
                //observable sequence에서 작동하는 바인딩하는 함수.
                //바인딩은 시퀀스를 구독하고, ObserverType 객체를 만든다.
                //따로 dataSource나 delegate를 설정해 줄 필요 없다.
                //observable에 새로운 새로운 요소배열이 전달되면 binding이 알아서 tableView reloads 한다.
                //각 항목의 셀을 가져 오려면 RxCocoa는 다시 로드 할 행의 세부 정보(및 날짜)와 함께 클로저를 호출한다.
                let indexPath = IndexPath(item: index, section: 0)

                switch element { //각 enum 별로 넣어준다.
                case .text(let title):
                    let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! TextCell
                    
                    cell.titleLabel.text = title

                    return cell
                case .pairOfImages(let firstImage, let secondImage):
                    let cell = tableView.dequeueReusableCell(withIdentifier: "pairOfImagesCell", for: indexPath) as! ImagesCell
                    cell.leftImage.image = firstImage
                    cell.rightImage.image = secondImage

                    return cell
                }
            }
            .disposed(by: disposeBag)
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

//TableViewController는 iOS 어플리케이션에서 가장 자주 사용되는 컨트롤러 중 하나이다.
//일반 적 구현에는 dataSource, delegate 콜백이 있지만,
//Rx를 사용하면, 시퀀스를 테이블과 완전히 통합할 수 있고, 보일러 코드의 양도 줄일 수 있다.
//RxCocoa에도 UITableView와 UICollectionView를 래핑한 클래스가 있지만,
//추가 라이브러리인 RxDataSources를 사용할 수 있다. UICollectionView에서도 똑같이 작동한다.
//RxDataSources는 RxCocoa 밑으로 설치 되어 RxCocoa만 import 해서 사용하면 된다.
//http://community.rxswift.org/
//https://github.com/RxSwiftCommunity/RxDataSources





