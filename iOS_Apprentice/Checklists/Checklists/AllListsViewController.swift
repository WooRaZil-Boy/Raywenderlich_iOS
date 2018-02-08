//
//  AllListsViewController.swift
//  Checklists
//
//  Created by 근성가이 on 2018. 2. 2..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import UIKit

class AllListsViewController: UITableViewController {
    
    var dataModel: DataModel! //앱이 시작될 때 dataModel이 일시적으로 nil이 되기 때문에 !이 필요하다.
    //?로 할 필요가 없는 이유는 앱이 시작될 때 한 번 객체가 생성되고 종료 시까지 계속해서 값을 가지고 있기 때문이다.

    override func viewDidLoad() { //이 뷰 컨트롤러가 생성 될 때 한 번 호출
        super.viewDidLoad()
//        navigationController?.navigationBar.prefersLargeTitles = true //스토리 보드에서 할 수도.
    }
    
    override func viewDidAppear(_ animated: Bool) { //이 뷰 컨트롤러가 생성 될 때 뿐 아니라 나타날 때 마다 호출
        super.viewDidAppear(animated)
        
        navigationController?.delegate = self
        
        let index = dataModel.indexOfSelectedChecklist //처음 앱을 실행하거나 지웠다가 다시 설치한 경우에는 Error
        if index >= 0 && index < dataModel.lists.count  { //이전에 종료된 화면 기록이 있다면
            //index < dataModel.lists.count로 UserDefaults에는 value가 저장되었지만, plist에 저장 되지 않은 경우(충돌로 인한 강제 종료), 에러를 막을 수 있다.
            let checklist = dataModel.lists[index]
            
            performSegue(withIdentifier: "ShowChecklist", sender: checklist) //이전에 종료된 화면으로 이동
        }
        //로직 상으로 보면, 체크 리스트 복원은 앱이 시작될 때 한 번만 수행되어야 하므로, viewDidLoad가 맞다.
        //실행 순서는 viewDidLoad가 먼저, navigationController(_ : willShow : animated :)가 이후 실행 된 후, viewDidAppear가 실행된다.
        //따라서 저장된 값이 있더라도 navigationController(_ : willShow : animated :)의 값이 덮어씌워지게 된다.
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

//MARK: - UINavigationControllerDelegate
extension AllListsViewController: UINavigationControllerDelegate { //UINavigationControllerDelegate로 push, pop의 알림을 받을 수 있다.
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) { //navigationController에 새 화면이 표시될 때마다 호출
        if viewController === self { //뒤로 가기로 눌러 AllList(메인)으로 왔을 때
            // == 를 사용하면, 두 변수가 같은 값을 가지고 있는 지 확인
            // === 를 사용하면, 두 변수가 같은 객체를 참조하는 지 확인
            //여기서는 == 를 써도 동일한 결과를 반환하지만, === 가 더 정확한 표현이다.
            dataModel.indexOfSelectedChecklist = -1
        }
    } //navigationController (_ : willShow : animated :)가 먼저 실행 된 이후, viewDidAppear가 실행된다.
}

//MARK: - UITableViewDataSource
extension AllListsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return dataModel.lists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = makeCell(for: tableView)
        let checklist = dataModel.lists[indexPath.row]
        
        cell.textLabel!.text = checklist.name
        cell.accessoryType = .detailDisclosureButton
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) { //삭제
        dataModel.lists.remove(at: indexPath.row) //Model에서 삭제 후
        
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic) //View에서도 삭제
    }
}

//MARK: - UITableViewDelegate
extension AllListsViewController { //행이 선택된 이후 불리는 메서드
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataModel.indexOfSelectedChecklist = indexPath.row
        //UserDefaults를 활용해 필요한 정보를 간단하게 저장할 수 있다. UserDefaults 또한 sandbox에 저장된다.
        //UserDefaults는 일종의 dictionary로 생각하면 된다.
        //보통 적절한 값이 없을 경우는 -1로 저장한다. 보통 index가 0부터 시작하기 때문에.
        
        let checklist = dataModel.lists[indexPath.row]
        performSegue(withIdentifier: "ShowChecklist", sender: checklist) //코드로 세그를 실행할 수 있다. //sender에 보낼 객체를 지정한다.
        //스토리보드에서 컨트롤러 자체와 연결되는 세그를 설정하고 id를 입력한 후 특정 조건일 때 실행되게 하면 된다.
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) { //엑서서리를 탭했을 경우 이 메서드로 오게 된다.
        let controller = storyboard!.instantiateViewController(withIdentifier: "ListDetailViewController") as! ListDetailViewController
        //스토리보드에서 식별자로 뷰 컨트롤러 객체를 가져온다.
        controller.delegate = self
        
        let checklist = dataModel.lists[indexPath.row]
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
        let newRowIndex = dataModel.lists.count
        dataModel.lists.append(checklist)
        
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        let indexPaths = [indexPath]
        tableView.insertRows(at: indexPaths, with: .automatic)
        
        navigationController?.popViewController(animated: true)
    }
    
    func listDetailViewController(_ controller: ListDetailViewController, didFinishEditing checklist: Checklist) {
        if let index = dataModel.lists.index(of: checklist) { //객체로 배열의 해당 인덱스를 가져올 수 있다.
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.textLabel?.text = checklist.name
            }
        }
        
        navigationController?.popViewController(animated: true)
    }
}
