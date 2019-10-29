//
//  Question.swift
//  RabbleWabble
//
//  Created by 근성가이 on 2019/10/24.
//  Copyright © 2019 근성가이. All rights reserved.
//

import Foundation

public class Question: Codable {
    //Memento Pattern을 구현하면서 struct에서 class로 변경해 준다.
    public let answer: String
    public let hint: String?
    public let prompt: String
    
    public init(answer: String, hint: String?, prompt: String) {
        self.answer = answer
        self.hint = hint
        self.prompt = prompt
    }
    //class는 생성자를 추가해 줘야 한다.
}
