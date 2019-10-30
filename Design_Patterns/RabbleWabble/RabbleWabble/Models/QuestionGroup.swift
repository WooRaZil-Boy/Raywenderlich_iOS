//
//  QuestionGroup.swift
//  RabbleWabble
//
//  Created by 근성가이 on 2019/10/24.
//  Copyright © 2019 근성가이. All rights reserved.
//

import Foundation
import Combine //Observer Pattern을 위해 Combine import

public class QuestionGroup: Codable {
    //struct는 value type이지만, class는 reference type이다.
    public class Score: Codable { //Memento Pattern
        public var correctCount: Int = 0 {
            didSet { updateRunningPercentage() } //값이 설정될 때 마다 percentage를 구한다.
        }
        public var incorrectCount: Int = 0 {
            didSet { updateRunningPercentage() } //값이 설정될 때 마다 percentage를 구한다.
        }
        //correctCount과 incorrectCount를 개별적으로 @Published 로 선언할 수 있지만,
        //이 앱에서는 percentage만 구하면 된다.
        
        public init() { }
        
        private enum CodingKeys: String, CodingKey { //enum 선언
            //컴파일러가 자동 생성하는 encoder, decoder 메서드에서 runningPercentage를 제외한다.
            case correctCount
            case incorrectCount
        }
        
        public required init(from decoder: Decoder) throws {
            //Custom initializer
            //score가 디코딩 되는 경우 runningPercentage 값을 설정해 줘야 한다.
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.correctCount = try container.decode(Int.self, forKey: .correctCount)
            self.incorrectCount = try container.decode(Int.self, forKey: .incorrectCount)
            updateRunningPercentage()
        }
        
        private func updateRunningPercentage() {
            let totalCount = correctCount + incorrectCount
            
            guard totalCount > 0 else {
                runningPercentage = 0
                return
            }
            
            runningPercentage = Double(correctCount) / Double(totalCount)
        }
        
        @Published public var runningPercentage: Double = 0
        //Observer Pattern Publisher 추가
        //이 속성의 인코딩, 디코딩 방법이 정의되어 있지 않기 때문에 새로 추가해 줘야 한다.
        
        public func reset() {
            correctCount = 0
            incorrectCount = 0
        }
    }
    
    public let questions: [Question]
    public let title: String
    
//    public var score: Score //Memento Pattern
    public private(set) var score: Score //Observer Pattern
    //외부 class에서 score의 값을 변경할 수 없다.
    
    public init(questions: [Question], score: Score = Score(), title: String) {
        //score에 default 값을 지정해 준다(빈 Score 객체).
        self.questions = questions
        self.score = score
        self.title = title
    }
}

//여러 개의 Question을 담는 Container
