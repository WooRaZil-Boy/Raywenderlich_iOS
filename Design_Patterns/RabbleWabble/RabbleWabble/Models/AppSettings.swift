//
//  AppSettings.swift
//  RabbleWabble
//
//  Created by 근성가이 on 2019/10/28.
//  Copyright © 2019 근성가이. All rights reserved.
//

import Foundation

public class AppSettings { //Singleton
    //MARK: - Keys
    private struct Keys { //UserDefaults에 저장하기 위한 key
        static let questionStrategy = "questionStrategy"
    }
    //String을 하드 코딩할 수 있지만, 구조체를 선언해 참조하는 방식으로 구현한다.
    
    //MARK: - Static Properties
    public static let shared = AppSettings()
    
    //MARK: - Instance Properties
    public var questionStrategyType: QuestionStrategyType {
        //사용자가 원하는 옵션을 유지한다. userDefaults를 사용해 옵션을 저장한다.
        get {
            let rawValue = userDefaults.integer(forKey: Keys.questionStrategy)
            
            return QuestionStrategyType(rawValue: rawValue)!
        } set {
            userDefaults.set(newValue.rawValue, forKey: Keys.questionStrategy)
        }
    }
    
    private let userDefaults = UserDefaults.standard //singleton
    //key-value 값을 저장한다.
    
    //MARK: - Object Lifecycle
    private init() {}
    
    //MARK: - Instance Methods
    public func questionStrategy(for questionGroup: QuestionGroup) -> QuestionStrategy {
        //선택한 questionStrategyType에 맞게, QuestionStrategy를 가져온다.
        return questionStrategyType.questionStrategy(for: questionGroup)
    }
}

//MARK: - QuestionStrategyType
public enum QuestionStrategyType: Int, CaseIterable {
    //앱에서 가능한 모든 QuestionStrategy에 대한 열거형
    //Swift 4.2부터 CaseIterable 프로토콜을 사용하면, 컴파일러가 allCases라는
    //static property를 추가한다. 이 속성은 해당 열거형의 모든 목록을 표시한다.
    case random
    case sequential
    
    //MARK: - Instance Methods
    public func title() -> String {
        switch self {
        case .random:
            return "Random"
        case .sequential:
            return "Sequential"
        }
    }
    
    public func questionStrategy(for questionGroup: QuestionGroup) -> QuestionStrategy {
        switch self {
        case .random:
            return RandomQuestionStrategy(questionGroup: questionGroup)
        case .sequential:
            return SequentialQuestionStrategy(questionGroup: questionGroup)
        }
    }
}
