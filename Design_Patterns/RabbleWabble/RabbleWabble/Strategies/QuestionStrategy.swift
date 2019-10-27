//
//  QuestionStrategy.swift
//  RabbleWabble
//
//  Created by 근성가이 on 2019/10/27.
//  Copyright © 2019 근성가이. All rights reserved.
//

public protocol QuestionStrategy: class {
    var title: String { get } //question 세트의 title
    
    var correctCount: Int { get } //정답 수
    var incorrectCount: Int { get } //오답 수
    
    func advanceToNextQuestion() -> Bool //다음 question으로 넘어간다.
    //false이면 마지막 question
    
    func currentQuestion() -> Question //현재 question 반환
    //advanceToNextQuestion()이 out of index를 방지하기 때문에,
    //currentQuestion()는 항상 question을 반환한다.
    
    func markQuestionCorrect(_ question: Question) //정답 표시
    func markQuestionIncorrect(_ question: Question) //오답 표시
    
    func questionIndexTitle() -> String //현재 question의 index 반환
}
