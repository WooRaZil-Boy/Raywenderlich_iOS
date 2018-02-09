//
//  ListDetailViewController.swift
//  Checklists
//
//  Created by 근성가이 on 2018. 2. 3..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import UIKit

protocol ListDetailViewControllerDelegate: class {
    func listDetailViewControllerDidCancel(_ controller: ListDetailViewController)
    func listDetailViewController(_ controller: ListDetailViewController, didFinishAdding checklist: Checklist)
    func listDetailViewController(_ controller: ListDetailViewController, didFinishEditing checklist: Checklist)
}

class ListDetailViewController: UITableViewController {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var iconImageView: UIImageView!
    
    weak var delegate: ListDetailViewControllerDelegate?
    
    var checklistToEdit: Checklist?
    var iconName = "Folder"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        if let checklist = checklistToEdit { //Edit 일 시
            title = "Edit Checklist"
            textField.text = checklist.name
            doneBarButton.isEnabled = true
            iconName = checklist.iconName
        }
        iconImageView.image = UIImage(named: iconName)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textField.becomeFirstResponder() //뷰 컨트롤러가 나타나면 textField가 자동으로 선택되어진다.
    }
}

//MARK: - Actions
extension ListDetailViewController {
    @IBAction func cancel() {
        delegate?.listDetailViewControllerDidCancel(self)
    }
    
    @IBAction func done() {
        if let checklist = checklistToEdit { //Edit 시
            checklist.name = textField.text!
            checklist.iconName = iconName
            delegate?.listDetailViewController(self, didFinishEditing: checklist)
        } else { //Add 시
            let checklist = Checklist(name: textField.text!, iconName: iconName) //Checklist가 init()가 없으므로 Checklist()을 하면 오류난다.
            delegate?.listDetailViewController(self, didFinishAdding: checklist)
        }
    }
}

// MARK:- Navigation
extension ListDetailViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickIcon" {
            let controller = segue.destination as! IconPickerViewController
            controller.delegate = self
        }
    }
}

//MARK: - UITableViewDataSource
extension ListDetailViewController {
    
}

//MARK: - UITableViewDelegate
extension ListDetailViewController {
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 1 { //아이콘 선택 창에서는 선택 되도록
            return indexPath
        } else {
            return nil //선택이 안 되도록
        }
    }
}

//MARK: - UITextFieldDelegate
extension ListDetailViewController: UITextFieldDelegate  { //텍스트 필드의 텍스트가 바뀔 때 호출된다. (키보드 입력, 잘라 내기, 붙여 넣기 ..) //텍스트의 대체 범위, 대체 문자열을 파라미터로 가진다.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text! //텍스트 필드에 이미 입력되어 있는 텍스트
        let stringRange = Range(range, in: oldText)! //NSRange를 Range형으로 바꿔준다. //NSRange는 Objective-C 에서 사용하므로, Swift에 맞추기 위해.
        let newText = oldText.replacingCharacters(in: stringRange, with: string) //해당 범위의 문자를 바꿔 입력 완료되는 텍스트를 추출.
        //NSRange와 Range 달리 NSSting과 String은 bridge가 되어 있다. 따라서 String을 NSString으로 바꾸어 replacementCharacters (: with :) 를 사용 해도 된다.
        
        doneBarButton.isEnabled = !newText.isEmpty
        
        return true
    }
}

extension ListDetailViewController : IconPickerViewControllerDelegate {
    func iconPicker(_ picker: IconPickerViewController, didPick iconName: String) { //아이콘 이미지 선택 시
        self.iconName = iconName
        iconImageView.image = UIImage(named: iconName)
        navigationController?.popViewController(animated: true)
    }
}


