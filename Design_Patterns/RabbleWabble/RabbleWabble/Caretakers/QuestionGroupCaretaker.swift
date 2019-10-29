//
//  QuestionGroupCaretaker.swift
//  RabbleWabble
//
//  Created by 근성가이 on 2019/10/29.
//  Copyright © 2019 근성가이. All rights reserved.
//

import Foundation

public final class QuestionGroupCaretaker {
    //MARK: - Properties
    private let fileName = "QuestionGroupData" //저장하고 검색할 파일
    public var questionGroups: [QuestionGroup] = [] //사용중인 QuestionGroup 유지
    public var selectedQuestionGroup: QuestionGroup! //선택한 QuestionGroup 유지
    
    //MARK: - Object Lifecycle
    public init() {
        loadQuestionGroups()
    }
    
    private func loadQuestionGroups() {
        if let questionGroups = try? DiskCaretaker.retrieve([QuestionGroup].self, from: fileName) { //해당 파일이 있는 경우
            self.questionGroups = questionGroups
        } else { //파일이 생성되지 않은 경우(첫 실행)
            let bundle = Bundle.main
            let url = bundle.url(forResource: fileName, withExtension: "json")!
            self.questionGroups = try! DiskCaretaker.retrieve([QuestionGroup].self, from: url)
            
            try! save()
        }
    }
    
    //MARK: - Instance Methods
    public func save() throws {
        try DiskCaretaker.save(questionGroups, to: fileName)
    }
}

//Chapter 7: Memento Pattern

//Tutorial project
//QuestionGroup이 originator 역할을 한다.
//이전까지 struct로 QuestionGroup를 선언했지만, class로 변경한다.
//struct는 value type이지만, class는 reference type이다.
//따라서, class로 변경하면 QuestionGroup 객체를 복사하지 않고 전달하거나 수정할 수 있다.
//QuestionGroup과, Question을 Codable로 수정하고, caretaker를 생성한다.
//QuestionGroupData.json을 가져오고, 이전에 사용하던 하드코딩된 QuestionGroupData.swift를 삭제한다.
//처음 앱을 시작하면, Documents 디렉토리에서 QuestionGroupData.json 읽으려 시도하지만,
//파일이 존재하지 않으므로, 에러 메시지를 콘솔에 출력한다.
//하지만, 이 경우 Bundle의 QuestionGroupData.json에서
//파일을 불러와 저장하도록 했기 때문에 정상적으로 작동한다.
//다음으로 Score를 저장하기 위해서는 SequentialQuestionStrategy에서 코드를 수정해줘야 한다.
//RandomQuestionStrategy에서도 비슷한 논리가 있다. 이 코드를 그대로 복사해도 되지만,
//새로운 디자인 패턴과 기능을 추가할 때 리팩토링하는 게 좋을 때가 있다.
//이 경우에는 공유가능한 로직을 새로운 클래스로 가져와 리팩토링 한다.
//BaseQuestionStrategy를 생성하고 공통적으로 사용하는 로직을 옮긴다.
//이후, RandomQuestionStrategy와 SequentialQuestionStrategy가
//BaseQuestionStrategy를 상속하도록 변경하고 코드를 수정한다.
//AppSettings.swift의 questionStrategy(for :) 도 변경된 코드에 맞게 수정해 준다.
