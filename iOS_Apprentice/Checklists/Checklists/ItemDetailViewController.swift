//
//  ItemDetailViewController.swift
//  Checklists
//
//  Created by 근성가이 on 2018. 1. 26..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import UIKit
import UserNotifications

//Cocoa touch 클래스로 만들어진 코멘트가 달린 코드를 보일러 플레이트(boilerplate)라 한다.
//네비게이션 컨트롤러와 탭 바 컨트롤러는 컨테이너라 생각하면 된다. (하나의 컨트롤러에는 하나의 화면)
//테이블 뷰에 섹션과 행의 수를 미리 알고 있는 경우에 Static cell을 사용할 수 있다.
//우 클릭 - refactoring - rename.. 으로 리펙토링 할 수 있다.

protocol ItemDetailViewControllerDelegate: class { //자바의 Interface와 비슷
    func itemDetailViewControllerDidCancel(_ controller: ItemDetailViewController) //프로토콜에서는 메서드의 이름만 적고, 메서드의 내용은 프로토콜이 구현된 곳에서 한다.
    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishAdding item: ChecklistItem)
    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishEditing item: ChecklistItem)
    //delegate 메서드는 일반적으로 첫 번재 파라미터로 owner를 받는 게 일반적이다.
    //delegate를 구현한 뷰 컨트롤러와 연결되는 delegate가 하나가 아닐 수 있기 때문에.
    //따라서 메서드 이름도 itemDetailViewController~ 로 시작하도록 했다.
}
//직접 객체를 받아와서 DTO를 만들고 넣어줘도 된다. 하지만, iOS 개발에서는 Delegate를 사용하는 것이 더 일반적이다.
//각각의 화면에는 하나의 뷰와 그 뷰에 관계된 작업만이 이루어지는 것을 권장.
//AddItemViewController에서 ChecklistViewController에 대한 작업을 하지 않는 것이 가장 좋다.
//따라서 Delegate로 ChecklistViewController의 작업은 ChecklistViewController에서 이루어 지도록 설계한다.


class ItemDetailViewController: UITableViewController { //하나의 뷰 컨트롤러의 여러개의 delegate 패턴을 가질 수 있다. (ex. 테이블 뷰, 테이블 뷰 데이터 소스, 텍스트 필트 ...)
    
    //@IBOutlet이나 @IBAction의 왼쪽 원을 눌러보면 어느 객체와 연결되어 있는지 알 수 있다.
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var shouldRemindSwitch: UISwitch!
    @IBOutlet weak var dueDateLabel: UILabel!
    
    @IBOutlet weak var datePickerCell: UITableViewCell!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    weak var delegate: ItemDetailViewControllerDelegate? //델리게이트
    //단순 참조. 댈리게이트가 참조하는 객체는 ChecklistViewController이지만 여기서는 단순히 필요한 부분을 넘겨주고, ChecklistViewController에서 해당 내용을 구현하면 된다.
    //초기화 되어야 하기 때문에 옵셔널, 현재 뷰 컨트롤러가 메모리 해제되어도 순환참조가 일어날 수 있으므로 방지하기 위해 weak.
    
    //strong 참조로 되어 있을 경우에는 두 객체는 삭제되거나 할당이 취소되지 않는다.
    //따라서 할당이 해제되어야 할 경우에 해제가 되지 않아 메모리가 낭비되는 경우가 있을 수도 있다.
    //이런 경우 서로 연결되어 있는 객체 중 하나를 weak으로 하면, 순환이 끊어질 수 있다.
    //@IBOutlet의 경우에도 weak으로 선언된다. 이 경우에는 메모리 순환을 끊기 위해서가 아니라 뷰 컨트롤러가 @IBOutlet의 소유자가 아님을 확실히 하기 위해서이다.
    
    var itemToEdit: ChecklistItem? //nil이면 add, 객체가 있으면 edit
    var dueDate = Date() //현재시간 //문자열에서 날짜를 추출해 내는 것이 더 어렵다.
    var datePickerVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationItem.largeTitleDisplayMode = .never //스토리보드에서 설정해 줄 수 있다.
        
        if let item = itemToEdit { //Edit 시 //if let으로 옵셔널을 해제할 수 있다.
            title = "Edit Item"
            textField.text = item.text
            doneBarButton.isEnabled = true //Edit 시 Done 버튼 활성화
            shouldRemindSwitch.isOn = item.shouldRemind
            dueDate = item.dueDate
        }
        
        updateDueDateLabel() //Add 시에는 현재 시간으로
    }
    
    override func viewWillAppear(_ animated: Bool) { //뷰가 보인 후 활성화
        super.viewWillAppear(true)
        
        textField.becomeFirstResponder() //텍스트 필드 입력이 활성화 된다. //작은 부분이 큰 차이를 만든다.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateDueDateLabel() {
        let formatter = DateFormatter() //DateFormatter로 Date 값을 텍스트로 변경한다.
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dueDateLabel.text = formatter.string(from: dueDate) //스타일을 지정한 후 텍스트로 변경
        //실행자의 로컬 설정에 따라 날짜 포맷이 맞춰진다.
    }
    
    func showDatePicker() {
        datePickerVisible = true
        
        let indexPathDateRow = IndexPath(row: 1, section: 1)
        let indexPathDatePicker = IndexPath(row: 2, section: 1) //새로 만들 열의 indexPath
        
        if let dateCell = tableView.cellForRow(at: indexPathDateRow) {
            dateCell.detailTextLabel!.textColor = dateCell.detailTextLabel!.tintColor
        }
        
        tableView.beginUpdates() //새로운 행을 삽입하고, 테이블을 다시 로드 하는 두 가지 작업을 동시에 하다보면 제대로 업데이트 되지 않는 경우가 생긴다.(애니메이션)
        //tableView.beginUpdates(), tableView.endUpdates()를 쓰면 순차적으로 부드럽게 업데이트 가능하다.
        tableView.insertRows(at: [indexPathDatePicker], with: .fade) //가장 밑에 새로운 열 삽입
        tableView.reloadRows(at: [indexPathDateRow], with: .none)
        tableView.endUpdates()
        
        datePicker.setDate(dueDate, animated: false)
    }
    
    func hideDatePicker() {
        if datePickerVisible {
            datePickerVisible = false
            
            let indexPathDateRow = IndexPath(row: 1, section: 1)
            let indexPathDatePicker = IndexPath(row: 2, section: 1)
            
            if let cell = tableView.cellForRow(at: indexPathDateRow) {
                cell.detailTextLabel!.textColor = UIColor.black
            }
            
            tableView.beginUpdates() //새로운 행을 삽입하고, 테이블을 다시 로드 하는 두 가지 작업을 동시에 하다보면 제대로 업데이트 되지 않는 경우가 생긴다.(애니메이션)
            //tableView.beginUpdates(), tableView.endUpdates()를 쓰면 순차적으로 부드럽게 업데이트 가능하다.
            tableView.reloadRows(at: [indexPathDateRow], with: .none)
            tableView.deleteRows(at: [indexPathDatePicker], with: .fade) //가장 밑에 DatePicker 셀 삭제
            tableView.endUpdates()
        }
    }
}

//MARK: - Actions
extension ItemDetailViewController {
    @IBAction func cancel() {
        delegate?.itemDetailViewControllerDidCancel(self) //델리게이트로 넘겨, 해당 뷰 컨트롤러에서 구현한다.
        //delegate가 nil이라도 옵셔널 체이닝을 사용했기 때문에 실행되지 않고 crash를 방지한다.
    }
    
    @IBAction func done() { //Edit와 Add 두 개의 상황을 판단해야 한다.
        if let item = itemToEdit { //Edit
            item.text = textField.text!
            item.shouldRemind = shouldRemindSwitch.isOn
            item.dueDate = dueDate
            
            item.scheduleNotification()
            delegate?.itemDetailViewController(self, didFinishEditing: item) //델리게이트로 넘겨, 해당 뷰 컨트롤러에서 구현한다.
            //delegate가 nil이라도 옵셔널 체이닝을 사용했기 때문에 실행되지 않고 crash를 방지한다.
        } else { //Add
            let item = ChecklistItem()
            item.text = textField.text!
            item.checked = false
            item.shouldRemind = shouldRemindSwitch.isOn
            item.dueDate = dueDate
            
            item.scheduleNotification()
            delegate?.itemDetailViewController(self, didFinishAdding: item) //델리게이트로 넘겨, 해당 뷰 컨트롤러에서 구현한다.
            //delegate가 nil이라도 옵셔널 체이닝을 사용했기 때문에 실행되지 않고 crash를 방지한다.
        }
    }
    
    @IBAction func dateChanged(_ datePicker: UIDatePicker) {
        dueDate = datePicker.date
        updateDueDateLabel()
    }
    
    @IBAction func shouldRemindToggled(_ switchControl: UISwitch) {
        textField.resignFirstResponder()
        if switchControl.isOn {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound]) { granted, error in //중간에 알림 설정 해제하거나 한 경우를 대비해서
                //Appdelegate에서 설정하는 것보다 사용자 친화적
            }
        }
    }
}

// MARK: - Table view data source
extension ItemDetailViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 && datePickerVisible { //DatePicker Cell의 경우
            return 3
        } else { //일반적인 경우 //Static cell
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { //이 뷰 컨트롤러는 static cell로만 이루어졌기 때문에 일반적으로 tableView(_ : cellForRowAt :)를 구현하지 않는다.
        //하지만 여기선 새로운 Datepicker cell을 추가하기 위해 커스터마이징을 해 줘야한다.
        if indexPath.section == 1 && indexPath.row == 2 { //DatePicker Cell의 경우
            return datePickerCell
        } else { //일반적인 경우 //Static cell
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 2 { //DatePicker Cell의 경우
            return 217 //Picker 216 + 구분선 1
        } else { //일반적인 경우 //Static cell //44
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
}

//MARK: - UITableView Delegate
extension ItemDetailViewController {
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? { //뷰에 선택되어질 때
        if indexPath.section == 1 && indexPath.row == 1 { //DatePicker Cell의 경우
            return indexPath
        } else { //일반적인 경우 //Static cell
            return nil //nil을 반환해 선택되어 지지 않도록 한다. //IndexPath? 이므로 옵셔널을 반환할 수 있다.
        }
    } //행 선택이 불가능해 지도록 해도, 회색 음염이 잠시 그려지는 경우가 있다. //스토리보드에서 테이블 뷰 Cell의 Selection을 None으로 해 선택 시 아무 변화없도록 설정한다.
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        textField.resignFirstResponder() //textField의 Responder를 해제해서 키보드를 숨긴다.
        
        if indexPath.section == 1 && indexPath.row == 1 {
            if !datePickerVisible {
                showDatePicker()
            } else {
                hideDatePicker()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        //추가되는 셀이 스토리보드의 테이블 뷰 일부가 아니기 때문에 수정해 주어야 한다.
        //따라서 셀이 추가될 때 3번째 셀이 있는 것처럼 해 줘야 한다.
        //https://stackoverflow.com/questions/45379230/why-it-needs-tableview-indentationlevelforrowat-when-inserting-cell-into-a-t
        var newIndexPath = indexPath
        if indexPath.section == 1 && indexPath.row == 2 {
            newIndexPath = IndexPath(row: 0, section: indexPath.section)
        }
        
        return super.tableView(tableView, indentationLevelForRowAt: newIndexPath)
    }
}

//MARK: - UITextFieldDelegate
extension ItemDetailViewController: UITextFieldDelegate { //스토리 보드에서 해당 텍스트 필드를 delegate로 연결한다.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool { //텍스트 필드의 텍스트가 바뀔 때 호출된다. (키보드 입력, 잘라 내기, 붙여 넣기 ..) //텍스트의 대체 범위, 대체 문자열을 파라미터로 가진다.
        let oldText = textField.text! //텍스트 필드에 이미 입력되어 있는 텍스트
        let stringRange = Range(range, in: oldText)! //NSRange를 Range형으로 바꿔준다. //NSRange는 Objective-C 에서 사용하므로, Swift에 맞추기 위해.
        let newText = oldText.replacingCharacters(in: stringRange, with: string) //해당 범위의 문자를 바꿔 입력 완료되는 텍스트를 추출.
        //NSRange와 Range 달리 NSSting과 String은 bridge가 되어 있다. 따라서 String을 NSString으로 바꾸어 replacementCharacters (: with :) 를 사용 해도 된다.
        
//        print("odlText :: \(oldText)")
//        print("newText :: \(newText)")
//        print("string :: \(string)")
        
        if newText.isEmpty { //doneBarButton.isEnabled = !newText.isEmpty로 단순화할 수 있다.
            doneBarButton.isEnabled = false
        } else {
            doneBarButton.isEnabled = true
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        hideDatePicker()
    }
}
