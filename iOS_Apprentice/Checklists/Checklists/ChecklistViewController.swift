//
//  ChecklistViewController.swift
//  Checklists
//
//  Created by 근성가이 on 2016. 10. 23..
//  Copyright © 2016년 근성가이. All rights reserved.
//

import UIKit

class ChecklistViewController: UITableViewController {
    //MARK: - Properties
    var checklist: Checklist! //AllListViewController에서 넘어올 때, viewDidLoad가 실행 되기 이 전에 prepareForSegue가 먼저 실행되는 데, 이 때 nil이 된다. 따라서 옵셔널로. //실행 순서 - init - prepare - viewDidLoad
    
//    required init?(coder aDecoder: NSCoder) { //스토리보드에서 불러올 때 사용되는 이니셜라이저. ChecklistViewController가 스토리보드를 사용하므로 NSCoding이 구현되어 있다. 따라서 ChecklistItem처럼 NSCoding을 따로 구현해 줄 필요 없다,
//        items = [ChecklistItem]()
//        super.init(coder: aDecoder)
//        loadChecklistItems() //1. 이 클래스의 변수들이 값을 가지고, 2. super.init를 불러 초기화를 완료한 이후에, 3. self, method 등을 사용할 수 있다.
//    }
}

//MARK: - ViewLifeCycle
extension ChecklistViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = checklist.name
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: - Delegates
extension ChecklistViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checklist.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistItem", for: indexPath)
        let item = checklist.items[indexPath.row]
        
        configureText(for: cell, with: item)
        configureCheckmark(for: cell, with: item)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let item = checklist.items[indexPath.row]
            item.toggleChecked()
            configureCheckmark(for: cell, with: item)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) { //the table view will automatically enable swipe-to- delete
        checklist.items.remove(at: indexPath.row) //DB에서 삭제
        
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic) //테이블 뷰에서 삭제
    }
}

//MARK - ItemDetailViewControllerDelegate
extension ChecklistViewController: ItemDetailViewControllerDelegate {
    func itemDetailViewControllerDidCancel(
        _ controller: ItemDetailViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishAdding item: ChecklistItem) {
        let newRowIndex = checklist.items.count
        checklist.items.append(item)
        
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        let indexPaths = [indexPath]
        tableView.insertRows(at: indexPaths, with: .automatic)
        dismiss(animated: true, completion: nil)
    }
    
    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishEditing item: ChecklistItem) {
        if let index = checklist.items.index(of: item) { //배열에서 같은 객체의 인덱스 값을 찾는다. //equatable 구현해야 한다.
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) {
                configureText(for: cell, with: item)
            }
        }
        dismiss(animated: true, completion: nil)
    }
}

//MARK; - Segues
extension ChecklistViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddItem" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! ItemDetailViewController
            controller.delegate = self
        } else if segue.identifier == "EditItem" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! ItemDetailViewController
            controller.delegate = self
        
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                controller.itemToEdit = checklist.items[indexPath.row]
            }
        }
    }
}

extension ChecklistViewController {
    func configureCheckmark(for cell: UITableViewCell, with item: ChecklistItem) {
        let label = cell.viewWithTag(1001) as! UILabel
        label.textColor = view.tintColor
        
        if item.checked {
            label.text = "√"
        } else {
            label.text = ""
        }
    }
    
    func configureText(for cell: UITableViewCell, with item: ChecklistItem) {
        let label = cell.viewWithTag(1000) as! UILabel
        label.text = item.text
    }
}

/*
//MARK: - Data
extension ChecklistViewController {
    func documentsDirectory() -> URL { //App sandBox 경로 불러오기 - 다른 어플에서는 접근할 수 없는 고유 공간
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        return paths[0]
    }
    
    func dataFilePath() -> URL { //file://
        return documentsDirectory().appendingPathComponent("Checklists.plist")
    }
    
    func saveChecklistItems() {
        let data = NSMutableData() //값의 변경이 일어나므로 MutalbleData
        let archiver = NSKeyedArchiver(forWritingWith: data) //NSCoder로 plist 생성
        archiver.encode(items, forKey: "ChecklistItems") //items를 키 값으로 인코딩 //ChecklistItem이 인코딩 가능하도록 구현해 주어야 한다.
        archiver.finishEncoding() //인코딩 완료
        data.write(to: dataFilePath(), atomically: true) //경로에 저장
    }
    
    func loadChecklistItems() {
        let path = dataFilePath() //데이터가 저장된 경로를 불러온다.
        if let data = try? Data(contentsOf: path) { //경로에서 데이터를 불러온다. //값 변경이 없으므로 Data
            let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
            items = unarchiver.decodeObject(forKey: "ChecklistItems") as! [ChecklistItem]
            unarchiver.finishDecoding() //디코딩 완료
        }
    }
}
*/








