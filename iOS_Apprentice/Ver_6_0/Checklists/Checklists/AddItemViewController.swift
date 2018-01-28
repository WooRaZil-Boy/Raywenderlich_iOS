//
//  AddItemViewController.swift
//  Checklists
//
//  Created by 근성가이 on 2018. 1. 26..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import UIKit

//Cocoa touch 클래스로 만들어진 코멘트가 달린 코드를 보일러 플레이트(boilerplate)라 한다.
//네비게이션 컨트롤러와 탭 바 컨트롤러는 컨테이너라 생각하면 된다. (하나의 컨트롤러에는 하나의 화면)
//테이블 뷰에 섹션과 행의 수를 미리 알고 있는 경우에 Static cell을 사용할 수 있다. 

class AddItemViewController: UITableViewController { //하나의 뷰 컨트롤러의 여러개의 delegate 패턴을 가질 수 있다. (ex. 테이블 뷰, 테이블 뷰 데이터 소스, 텍스트 필트 ...)
    
    //@IBOutlet이나 @IBAction의 왼쪽 원을 눌러보면 어느 객체와 연결되어 있는지 알 수 있다.
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationItem.largeTitleDisplayMode = .never //스토리보드에서 설정해 줄 수 있다.
        
    }
    
    override func viewWillAppear(_ animated: Bool) { //뷰가 보인 후 활성화
        super.viewWillAppear(true)
        
        textField.becomeFirstResponder() //텍스트 필드 입력이 활성화 된다. //작은 부분이 큰 차이를 만든다.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel() {
        navigationController?.popViewController(animated: true) //pop. 빼낸다.
    }
    
    @IBAction func done() {
        print("Contents of the text field: \(textField.text!)")
        
        navigationController?.popViewController(animated:true)
    }
}

// MARK: - Table view data source
extension AddItemViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}

//MARK: - UITableView Delegate
extension AddItemViewController {
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? { //뷰에 선택되어질 때
        return nil //nil을 반환해 선택되어 지지 않도록 한다. //IndexPath? 이므로 옵셔널을 반환할 수 있다.
    } //행 선택이 불가능해 지도록 해도, 회색 음염이 잠시 그려지는 겨웅가 있다. //스토리보드에서 테이블 뷰 Cell의 Selection을 None으로 해 선택 시 아무 변화없도록 설정한다.
}

//MARK: - UITextFieldDelegate
extension AddItemViewController: UITextFieldDelegate { //스토리 보드에서 해당 텍스트 필드를 delegate로 연결한다.
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
}
