//
//  ChecklistViewController.swift
//  Checklists
//
//  Created by 근성가이 on 2018. 1. 3..
//  Copyright © 2018년 근성가이. All rights reserved.
//

//iPad의 경우 4가지 방향을 모두 지원해야 한다.
//메서드를 작성하면 Xcode 메뉴 method jump bar에서 쉽게 찾을 수 있다.
//Swift의 많은 부분은 Objective C 프레임워크에서 왔다.

import UIKit //"UI"로 시작하는 모든 것은 UIKit의 일부

class ChecklistViewController: UITableViewController { //테이블 뷰 컨트롤러(기본적으로 뷰 컨트롤러)가 delegate가 된다.

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//Delegate를 통해 코드 수행의 일부를 위임한다. 여기서 테이블 뷰는 실제 데이터의 종류나 처리를 신경쓰지 않아도 된다.
//이런 식으로 구현하면, 테이블 뷰의 구성이 단순하게 유지되고, 코드를 효율적으로 관리할 수 있다.

//MARK: - UITableViewDataSource
extension ChecklistViewController { //프로토콜. 특정 메소드나 변수를 구현하지만, 모든 세부 사항을 알 필요는 없다.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { //각 섹션의 열 수를 반환 //tableView가 메서드 이름이 아니라 arguments까지 모두 메서드의 이름이다.
        return 100
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { //해당 셀을 가져온다.
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistItem", for: indexPath)
        //재사용 셀을 가져온다.
        //IndexPath는 테이블의 특정 행을 가리키는 객체
        
        //1. 프로토 타입 셀을 스토리 보드의 테이블 뷰에 추가한다.
        //2. 프로토 타입 셀에 재사용 식별자를 설정한다.
        //3. tableView.dequeueReusableCell (withIdentifier : for :)을 호출한다.
        //  필요한 경우 프로토 타입 셀의 복사본을 만들거나 더 이상 사용하지 않는 기존 셀을 재활용한다.
        
        let label = cell.viewWithTag(1000) as! UILabel //스토리보드에서 태그 값을 설정해 줄 수 있다. 태그의 기본 값은 0이다.
        //태그는 @IBOutlet을 만들지 않고도 손쉽게 UI 요소에 대한 참조를 가져올 수 있다.
        //이 경우에는 @IBOutlet로 연결하면, 각 객체의 레이블이 아니라 프로토 타입의 하나의 객체만 가져오므로 적절치 않다.
        
        if indexPath.row % 5 == 0 { //나머지 연산자
            label.text = "Walk the dog"
        } else if indexPath.row % 5 == 1 {
            label.text = "Brush my teeth"
        } else if indexPath.row % 5 == 2 {
            label.text = "Learn iOS development"
        } else if indexPath.row % 5 == 3 {
            label.text = "Soccer practice"
        } else if indexPath.row % 5 == 4 {
            label.text = "Eat ice cream"
        }
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension ChecklistViewController { //행이 선택된 이후 불리는 메서드
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) { //indexPath에 맞춰 cell 반환 //없으면 nil
            //위의 tableView.cellForRow(at :) 메서드와 혼동 주의
            if cell.accessoryType == .none {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true) //해당 셀 선택 해제
    }
}

//적절한 데이터 모델을 사용하지 않으면, 재사용 셀을 사용하면서 이전 셀의 내용과 새로운 셀의 내용이 겹쳐지거나 제대로 안 보여질 때가 있다.

