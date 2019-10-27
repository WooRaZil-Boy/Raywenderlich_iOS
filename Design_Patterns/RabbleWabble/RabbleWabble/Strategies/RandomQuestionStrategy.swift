//
//  RandomQuestionStrategy.swift
//  RabbleWabble
//
//  Created by 근성가이 on 2019/10/27.
//  Copyright © 2019 근성가이. All rights reserved.
//

import GameplayKit.GKRandomSource
//Ramdom을 직접 구현할 수 있지만, 이미 작성된 로직을 가져와 쓸 수 있다.
//GameplayKit.GKRandomSource는 크기가 매우 작고 범위를 지정할 수 있기 때문에 효율이 좋다.

public class RandomQuestionStrategy: QuestionStrategy { //QuestionStrategy 구현
    //RandomQuestionStrategy는 임의의 순대대로 question이 표시된다.
    //MARK: - Properties
    public var correctCount: Int = 0
    public var incorrectCount: Int = 0
    private let questionGroup: QuestionGroup
    private var questionIndex = 0
    private let questions: [Question]
    
    //MARK: - Object Lifecycle
    public init(questionGroup: QuestionGroup) {
        self.questionGroup = questionGroup
        
        let randomSource = GKRandomSource.sharedRandom() //Singleton
        self.questions = randomSource.arrayByShufflingObjects(in: questionGroup.questions) as! [Question]
        //arrayByShufflingObjects 메서드는 배열을 인자로 받아, 임의의 순서로 섞는다.
        //NSArray를 반환하기 때문에 캐스팅 해 준다.
    }
    
    //MARK: - QuestionStrategy
    public var title: String {
        return questionGroup.title
    }
    
    public func currentQuestion() -> Question {
        return questions[questionIndex]
    }
    
    public func advanceToNextQuestion() -> Bool {
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


