//
//  QuestionGroupBuilder.swift
//  RabbleWabble
//
//  Created by 근성가이 on 2019/11/05.
//  Copyright © 2019 근성가이. All rights reserved.
//

public class QuestionGroupBuilder {
    public var questions = [QuestionBuilder()]
    //초기에는 빈 문자열로 초기화된 Question 하나가 있는 배열이 된다.
    //따라서 questions에는 하나 이상의 Question이 반드시 존재해야 한다.
    public var title = ""
    
    public func addNewQuestion() {
        let question = QuestionBuilder()
        questions.append(question)
        //QuestionBuilder를 사용해, 새 question을 추가한다.
    }
    
    public func removeQuestion(at index: Int) {
        questions.remove(at: index)
        //question을 제거한다.
    }
    
    public func build() throws -> QuestionGroup {
        guard self.title.count > 0 else {
            throw Error.missingTitle
        }
        
        guard self.questions.count > 0 else {
            throw Error.missingQuestions
        }
        //하나 이상의 question이 있는 지 확인한다.
        
        let questions = try self.questions.map { try $0.build() }
        //question 생성
        
        return QuestionGroup(questions: questions, title: title)
    }
    
    public enum Error: String, Swift.Error {
        case missingTitle
        case missingQuestions
    }
}

public class QuestionBuilder {
    public var answer = ""
    public var hint = ""
    public var prompt = ""
    //Question을 작성하는데 필요한 inputs으로 answer, hint, prompt가 필요하다.
    //빈 문자열로 초기화
    
    public func build() throws -> Question {
        guard answer.count > 0 else { throw Error.missingAnswer }
        guard prompt.count > 0 else { throw Error.missingPrompt }
        //build()를 호출할 때마다, answer과 prompt가 설정되었는지 확인한다.
        //hint는 optional
        
        return Question(answer: answer, hint: hint, prompt: prompt)
    }
    
    public enum Error: String, Swift.Error {
        case missingAnswer
        case missingPrompt
    }
}

//QuestionGroupBuilder로 새로운 QuestionGroup을 생성한다.
//QuestionGroup에는 Question도 포함되어 있다.
