//
//  QuestionViewController.swift
//  RabbleWabble
//
//  Created by 근성가이 on 2019/10/24.
//  Copyright © 2019 근성가이. All rights reserved.
//

import UIKit

//public protocol QuestionViewControllerDelegate: class {
//    func questionViewController(_ viewController: QuestionViewController, didCancel questionGroup: QuestionGroup, at questionIndex: Int)
//    //cancel 버튼을 누르는 경우 호출
//    func questionViewController(_ viewController: QuestionViewController, didComplete questionGroup: QuestionGroup)
//    //모든 question을 완료한 경우 호출
//}




public protocol QuestionViewControllerDelegate: class {
    func questionViewController(_ viewController: QuestionViewController, didCancel questionGroup: QuestionStrategy)
    //cancel 버튼을 누르는 경우 호출
    func questionViewController(_ viewController: QuestionViewController, didComplete questionStrategy: QuestionStrategy)
    //모든 question을 완료한 경우 호출
}

//Strategy Pattern으로 변경

public class QuestionViewController: UIViewController {
    //public 키워드를 추가해 준다. 다른 type, property, method 등이 공개적으로 접근할 수 있다.
    //private의 경우에는 자체에서만 접근할 경우 붙여준다.
    //internal는 subclass 또는 related type에서 접근하는 경우에 사용한다.
    //이런 키워드들을 access control라고 한다.
    //파일을 별도의 모듈로 옮겨야 하는 경우(공유 라이브러리, 프레임워크 생성 등), 필요하다.
    //처음부터 access control를 사용하는 습관을 들이는 것이 좋다.
    
    //MARK: - Instance Properties
    public weak var delegate: QuestionViewControllerDelegate? //custom delegate
    
    public var questionStrategy: QuestionStrategy! {
        didSet {
            navigationItem.title = questionStrategy.title
        }
        //Strategy Pattern
        //questionStrategy에서 question을 순서(SequentialQuestionStrategy)대로 출력할지,
        //랜덤(RandomQuestionStrategy)으로 출력할지 결정한다.
    }
    
//    public var questionGroup: QuestionGroup! {
//        didSet {
//            navigationItem.title = questionGroup.title
//            //네비게이션 상단에 title을 지정해 준다.
//        }
//    }
    //Strategy Pattern으로 변경하면서 삭제
    
    public var questionIndex = 0 //현재 Question index. 다음 question으로 넘어갈 때 +1
    
    public var correctCount = 0
    public var incorrectCount = 0
    
    public var questionView: QuestionView! { //computed property
        guard isViewLoaded else { return nil }
        
        return (view as! QuestionView)
    }
    
    private lazy var questionIndexItem: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        item.tintColor = .black
        navigationItem.rightBarButtonItem = item
        //네비게이션 오른쪽에 barButtonItem 추가
        
        return item
    }()
    
    //MARK: - View Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCancelButton()
        showQuestion()
    }
    
    private func setupCancelButton() {
        let action = #selector(handleCancelPressed(sender:))
        let image = UIImage(named: "ic_menu")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, landscapeImagePhone: nil, style: .plain, target: self, action: action)
        //네비게이션 왼쪽에 barButtonItem 추가
        //버튼을 누르면, delegate에 연결된 메서드가 실행된다.
    }
    
    @objc private func handleCancelPressed(sender: UIBarButtonItem) {
//        delegate?.questionViewController(self, didCancel: questionGroup, at: questionIndex)
        
        
        
        //Strategy Pattern 으로 변경
        delegate?.questionViewController(self, didCancel: questionStrategy)
    }
    
    private func showQuestion() {
//        let question = questionGroup.questions[questionIndex]
//
//        questionView.answerLabel.text = question.answer
//        questionView.promptLabel.text = question.prompt
//        questionView.hintLabel.text = question.hint
//
//        questionView.answerLabel.isHidden = true
//        questionView.hintLabel.isHidden = true
//
//        questionIndexItem.title = "\(questionIndex + 1)/" + "\(questionGroup.questions.count)"
        
        
        
        
        //Strategy Pattern 으로 변경
        let question = questionStrategy.currentQuestion()
        
        questionView.answerLabel.text = question.answer
        questionView.promptLabel.text = question.prompt
        questionView.hintLabel.text = question.hint

        questionView.answerLabel.isHidden = true
        questionView.hintLabel.isHidden = true
        
        questionIndexItem.title = questionStrategy.questionIndexTitle()
    }
    
    //MARK: - Actions
    @IBAction func toggleAnswerLabels(_ sender: Any) {
        //Tap Gesture Recognizer와 연결한다.
        questionView.answerLabel.isHidden = !questionView.answerLabel.isHidden
        questionView.hintLabel.isHidden = !questionView.hintLabel.isHidden
    }
    
    @IBAction func handleCorrect(_ sender: Any) {
        //정답
//        correctCount += 1
//        questionView.correctCountLabel.text = "\(correctCount)"
//        showNextQuestion()
        
        
        
        
        //Strategy Pattern 으로 변경
        let question = questionStrategy.currentQuestion()
        questionStrategy.markQuestionCorrect(question)
        questionView.correctCountLabel.text = String(questionStrategy.correctCount)
        showNextQuestion()
        
    }
    
    @IBAction func handleIncorrect(_ sender: Any) {
        //오답
//        incorrectCount += 1
//        questionView.incorrectCountLabel.text = "\(incorrectCount)"
//        showNextQuestion()
        
        
        
        
        //Strategy Pattern 으로 변경
        let question = questionStrategy.currentQuestion()
        questionStrategy.markQuestionIncorrect(question)
        questionView.incorrectCountLabel.text = String(questionStrategy.incorrectCount)
        showNextQuestion()
    }
    
    private func showNextQuestion() {
        //다음 question으로 넘어간다.
        
//        questionIndex += 1
//
//        guard questionIndex < questionGroup.questions.count else {
//            //남은 question이 있어야 한다.
//            delegate?.questionViewController(self, didComplete: questionGroup)
//            return
//        }
//
//        showQuestion()
        
        
        
        guard questionStrategy.advanceToNextQuestion() else {
            delegate?.questionViewController(self, didComplete: questionStrategy)
            
            return
        }
        
        showQuestion()
        //Strategy Pattern 으로 변경
        //delegate 메서드를 호출하기 때문에 변경에 유의해야 하며, questionGroup이 필요하다. 구현 방법은
        // 1. QuestionGroup을 QuestionStrategy 프로토콜에 추가하거나
        // 2. QuestionViewControllerDelegate 메서드를 업데이트하여
        //  QuestionGroup대신 QuestionStrategy를 사용하도록 해야 한다.
        //이러한 옵션들이 있을 때 각각의 결과를 고려해야 한다.
        // • QuestionGroup을 노출할 경우, 앱 디자인이 복잡해지고 유지 관리하기 어려워지는가?
        // • QuestionGroup 대신 QuestionStrategy으로 변경하고, QuestionGroup이 필요한 경우가 있는가?
        // • QuestionViewControllerDelegate를 구현하는 기존 클래스가
        //  QuestionGroup 매개변수를 사용하고 의존하는가?
        //여기에서는 QuestionViewControllerDelegate를 업데이트 하고,
        //QuestionGroup을 QuestionStrategy으로 변경한다.
    }
}

//Chapter 3: Model-View-Controller Pattern

//Tutorial project
//언어 학습 앱을 만든다. 새 프로젝트를 생성하고 설정을 완료한다.
//ViewController.swift 파일을 열고, 내부 코드를 모두 삭제한다.
//이후, ViewController를 right-click 하여, Refactor ▸ Rename.... 을 선택한다.
//QuestionViewController 를 입력하고 변경하면 모든 해당 내용이 변경된다.
//File hierarchy의 RabbleWabble 그룹 하위에 새로운 그룹을 생성한다(Command + Option + N).
//이름을 지정하고, 파일들을 정렬해 그룹 안으로 넣어준다.
//SceneDelegate는 iOS 13에서 도입된 새로운 클래스이다. 앱에 여러 개의 scene이 실행되도록 관리한다.
//iPad와 같이 큰 화면에서 특히 유용하다. 이 앱에서는 사용하지 않는다.
//Info.plist를 이동했으므로, Xcode에 새로운 위치를 알려줘야 한다.
//파란색의 RabbleWabble 프로젝트를 선택하고, Targets에서 RabbleWabble을 선택한다.
//Build Settings 탭에서, Packaging 메뉴의 info.plist File에서 경로를 바르게 지정해 준다.
//이런식으로 파일을 그룹화해 두면, 유지 보수 하는 데 용이하다.

//Creating the models
//Model을 생성한다. 해당 폴더에 필요한 파일을 생성하고 작업한다.

//Creating the view
//View를 생성한다. 해당 폴더에 필요한 파일들을 생성하고 작업한다.
//View는 main.storyboard에 필요한 컨트롤러를 추가해야 한다.
//storyboard에서 library를 항상 표시되게 하려면, option-click을 하면 된다.
//여러 개의 컨트롤러를 선택한 상태에서 Horizontal Center를 선택해 줄 수 있다.

//Creating the controller
//Controller를 작업한다. Tap Gesture Recognizer를 IBAction에 연결한다.
//------------------------------------------------------------------------------------




//Chapter 5: Strategy Pattern

//Tutorial project
//Strategy Pattern을 사용해 Question이 순서대로 표시되거나 무작위로 표시 하는 두 옵션을 허용하도록 한다.
//Strategies 그룹을 만들어 프로토콜을 작성하고, 각 class를 구현한다.
//이후 QuestionViewController에서 Strategy Pattern을 구현한다.
//showNextQuestion()을 수정할 때 delegate 메서드를 호출하기 때문에 변경에 유의해야 하며,
//questionGroup이 필요하다. 구현 방법으로는
// 1. QuestionGroup을 QuestionStrategy 프로토콜에 추가하거나
// 2. QuestionViewControllerDelegate 메서드를 업데이트하여
//  QuestionGroup대신 QuestionStrategy를 사용하도록 해야 한다.
//이러한 옵션들이 있을 때 각각의 결과를 고려해야 한다.
// • QuestionGroup을 노출할 경우, 앱 디자인이 복잡해지고 유지 관리하기 어려워지는가?
// • QuestionGroup 대신 QuestionStrategy으로 변경하고, QuestionGroup이 필요한 경우가 있는가?
// • QuestionViewControllerDelegate를 구현하는 기존 클래스가
//  QuestionGroup 매개변수를 사용하고 의존하는가?
//여기에서는 QuestionViewControllerDelegate를 업데이트 하고,
//QuestionGroup을 QuestionStrategy으로 변경한다.
//QuestionGroup을 더 이상 사용하지 않으므로 삭제하고,
//SelectQuestionGroupViewController에서도 QuestionGroup을 사용하는 코드를 변경해 준다.
