/*:
 [Previous](@previous)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Next](@next)
 
 # Memento
 - - - - - - - - - -
 ![Memento Diagram](Memento_Diagram.png)
 
 The memento pattern allows an object to be saved and restored. It involves three parts:
 
 (1) The **originator** is the object to be saved or restored.
 
 (2) The **memento** is a stored state.
 
 (3) The **caretaker** requests a save from the originator, and it receives a memento in response. The care taker is responsible for persisting the memento, so later on, the care taker can provide the memento back to the originator to request the originator restore its state.
 
 ## Code Example
 */
//Memento Pattern을 사용하면 객체를 저장하고 복원할 수 있다. 세 가지 파트로 구성된다.
// 1. originator(작성자) : 저장하거나 복원할 객체
// 2. memento : 저장된 state를 나타낸다.
// 3. caretaker(관리자) : originator에게 저장을 요청하고, 이에 대한 응답으로 memento를 수신한다.
//  caretaker는 memento를 유지하고, 필요할 때 memento를 다시 originator에게 제공하여
//  originator의 state를 복원한다.
//iOS 앱은 일반적으로(반드시는 아니다) 인코더를 사용해 originator의 state를
//memento로 인코딩하고, 디코더가 memento를 다시 originator로 디코딩한다.
//이를 통해, originator 간에 인코딩 및 디코딩 논리를 재사용할 수 있다.
//ex. JSONEncoder와 JSONDecoder를 사용하면, 객체를 각각 JSON 데이터로
//  인코딩, 디코딩 할 수 있다.




//When should you use it?
//객체의 state를 저장하고, 나중에 복원해야 할 때 Memento Pattern을 사용한다.
//ex. 게임을 저장하는 시스템
//  originator는 game state(level, life) 이고, memento는 저장된 데이터 이다.
//  그리고 caretaker는 게임 시스템이다.
//이전 state의 stack을 나타내는 memento 배열을 구성할 수도 있다.
//이를 사용하면, IDE 또는 그래픽 소프트웨어에서 undo/redo 기능을 구현할 수 있다.




//Playground example
//Memento Pattern은 Behavioral Pattern 이다.

import Foundation

//MARK: - Originator
public class Game: Codable {
    //Codable를 준수하는 모든 유형은
    //자신을 변환하거나, 다른 외부 유형(external representation : ex. JSON)으로 변환할 수 있다.
    //기본적으로, 저장과 복원을 할 수 있는 유형이다.
    public class State: Codable { //게임 속성
        public var attemptsRemaining: Int = 3
        public var level: Int = 1
        public var score: Int = 0
    }
    //Swift 기본 유형은 Codable이 구현되어 있다.

    public var state = State()
    
    public func rackUpMassivePoints() {
        state.score += 9002
    }
    
    public func monstersEatPlayer() {
        state.attemptsRemaining -= 1
    }
}

//Codable은 Swift4 에서 도입 되었다. Codable를 준수하는 모든 유형은
//자신을 변환하거나, 다른 외부 유형(external representation : ex. JSON)으로 변환할 수 있다.
//기본적으로, 저장과 복원을 할 수 있는 유형이다.
//Game과 State에서 사용하는 모든 속성이 Codable을 준수하므로(기본 유형) 컴파일러는 필요한
//모든 Codable 프로토콜 메서드를 자동으로 생성한다.
//typealias Codable = Decodable & Encodable
//Codable은 Decodable와 Encodable 프로토콜이 결합된 형태이다.
//Encodable 유형은 인코더를 사용해, 외부 유형으로 변환될 수 있다.
//외부 유형의 실제 유형은 사용하는 Encoder에 따라 다르다.
//Foundation 에서는 JSON으로 변환할 수 있는 JSONEncoder 등 몇 가지 기본 인코더를 제공한다.
//Decodable 유형은 디코더를 사용해, 외부 유형을 변환할 수 있다.
//Foundation 에서는 JSON을 변환할 수 있는 JSONDecoder 등 몇 가지 기본 디코더를 제공한다.

//MARK: - Memento
typealias GameMemento = Data
//이 부분을 반드시 구현해야 하는 것은 아니다. GameMemento 유형이 Data 인 것을 알려준다.
//저장시, Encoder에서 생성되고, 복원 시 Decoder에서 사용된다.

//MARK: - CareTaker
public class GameSystem {
    private let decoder = JSONDecoder() //디코더
    private let encoder = JSONEncoder() //인코더
    private let userDefaults = UserDefaults.standard //데이터 저장할 객체
    //앱을 다시 시작하더라고 저장된 데이터를 계속 사용할 수 있다.
    
    public func save(_ game: Game, title: String) throws { //save 로직 캡슐화
        let data = try encoder.encode(game) //인코딩
        userDefaults.set(data, forKey: title) //데이터 저장
    }
    
    public func load(title: String) throws -> Game { //load 로직 캡슐화
        guard let data = userDefaults.data(forKey: title), //데이터를 가져온다.
            let game = try? decoder.decode(Game.self, from: data) else { //디코딩
            throw Error.gameNotFound //에러
        }
        
        return game //성공시 결과 반환
    }
    
    public enum Error: String, Swift.Error {
        case gameNotFound
    }
}

//MARK: - Example
var game = Game()
game.monstersEatPlayer()
game.rackUpMassivePoints()

//Save Game
let gameSystem = GameSystem()
try gameSystem.save(game, title: "Best Game Ever")

//New Game
game = Game()
print("New Game Score: \(game.state.score)") //Loaded Game Score: 0 //Load가 아닌 New 이므로 0

//Load Game
game = try! gameSystem.load(title: "Best Game Ever")
print("Loaded Game Score: \(game.state.score)") //Loaded Game Score: 9002




//What should you be careful about?
//Codable 속성은 인코딩, 디코딩 시 오류가 발생할 수 있으므로 추가하거나 제거할 때 주의해야 한다.
//try! 로 force unwrapping 할 때 오류가 발생하면 앱이 crash 된다.
//모델을 변경할 때 미리 계획 해야 한다. 버전을 지정해 관리할 수 있다.
//버전을 업그레이드하는 경우에는 이전 데이터를 삭제하거나 migration을 해야 한다.

