//
//  ViewController.swift
//  WorldCup
//
//  Created by 근성가이 on 2017. 1. 2..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    //MARK: - Properties
    fileprivate let teamCellIdentifier = "teamCellReuseIdentifier"
    var coreDataStack: CoreDataStack!
    var fetchedResultsController: NSFetchedResultsController<Team>! //UITableView와 연동해서 쓰기 편함 //viewcController 아님. 인터페이스 빌더로 만드는 것이 아닌 코드로만 존재함 //제네릭으로
    
    //MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!

    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest: NSFetchRequest<Team> = Team.fetchRequest()
        
        //NSFetchedResultsController는 꼭 정렬을 한 후 fetch를 해야한다. 테이블 뷰의 올바른 순서를 알아야 하기 때문.
        let zoneSort = NSSortDescriptor(key: #keyPath(Team.qualifyingZone), ascending: true) //섹션을 사용할 때는 첫 번째 NSSortDescriptor의 속성이 일치해야 한다.
        let scoreSort = NSSortDescriptor(key: #keyPath(Team.wins), ascending: false)
        let nameSort = NSSortDescriptor(key: #keyPath(Team.teamName), ascending: true)
        
        fetchRequest.sortDescriptors = [zoneSort, scoreSort, nameSort] //순서대로 정렬이 된다.
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: coreDataStack.managedContext, sectionNameKeyPath: #keyPath(Team.qualifyingZone), cacheName: "worldCup") //지역 이름으로 섹션 만들기 //문자열 코드 대신 #keyPath 구문으로 오타를 방지할 수 있다. //캐싱, 섹션으로 그룹화 하거나 데이터가 큰 경우 캐싱하는 게 좋다.
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch() //Controller로 fetch //NSFetchedResultsController는 fetch 요청과 결과를 담는 컨테이너
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) { //모션이 끝났을 떄
        if motion == .motionShake { //기기를 흔들었을 경우
            addButton.isEnabled = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: - Internal
extension ViewController {
    func configure(cell: UITableViewCell, for indexPath: IndexPath) {
        guard let cell = cell as? TeamCell else {
            return
        }
        
        let team = fetchedResultsController.object(at: indexPath) //fetchedResultsController에서 객체 가져오기 //Array 필요없이 바로 가져 올 수 있다.
        cell.flagImageView.image = UIImage(named: team.imageName!)
        cell.teamLabel.text = team.teamName
        cell.scoreLabel.text = "Wins: \(team.wins)"
    }
    
    @IBAction func addTeam(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Secret Team", message: "Add a new team", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Team Name"
        }
        alert.addTextField { textField in
            textField.placeholder = "Qualifying Zone"
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] action in
            guard let nameTextField = alert.textFields?.first, let zoneTextField = alert.textFields?.last else {
                return
            }
            
            let team = Team(context: self.coreDataStack.managedContext)
            team.teamName = nameTextField.text
            team.qualifyingZone = zoneTextField.text
            team.imageName = "wenderland-flag"
            self.coreDataStack.saveContext()
        }
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default))
        
        present(alert, animated: true)
    }
}

//MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard  let sectionInfo = fetchedResultsController.sections?[section] else {
            return 0
        }
        
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: teamCellIdentifier, for: indexPath)
        configure(cell: cell, for: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections?[section] //배열이나 딕셔너리 없이 간단히 섹션을 구현할 수 있다.
        
        return sectionInfo?.name
    }
}

//MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let team = fetchedResultsController.object(at: indexPath) //NSFetchedResultsController에서 객체 가져오기
        team.wins = team.wins + 1
        
        coreDataStack.saveContext() //NSFetchedResultsController는 단순히 가져오기만 하는 것이 아니다. context를 가지고 있으므로 업데이트 하고 저장을 해도 반영이 된다.

//        tableView.reloadData() //Delegate로 이동
    }
}

//MARK: - NSFetchedResultsControllerDelegate
extension ViewController: NSFetchedResultsControllerDelegate { //NSFetchedResultsControllerDelegate 처음 생성할 때 가지고 있던 context의 변경만을 모니터링 할 수 있다. 
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) { //변경이 발생하려 할 때
        tableView.beginUpdates() //endUpdates()와 쌍으로 실행되어야 한다. 모든 셀을 다시 로드 하지 않고 특정 셀만 애니메이션과 함께 적용한다. //reloadData()보다 리소스를 적게 사용하고, 애니메이션 효과를 부드럽게 줄 수 있다.
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) { //직접 변경되는 부분 //indexPath :: 변경된 객체의 indexPath (삽입 시에는 nil), newIndexPath :: 삽입, 이동을 위한 객체의 indexPath (삭제 시에는 nil)
        switch type { //type은 insert, delete, update, move 네 가지 뿐.
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            let cell = tableView.cellForRow(at: indexPath!) as! TeamCell
            configure(cell: cell, for: indexPath!)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) { //콘텐츠 변화 시
//        tableView.reloadData() //didSelectRowAt에서 하는 것과 달리, 값이 변할 때마다 정렬을 변경하고, 테이블 뷰의 데이터 소스를 다시 조정한다.
        tableView.endUpdates() //reloadData()와 달리 전체 셀이 아닌 특정 셀만 변경한다. //beginUpdates()와 쌍을 이루어야 한다.
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) { //섹션에 변경 사항이 생길 때
        let indexSet = IndexSet(integer: sectionIndex)
        
        switch type {
        case .insert:
            tableView.insertSections(indexSet, with: .automatic)
        case .delete:
            tableView.deleteSections(indexSet, with: .automatic)
        default: break
        }
    }
}
