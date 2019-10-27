//
//  SequentialQuestionStrategy.swift
//  RabbleWabble
//
//  Created by 근성가이 on 2019/10/27.
//  Copyright © 2019 근성가이. All rights reserved.
//

public class SequentialQuestionStrategy: QuestionStrategy { //QuestionStrategy 구현
    //SequentialQuestionStrategy는 정의된 순대대로 question이 표시된다.
    
    //MARK: - Properties
    public var correctCount: Int = 0
    public var incorrectCount: Int = 0
    private let questionGroup: QuestionGroup
    private var questionIndex = 0
    
    //MARK: - Object Lifecycle
    public init(questionGroup: QuestionGroup) {
        self.questionGroup = questionGroup
    }
    
    //MARK: - QuestionStrategy
    public var title: String {
        return questionGroup.title
    }
    
    public func currentQuestion() -> Question {
        return questionGroup.questions[questionIndex]
    }
    
    public func advanceToNextQuestion() -> Bool {
        guard questionIndex + 1 < questionGroup.questions.count else {
            return false
        }
        
        questionIndex += 1
        
        return true
    }
    
    public func markQuestionCorrect(_ question: Question) {
        correctCount += 1
    }
    
    public func markQuestionIncorrect(_ question: Question) {
        incorrectCount += 1
    }
    
    public func questionIndexTitle() -> String {
        return "\(questionIndex + 1)/" + "\(questionGroup.questions.count)"
    }
}
