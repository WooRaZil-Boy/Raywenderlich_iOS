//
//  CategoryPickerViewController.swift
//  MyLocations
//
//  Created by 근성가이 on 2018. 2. 19..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import UIKit

class CategoryPickerViewController: UITableViewController {
    var selectedCategoryName = ""
    let categories = ["No Category", "Apple Store", "Bar", "Bookstore", "Club", "Grocery Store", "Historic Building", "House", "Icecream Vendor", "Landmark", "Park"]
    var selectedIndexPath = IndexPath()
    
    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0..<categories.count { //해당 인덱스를 알아야 하기에 for in 대신 이런 식으로 쓴다.
            //0에서 categories.count - 1 까지
            //for (i, category) in categories.enumerated()으로 해도 된다.
            if categories[i] == selectedCategoryName {
                selectedIndexPath = IndexPath(row: i, section: 0)
                
                break
            }
        }
    }
}

//MARK: - Navigations
extension CategoryPickerViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickedCategory" { //unwind segue의 경우
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPath(for: cell) { //셀 선택시 마다 selectedCategoryName을 업데이트 해서 할 수도 있지만, 여기서의 기능 상 단순히 마지막에 추가해 주는 것이 더 효율적이다.
                //뒤로 가기 눌렀을 경우, 따로 처리해 줄 필요가 없어진다.
                selectedCategoryName = categories[indexPath.row]
            }
        }
    }
}

//MARK: - UITableViewDataSource
extension CategoryPickerViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        //이 메서드는 프로토 타입 셀에서만 작동한다. cf.tableView.dequeueReusableCell(withIdentifier: )
        let categoryName = categories[indexPath.row]
        cell.textLabel!.text = categoryName
        
        if categoryName == selectedCategoryName { //선택된 카테고리라면
            cell.accessoryType = .checkmark
        } else { //선택된 카테고리가 아니라면
            cell.accessoryType = .none
        }
        
        let selection = UIView(frame: CGRect.zero)
        selection.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        cell.selectedBackgroundView = selection
        //selectedBackgroundView으로 선택된 셀의 컬러를 변경하는 듯한 효과를 얻을 수 있다.
        //셀을 탭할 때, 셀의 배경에 20% 투명도의 흰색 뷰가 배치된다.
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension CategoryPickerViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != selectedIndexPath.row { //이미 선택된 카테고리를 다시 선택하는 경우가 아니라면
            if let newCell = tableView.cellForRow(at: indexPath) { //선택한 셀을 체크
                newCell.accessoryType = .checkmark
            }
            
            if let oldCell = tableView.cellForRow(at: selectedIndexPath) { //이전 선택했던 카테고리 셀을 언 체크
                oldCell.accessoryType = .none
            }
            
            selectedIndexPath = indexPath
        }
    }
}
