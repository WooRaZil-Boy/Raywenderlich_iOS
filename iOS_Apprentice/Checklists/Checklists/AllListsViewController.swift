//
//  AllListsViewController.swift
//  Checklists
//
//  Created by 근성가이 on 2018. 2. 2..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import UIKit

class AllListsViewController: UITableViewController {
    
    var lists = [Checklist]() //Array<Checklist>() 같은 표현이다.

    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationController?.navigationBar.prefersLargeTitles = true //스토리 보드에서 할 수도.
        
        var list = Checklist(name: "Birthdays")
        lists.append(list)
        
        list = Checklist(name: "Groceries")
        lists.append(list)
        
        list = Checklist(name: "Cool Apps")
        lists.append(list)
        
        list = Checklist(name: "To Do")
        lists.append(list)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func makeCell(for tableView: UITableView) -> UITableViewCell {
        let cellIdentifier = "Cell" //더 논리적이고 간결하게 쓰기위해
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) { //재활용할 셀이 있을 때
            //tableView.dequeueReusableCell(withIdentifier: <#T##String#>, for: <#T##IndexPath#>)도 있다. 이 메서드는 프로토 타입 셀에서만 작동한다.
            return cell
        } else { //재활용할 셀이 없을 때
            return UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        } //항상 재활용할 셀이 있는지 확인 후에 없을 경우 새 셀을 만든다. 재활용할 셀이 있는데도 재활용하지 않을 경우, 메모리가 낭비되고 속도가 느려진다.
        
        //테이블 뷰 셀을 만드는 방법
        //1. prototype cell //스토리보드에서 하나만 나와 있는 셀로
        //2. static cell //직접 필요한 만큼 셀을 만든다. 셀의 수를 미리 알고 있는 경우. cellForRowAt 등의 메서드를 따로 구현할 필요 없다.
        //3. nib //작은 스토리 보드
        //4. code //코드로 필요한 셀을 직접 만든다.
    }
}

//MARK: - Navigation
extension AllListsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //Any는 모든 유형의 객체가 될 수 있다. 캐스팅 해서 사용
        if segue.identifier == "ShowChecklist" {
            let controller = segue.destination as! ChecklistViewController //세그의 목적 뷰 컨트롤러를 캐스팅
            controller.checklist = sender as! Checklist //sender로 넘어온 객체를 캐스팅
        } else if segue.identifier == "AddChecklist" {
            let controller = segue.destination as! ListDetailViewController
            controller.delegate = self
        } else if segue.identifier == "EditChecklist" {
            let controller = segue.destination as! ListDetailViewController
            controller.delegate = self
            controller.checklistToEdit = sender as! Checklist
        }
    }
}

//MARK: - UITableViewDataSource
extension AllListsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return lists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = makeCell(for: tableView)
        let checklist = lists[indexPath.row]
        
        cell.textLabel!.text = checklist.name
        cell.accessoryType = .detailDisclosureButton
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) { //삭제
        lists.remove(at: indexPath.row) //Model에서 삭제 후
        
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic) //View에서도 삭제
    }
}

//MARK: - UITableViewDelegate
extension AllListsViewController { //행이 선택된 이후 불리는 메서드
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let checklist = lists[indexPath.row]
        performSegue(withIdentifier: "ShowChecklist", sender: checklist) //코드로 세그를 실행할 수 있다. //sender에 보낼 객체를 지정한다.
        //스토리보드에서 컨트롤러 자체와 연결되는 세그를 설정하고 id를 입력한 후 특정 조건일 때 실행되게 하면 된다.
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) { //엑서서리를 탭했을 경우 이 메서드로 오게 된다.
        let controller = storyboard!.instantiateViewController(withIdentifier: "ListDetailViewController") as! ListDetailViewController
        //스토리보드에서 식별자로 뷰 컨트롤러 객체를 가져온다.
        controller.delegate = self
        
        let checklist = lists[indexPath.row]
        controller.checklistToEdit = checklist
        
        navigationController?.pushViewController(controller, animated: true)
        //segue를 만들고 prepare(for:)로 넘어가도록 할 수도 있다.
    }
}

//스페셜 코멘트로 MARK, TODO, FIXME 등을 사용할 수도 있다.

//MARK: - ListDetailViewControllerDelegate
extension AllListsViewController: ListDetailViewControllerDelegate {
    func listDetailViewControllerDidCancel(_ controller: ListDetailViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func listDetailViewController(_ controller: ListDetailViewController, didFinishAdding checklist: Checklist) {
        let newRowIndex = lists.count
        lists.append(checklist)
        
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        let indexPaths = [indexPath]
        tableView.insertRows(at: indexPaths, with: .automatic)
        
        navigationController?.popViewController(animated: true)
    }
    
    func listDetailViewController(_ controller: ListDetailViewController, didFinishEditing checklist: Checklist) {
        if let index = lists.index(of: checklist) { //객체로 배열의 해당 인덱스를 가져올 수 있다.
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.textLabel?.text = checklist.name
            }
        }
        
        navigationController?.popViewController(animated: true)
    }
}
