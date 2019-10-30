//
//  BaseQuestionStrategy.swift
//  RabbleWabble
//
//  Created by 근성가이 on 2019/10/29.
//  Copyright © 2019 근성가이. All rights reserved.
//

public class BaseQuestionStrategy: QuestionStrategy {
    //MARK: - Properties
    public var correctCount: Int {
        get { return questionGroup.score.correctCount }
        set { questionGroup.score.correctCount = newValue }
    }
    public var incorrectCount: Int {
        get { return questionGroup.score.incorrectCount }
        set { questionGroup.score.incorrectCount = newValue }
    }
    //Store Properties 대신, Computed Properties를 사용한다.
    
    private var questionGroupCaretaker: QuestionGroupCaretaker
    
    private var questionGroup: QuestionGroup { //Computed Property
        return questionGroupCaretaker.selectedQuestionGroup
    }
    private var questionIndex = 0
    private let questions: [Question]
    
    //MARK: - Object Lifecycle
    public init(questionGroupCaretaker: QuestionGroupCaretaker, questions: [Question]) {
        //QuestionGroup 대신 QuestionGroupCaretaker를 사용하는 생성자
        self.questionGroupCaretaker = questionGroupCaretaker //디스크에 대한 변경사항 유지
        self.questions = questions
//        self.questionGroupCaretaker.selectedQuestionGroup.score = QuestionGroup.Score()
        //새 인스턴스를 생성하므로, score는 앱을 시작할 때 마다 새로 작성된다.
        
        
        
        
        //Observer Pattern으로 변경
        self.questionGroupCaretaker.selectedQuestionGroup.score.reset()
    }
    
    //MARK: - QuestionStrategy
    public var title: String {
        return questionGroup.title
    }
    
    public func currentQuestion() -> Question {
        return questions[questionIndex]
    }
    
    public func advanceToNextQuestion() -> Bool {
        try? questionGroupCaretaker.save() //다음 question으로 넘어갈 때마다 score 저장
        
        guard questionIndex + 1 < questions.count else {
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
        return "\(questionIndex + 1)/\(questions.count)"
    }
}

//상당 부분이 RandomQuestionStrategy, SequentialQuestionStrategy 와 비슷하다.
