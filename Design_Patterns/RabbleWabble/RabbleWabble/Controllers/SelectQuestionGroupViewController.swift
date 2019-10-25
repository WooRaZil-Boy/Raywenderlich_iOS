//
//  SelectQuestionGroupViewController.swift
//  RabbleWabble
//
//  Created by 근성가이 on 2019/10/25.
//  Copyright © 2019 근성가이. All rights reserved.
//

import UIKit

public class SelectQuestionGroupViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet internal var tableView: UITableView! {
        //TableView를 사용해, Question Group 목록을 표시한다.
        didSet {
            //tableView가 설정될 때마다 Footer를 빈 UIView로 설정한다.
            tableView.tableFooterView = UIView()
            //TableView가 불필요한 빈 TableViewCell을 그리는 것을 방지한다.
            //tableFooterView는 기본적으로 다른 모든 셀을 그린 후 수행된다.
        }
    }
    
    //MARK: - Properties
    public let questionGroups = QuestionGroup.allGroups() //모든 QuestionGroup
    private var selectedQuestionGroup: QuestionGroup! //사용자가 선택한 QuestionGroup
}

//MARK: - UITableViewDataSource
extension SelectQuestionGroupViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 
        return questionGroups.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionGroupCell") as! QuestionGroupCell
        let questionGroup = questionGroups[indexPath.row]
        cell.titleLabel.text = questionGroup.title
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension SelectQuestionGroupViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        //선택한 QuestionGroup을 설정해 준다.
        //segue 실행 후, tableView(_:, didSelectRowAt:)이 호출되기 때문에 이곳에서 설정해야 한다.
        //tableView(_:, didSelectRowAt:)에서 selectedQuestionGroup을 설정하면,
        //selectedQuestionGroup이 nil이므로 crash 된다.
        selectedQuestionGroup = questionGroups[indexPath.row]
        
        return indexPath
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //선택한 셀을 해제해 준다. segue가 실행되서 ViewController가 전환되고,
        //나중에 다시 뒤로 가기로 돌아왔을 때, 선택한 셀을 표시하지 않는다.
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //segue가 실행되기 전에 호출된다.
        guard let viewController = segue.destination as? QuestionViewController else { return }
        //전환할 ViewController 확인
        
        viewController.questionGroup = selectedQuestionGroup
        viewController.delegate = self //delegate를 설정해 준다.
        //self이므로 해당 ViewController에서 QuestionViewControllerDelegate를 구현해 줘야 한다.
    }
}

//MARK: - QuestionViewControllerDelegate
extension SelectQuestionGroupViewController: QuestionViewControllerDelegate {
    public func questionViewController(_ viewController: QuestionViewController, didCancel questionGroup: QuestionGroup, at questionIndex: Int) {
        navigationController?.popToViewController(self, animated: true)
    }
    
    public func questionViewController(_ viewController: QuestionViewController, didComplete questionGroup: QuestionGroup) {
        navigationController?.popToViewController(self, animated: true)
    }
}

//Chapter 4: Delegate Pattern

//Tutorial project
//SelectQuestionGroupViewController.swift와 QuestionGroupCell.swift를 작성한다.

//Setting up the views
//Main.storyboard 에서 SelectQuestionGroupViewController와 QuestionGroupCell를 작성한다.
//Auto layout에서 Content Hugging와 Compression Resistance로,
//최대 크기, 최소 크기를 지정해 줄 수 있다. //https://academy.realm.io/kr/posts/ios-autolayout/
//TableView는 스토리보드에서, ViewController에 연결해 dataSource와 delegate를 설정해 준다.

//Displaying selected question groups
//스토리보드에서 SelectQuestionGroupViewController를 선택하고
//Editor 메뉴에서 Embed In ▸ Navigation Controller를 선택해 쉽게 추가해 줄 수 있다.
//SelectQuestionGroupViewController에서 QuestionViewController로 segue를 만들어 준다.
//Cell을 right-click으로 QuestionViewController로 연결해 주면 segue를 만들 수 있다.
//QuestionViewController에서 선택된 QuestionGroup의 question을 보여주도록 해야한다.
//그러기 위해서는 SelectQuestionGroupViewController가 UITableViewDelegate를 구현해야 한다.

//Creating a custom delegate
//현재 Controller에서 Cancel을 누르면 일반적으로 delegate로 caller에게 알리는 것이 일반적이다.
//Cancel button이 따로 없는 경우, back button을 주로 사용한다.
//QuestionViewController에 사용자 지정 delegate protocol을 작성한다.





//------------------------------------------------------------------------------------
