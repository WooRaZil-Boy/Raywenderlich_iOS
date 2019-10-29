//
//  SequentialQuestionStrategy.swift
//  RabbleWabble
//
//  Created by 근성가이 on 2019/10/27.
//  Copyright © 2019 근성가이. All rights reserved.
//

//public class SequentialQuestionStrategy: QuestionStrategy { //QuestionStrategy 구현
//    //SequentialQuestionStrategy는 정의된 순대대로 question이 표시된다.
//
//    //MARK: - Properties
////    public var correctCount: Int = 0
////    public var incorrectCount: Int = 0
//
//
//
//
//    //Memento Pattern으로 변경
//    public var correctCount: Int {
//        get {
//            return questionGroup.score.correctCount
//        } set {
//            questionGroup.score.correctCount = newValue
//        }
//    }
//    public var incorrectCount: Int {
//        get {
//            return questionGroup.score.incorrectCount
//        } set {
//            questionGroup.score.incorrectCount = newValue
//        }
//    }
//    //stored properties 대신 computed properties로 구현한다.
//
//    private let questionGroup: QuestionGroup
//    private var questionIndex = 0
//
//    //MARK: - Object Lifecycle
//    public init(questionGroup: QuestionGroup) {
//        self.questionGroup = questionGroup
//    }
//
//    //MARK: - QuestionStrategy
//    public var title: String {
//        return questionGroup.title
//    }
//
//    public func currentQuestion() -> Question {
//        return questionGroup.questions[questionIndex]
//    }
//
//    public func advanceToNextQuestion() -> Bool {
//        guard questionIndex + 1 < questionGroup.questions.count else {
//            return false
//        }
//
//        questionIndex += 1
//
//        return true
//    }
//
//    public func markQuestionCorrect(_ question: Question) {
//        correctCount += 1
//    }
//
//    public func markQuestionIncorrect(_ question: Question) {
//        incorrectCount += 1
//    }
//
//    public func questionIndexTitle() -> String {
//        return "\(questionIndex + 1)/" + "\(questionGroup.questions.count)"
//    }
//}




//Memento Pattern을 구현하면서 공통의 로직은 BaseQuestionStrategy로 이동한다.
public class SequentialQuestionStrategy: BaseQuestionStrategy {
    public convenience init(questionGroupCaretaker: QuestionGroupCaretaker) {
        let questionGroup = questionGroupCaretaker.selectedQuestionGroup!
        let questions = questionGroup.questions
        
        self.init(questionGroupCaretaker: questionGroupCaretaker, questions: questions)
        //정해진 순서대로 questions를 전달한다.
  }
}
