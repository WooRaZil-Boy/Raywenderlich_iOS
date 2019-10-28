//
//  AppSettingsViewController.swift
//  RabbleWabble
//
//  Created by 근성가이 on 2019/10/28.
//  Copyright © 2019 근성가이. All rights reserved.
//

import UIKit

public class AppSettingsViewController: UITableViewController {
    //MARK: - Properties
    public let appSettings = AppSettings.shared //앱 세팅 singleton 객체
    private let cellIdentifier = "basicCell"
    
    //MARK: - View Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView() //tableFooterView 아래에 빈 UIView를 설정해 준다.
        //이렇게 하면, TableView의 맨 밑에 빈 Cell이 추가되지 않는다.
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        //Cell을 등록한다. tableView.dequeueReusableCell(withIdentifier:for:)를 호출할 때 마다
        //UITableViewCell 인스턴스를 얻는다.
    }
}

//MARK: - UITableViewDataSource
extension AppSettingsViewController {
    //UIViewController가 아닌 UITableViewController이므로
    //이미 DataSource와 Delegate는 구현되어 있다. 따라서 새로 작성하는 것이 아니라 override 한다.
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return QuestionStrategyType.allCases.count
        //전체 QuestionStrategy의 수를 반환한다.
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //해당 indexPath의 cell을 설정해 준다.
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let questionStrategyType = QuestionStrategyType.allCases[indexPath.row]
        cell.textLabel?.text = questionStrategyType.title()
        
        if appSettings.questionStrategyType == questionStrategyType {
            //현재 사용중인 questionStrategyType라면
            cell.accessoryType = .checkmark //체크
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension AppSettingsViewController {
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let questionStrategyType = QuestionStrategyType.allCases[indexPath.row]
        //cell을 선택할 때마다 지정된 indexPath.row에 대한 questionStrategyType을 가져온다.
        appSettings.questionStrategyType = questionStrategyType //선택한 questionStrategyType 설정
        tableView.reloadData() //리로드
    }
}

//Chapter 6: Singleton Pattern

//Tutorial project
//이전까지 question을 표시하는데 Strategy Pattern을 사용해, 무작위 또는 순차적으로 하드코딩했다.
//이는 사용자가 변경할 수 없음을 의미한다. Singleton을 구현해, 사용자가 질문을 표시할 방법을 선택하도록 한다.

//Creating the AppSettings singleton
//앱 설정을 저장할 AppSettings 객체를 만들어 준다.
//앱 전체에서 여러 세팅 인스턴스를 사용하는 것은 불필요하므로 Singleton plus 대신 Singleton을 사용한다.
//사용할 수 있는 옵션을 열거형으로 정리해 사용하면 편하다.
//Swift 4.2부터 CaseIterable 프로토콜을 사용하면, 컴파일러가 allCases라는 static property를 추가한다.
//이 속성은 해당 열거형의 모든 목록을 표시한다.

//Selecting the strategy
//세팅 화면을 구현하는 AppSettingsViewController를 작성한다.
//이후, 필요한 화면을 main.storyboard에서 구현한다.
//설정 이미지를 Library에서 그대로 navigation bar item에 drag-and-drop하면 된다.
//UITableViewController를 가져와서 설정을 하고 연결해 주면 된다.
//SelectQuestionGroupViewController.swift에서 Strategy Pattern을 하드 코딩한 부분을 수정한다.
