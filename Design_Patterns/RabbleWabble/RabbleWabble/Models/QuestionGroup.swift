//
//  QuestionGroup.swift
//  RabbleWabble
//
//  Created by 근성가이 on 2019/10/24.
//  Copyright © 2019 근성가이. All rights reserved.
//

import Foundation

public class QuestionGroup: Codable {
    //struct는 value type이지만, class는 reference type이다.
    public class Score: Codable { //Memento Pattern
        public var correctCount: Int = 0
        public var incorrectCount: Int = 0
        public init() { }
    }
    
    public let questions: [Question]
    public let title: String
    
    public var score: Score //Memento Pattern
    
    public init(questions: [Question], score: Score = Score(), title: String) {
        //score에 default 값을 지정해 준다(빈 Score 객체).
        self.questions = questions
        self.score = score
        self.title = title
    }
}

//여러 개의 Question을 담는 Container
