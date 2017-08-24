//
//  AllListsViewController.swift
//  Checklists
//
//  Created by 근성가이 on 2016. 10. 29..
//  Copyright © 2016년 근성가이. All rights reserved.
//

import UIKit

class AllListsViewController: UITableViewController {
    //MARK - Properties
    var dataModel: DataModel!
}

//MARK: - ViewLifeCycle
extension AllListsViewController {
    override func viewWillAppear(_ animated: Bool) { //뷰가 보여지고, 애니메이션은 아직 시작되지 않을 때 불려진다. //여기서는 네비게이션 백 버튼 눌러 돌아왔을 때
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) { //뷰가 보여지고, 애니메이션이 종료된 후 불려진다.
        super.viewDidAppear(animated)
        
        navigationController?.delegate = self //모든 viewController는 navigationController 프로퍼티를 가지고 있다.
        
        let index = dataModel.indexOfSelectedChecklist //UserDefaults.standard.integer(forKey: )는 값을 찾지 못하면 0을 할당한다. - 따라서 처음 실행할 시에는 인덱스 0에 대한 값이 없으므로 crash가 난다.
        if index >= 0 && index < dataModel.lists.count { //사실 구현한 부분에서는 index != -1와 같은 조건이지만, 이렇게 하면 차후에 확장되더라도 더 많은 예외 상황에 제대로 대응이 가능하다.
            let checklist = dataModel.lists[index]
            performSegue(withIdentifier: "ShowChecklist", sender: checklist)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: - Delegates
extension AllListsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel.lists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = makeCell(for: tableView)
        let checklist = dataModel.lists[indexPath.row]
        cell.textLabel?.text = checklist.name
        cell.accessoryType = .detailDisclosureButton
        
        let count = checklist.countUncheckedItems()
        if checklist.items.count == 0 {
            cell.detailTextLabel!.text = "(No Items)"
        } else if count == 0 {
            cell.detailTextLabel!.text = "All Done!"
        } else {
            cell.detailTextLabel!.text = "\(count) Remaining"
        }
        
        cell.imageView!.image = UIImage(named: checklist.iconName)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataModel.indexOfSelectedChecklist = indexPath.row
    
        let checklist = dataModel.lists[indexPath.row]
        performSegue(withIdentifier: "ShowChecklist", sender: checklist) //스토리 보드 세그를 실행. 결국 prepareForSegue로 감
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        dataModel.lists.remove(at: indexPath.row)
        
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let navigationController = storyboard!.instantiateViewController(withIdentifier: "ListDetailNavigationController") as! UINavigationController
        
        let controller = navigationController.topViewController as! ListDetailViewController //topViewController 프로퍼티는 NaviagationController의 현재 뷰 컨트롤러. [0]과 다를 수 있다.
        controller.delegate = self
        
        let checklist = dataModel.lists[indexPath.row]
        controller.checklistToEdit = checklist
        
        present(navigationController, animated: true, completion: nil)
    }
}

extension AllListsViewController {
    func makeCell(for tableView: UITableView) -> UITableViewCell {
        let cellIdentifier = "Cell"
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            return cell
        } else {
            return UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
    }
}

extension AllListsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowChecklist" {
            let controller = segue.destination as! ChecklistViewController //Add, Edit의 경우 modal로 열리는 데, 그 경우에는 Navigation을 포함하고 있다. 그러나 이 경우에는 push로 보내는 데 이 때는 바로 ViewController로 연결이 되므로 NavigationController를 찾을 필요 없다. //스토리보드를 보면 바로 연결이 되어 있는 지, 중간에 Navigation이 끼워져 있는 지 알 수 있다.
            controller.checklist = sender as! Checklist
        } else if segue.identifier == "AddChecklist" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! ListDetailViewController
            controller.delegate = self
            controller.checklistToEdit = nil
        }
    }
}

//MARK: - Delegate
extension AllListsViewController: ListDetailViewControllerDelegate {
    func listDetailViewControllerDidCancel(_ controller: ListDetailViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func listDetailViewController(_ controller: ListDetailViewController, didFinishAdding checklist: Checklist) {
        dataModel.lists.append(checklist)
        dataModel.sortChecklists()
        tableView.reloadData()
        
        dismiss(animated: true, completion: nil)
    }
    
    func listDetailViewController(_ controller: ListDetailViewController, didFinishEditing checklist: Checklist) {
        dataModel.sortChecklists()
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - Delegate
extension AllListsViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) { //네비게이션 컨트롤러가 새 스크린 슬라이드 할 때마다 호출
        if viewController === self { //Back 버튼 누른 경우 //===는 메모리 주소 값 비교, ==는 단순 값 비교. 여기서는 어느 것을 해도 똑같은 결과가 나오지만 정확히는 ===가 옳다.
            dataModel.indexOfSelectedChecklist = -1 //메인 화면 = self로 돌아온 경우에는 -1 할당
        }
    }
}
