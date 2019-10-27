/*:
 [Previous](@previous)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Next](@next)
 
 # Strategy
 - - - - - - - - - -
 ![Strategy Diagram](Strategy_Diagram.png)
 
 The strategy pattern defines a family of interchangeable objects.
 
 This pattern makes apps more flexible and adaptable to changes at runtime, instead of requiring compile-time changes.
 
 ## Code Example
 */
//Strategy Pattern은 런타임 시 set하거나, switch될 수 있는 interchangeable 객체를 정의한다.
//Strategy Pattern에는 세 가지 Part가 있다.
// • object using a strategy : Strategy를 사용하는 객체.
//  iOS 개발에서는 주로 ViewController이지만, 모든 종류의 객체가 될 수 있다.
// • strategy protocol : Strategy가 구현해야 하는 메서드를 정의한다.
// • strategies : Strategy Protocol을 구현하는 객체




//When should you use it?
//두 개 이상의 서로 다른 동작을 interchange할 수 있는 경우 Strategy Pattern을 사용한다.
//이 패턴은 Delegate Pattern가 유사하다.
//두 패턴 모두 유연성을 위해 구체적인 객체 대신 프로토콜에 의존한다.
//따라서 Strategy Pattern을 구현하는 모든 객체를 런타임시 Strategy으로 사용할 수 있다.
//Delegate와 달리 Strategy Pattern은 일련의 객체(family of objects)를 사용한다.
//Delegate는 종종 런타임에 fix된다.
//ex. UITableView의 dataSource와 delegate는 Interface Builder에서 설정할 수
//있으며, 런타임 중에 변경되는 경우는 거의 없다.
//그러나, Strategy Pattern은 이와 달리, 런타임시 interchangeable 하도록 고안되었다.




//Playground example
//Strategy Pattern은 다른 객체를 사용해 작업을 수행하는 패턴이므로, Behavioral Pattern 이다.
//"영화 등급"을 서비스하는 앱에서, 각 서비스에 대한 코드를 ViewController에 직접 작성하지 않고,
//복잡한 if-else 문이 있는 경우, Strategy Pattern을 사용하여 모든 서비스에 대한 공통 API를
//정의하는 Protocol을 작성하여 작업을 단순화할 수 있다.

import UIKit

public protocol MovieRatingStrategy {
    var ratingServiceName: String { get } //서비스 등급
    
    func fetchRating(for movieTitle: String, success: (_ rating: String, _ review: String) -> ())
    //영화의 등급을 비동기적으로 가져온다. 실제 앱에서는 네트워크 환경에 따라 실패할 수도 있다.
}

public class RottenTomatoesClient: MovieRatingStrategy {
    public let ratingServiceName = "Rotten Tomatoes"
    
    public func fetchRating(for movieTitle: String, success: (_ rating: String, _ review: String) -> ()) {
        //실제 서비스에서는 네트워크를 요청한다.
        //여기서는 더미 데이터로 대신한다.
        let rating = "95%"
        let review = "It rocked!"
        
        success(rating, review)
    }
}

public class IMDbClient: MovieRatingStrategy {
    public let ratingServiceName = "IMDb"
    
    public func fetchRating(for movieTitle: String, success: (_ rating: String, _ review: String) -> ()) {
        let rating = "3 / 10"
        let review = """
          It was terrible! The audience was throwing rotten
          tomatoes!
          """
        success(rating, review)
    }
}

//두 Client 모두 MovieRatingStrategy를 준수하므로, 이를 사용하려 할 때,
//직접적인 내용을 알 필요 없이 프로토콜에만 의존할 수 있다.

public class MovieRatingViewController: UIViewController {
    //MARK: - Properties
    public var movieRatingClient: MovieRatingStrategy!
    
    //MARK: - Outlets
    @IBOutlet public var movieTitleTextField: UITextField!
    @IBOutlet public var ratingServiceNameLabel: UILabel!
    @IBOutlet public var ratingLabel: UILabel!
    @IBOutlet public var reviewLabel: UILabel!
    
    //MARK: - View Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        ratingServiceNameLabel.text = movieRatingClient.ratingServiceName
    }
    
    //MARK: - Actions
    @IBAction public func searchButtonPressed(sender: Any) {
        guard let movieTitle = movieTitleTextField.text else { return }
        
        movieRatingClient.fetchRating(for: movieTitle) { (rating, review) in
            self.ratingLabel.text = rating self.reviewLabel.text = review
        }
    }
}

//이 ViewController가 인스턴스화 될 때마다 movieRatingClient를 설정해야 한다.
//ViewController는 movieRatingClient의 구체적인 구현에 대해 알지 못한다.
//사용할 MovieRatingStrategy 객체를 결정하는 것은 런타임 중일 수 있고,
//앱 구현에 따라 사용자가 이를 선택하는 경우일 수도 있다.




//What should you be careful about?
//Strategy Pattern을 과도하게 사용하는 것에 주의해야 한다.
//특히, 어떤 behavior이 변하지 않는다면, Strategy Pattern을 사용하지 않고
//ViewController 나 객체 context에 바로 코드를 작성해도 된다.
//이 패턴의 트릭은 behavior의 시기를 아는 것이므로, 필요하다면 lazy로 선언할 수 있다.


