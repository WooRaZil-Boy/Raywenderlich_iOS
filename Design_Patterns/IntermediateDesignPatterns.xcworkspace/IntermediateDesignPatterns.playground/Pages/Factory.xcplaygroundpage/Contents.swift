/*:
 [Previous](@previous)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Next](@next)
 
 # Factory
 - - - - - - - - - -
 ![Factory Diagram](Factory_Diagram.png)
 
 The factory pattern provides a way to create objects without exposing creation logic. It involves two types:
 
 1. The **factory** creates objects.
 2. The **products** are the objects that are created.
 
 ## Code Example
 */
//Factory Pattern은 생성 논리를 노출시키지 않고 객체를 만든다.
//Factory Pattern에는 두 가지 type이 있다.
// 1. factory : 객체를 생성한다.
// 2. product : 생성된 객체이다.
//Factory Pattern은 simple factory, abstract factory 등 여러 유형이 있을 수 있다.
//이런 경우에도 각각은 공통의 목표(객체 생성 로직 분리)를 공유한다.
//일반적인 객체나 protocol로 Factory를 생성해 두면, 사용자가 이를 직접 사용하는 형태이다.




//When should you use it?
//직접 product를 만들지 않고, product의 생성 로직을 분리해야 할 때, Factory Pattern을 사용한다.
//Factory Pattern은 다형성(polymorphic) subclass나 동일한 protocol을 구현하는
//여러 객체와 같이 연관된 product 그룹이 있을 때 매우 유용하다.
//ex. Factory를 사용하여 네트워크의 response를 검사하고 구체적인 subtype으로 전환할 수 있다.
//Factory는 단일 product type인 경우에도 유용하지만,
//이때는 종속성이나 객체 생성에 필요한 정보를 제공해야 한다.
//ex. Factory를 사용하여, "job applicant response" 이메일을 작성한다.
//  Factory는 지원자의 수락 / 거절 여부에 따라 세부 사항을 생성할 수 있다.




//Playground example
import Foundation

public struct JobApplicant {
    public let name: String
    public let email: String
    public var status: Status
    
    public enum Status {
      case new
      case interview
      case hired
      case rejected
    }
}
//구직자 정보

public struct Email {
    public let subject: String
    public let messageBody: String
    public let recipientEmail: String
    public let senderEmail: String
}
//이메일의 subject와 messageBody는 구직자의 status에 따라 달라진다.

public struct EmailFactory { //Factory
    public let senderEmail: String
    //해당 속성을 EmailFactory 생성자에서 설정해 준다.
    
    public func createEmail(to recipient: JobApplicant) -> Email {
        let subject: String
        let messageBody: String
        
        switch recipient.status {
        case .new:
            subject = "We Received Your Application"
            messageBody = "Thanks for applying for a job here! " +
            "You should hear from us in 17-42 business days."
        case .interview:
            subject = "We Want to Interview You"
            messageBody = "Thanks for your resume, \(recipient.name)! " +
            "Can you come in for an interview in 30 minutes?"
        case .hired:
            subject = "We Want to Hire You"
            messageBody = "Congratulations, \(recipient.name)! " +
            "We liked your code, and you smelled nice. " +
            "We want to offer you a position! Cha-ching! $$$"
        case .rejected:
            subject = "Thanks for Your Application"
            messageBody = "Thank you for applying, \(recipient.name)! " +
            "We have decided to move forward " +
            "with other candidates. " +
            "Please remember to wear pants next time!"
        }
        //JobApplicant의 status에 따라 적절한 데이터로
        //subject과 messageBody를 채운다.
        
        return Email(subject: subject, messageBody: messageBody, recipientEmail: recipient.email, senderEmail: senderEmail)
        //Email 반환
    }
}
//factory Pattern은 Template을 구성하는 것과 비슷하다.

var jackson = JobApplicant(name: "Jackson Smith", email: "jackson.smith@example.com", status: .new)
//구직자 정보 생성
let emailFactory = EmailFactory(senderEmail: "RaysMinions@RaysCoffeeCo.com")
//Factory 인스턴스 생성

// New
print(emailFactory.createEmail(to: jackson), "\n")

// Interview
jackson.status = .interview
print(emailFactory.createEmail(to: jackson), "\n")

// Hired
jackson.status = .hired
print(emailFactory.createEmail(to: jackson), "\n")

//JobApplicant의 status에 따라 생성되는 Email이 다르다.




//What should you be careful about?
//모든 다형성(polymorphic) 객체에 Facoty가 필요한 것은 아니다.
//객체가 매우 단순하면, ViewController와 같은 consumer에 직접 생성 로직을 작성할 수 있다.
//또한, 객체에 일련의 단계가 필요한 경우에는 Builder Pattern 또는 다른 패턴을 사용하는 것이 좋다.
