import UIKit

// MARK: - Generating Random Numbers

//: Before Swift 4.2, C APIs  had to be used to work with random numbers.  For example, to get a random number between 0 and 9, you could call `arc4random_uniform()`

let cRandom = Int(arc4random_uniform(10))
//Swift 4.2 이전에 랜덤한 수를 생성하기 위해서는 C 언어의 arc4random을 사용했다. 이는 Foundation을 import 해야 하며 Linux에서는 작동하지 않는다.

//: While this gave a random number, you had to import Foundation, it didn't work on linux, and wasn't very random thanks to modulo bias.  Now in Swift 4.2 the Standard Library includes some random API. Now to get a number between 0 and 9, use `random(in:)` on the `Int` class

let digit = Int.random(in: 0..<10)
//Swift 4.2 에서는 Standard Library에 Random API가 있다. 위의 코드와 결과가 같다. 제공된 범위에서 난수를 반환한다.

//: This returns a random number from the provided range.  You can also call `randomElement()` directly on a range

if let anotherDigit = (0..<10).randomElement() { //범위에서 직접 randomElement() 메서드를 사용해 난수를 가져올 수도 있다.
    //optional이므로 if let으로 바인딩 해야 한다.
    print(anotherDigit)
} else {
    print("Empty range.")
}

//: Asking for a random number this way on the range returns an optional, so it needs to be unwrapped with `if let`.  The random method also works on `Doubles`, `Floats` and `CGFloat`, and a no-argument version exists for `Boolean` so you flip a coin with a method call

let double = Double.random(in: 0..<1)
let float = Float.random(in: 0..<1)
let cgFloat = CGFloat.random(in: 0..<1)
let bool = Bool.random()
//Double, Float, CGFloat, Bool에도 적용된다. 특히 Bool은 동전 던지기 등의 T/F에 다양하게 사용할 수 있다.

// MARK: - Shuffling Lists

//: Numbers aren't the only type to get new random features - arrays also got some attention in Swift 4.2,  If I have an array of strings, `randomElement()` can be used to get a random string from the array

let playlist = ["Nothing Else Matters", "Stairway to Heaven", "I Want to Break Free", "Yesterday"]
if let song = playlist.randomElement() { //배열에서도 randomElement()로 값을 가져올 수 있다(위에서는 range).
    //optional이므로 if let으로 바인딩 해야 한다.
    print(song)
} else {
    print("Empty playlist.")
}

//: As with `randomElement()` with numbers, this returns an optional, so it is unwrapped with `if let`.

//: Another new feature that arrays get that is related to random is the ability to shuffle.  Before Swift 4.2, a feature like this had to be created by hand.  Now, a simple call to `shuffled()` will do.

let shuffledPlaylist = playlist.shuffled() //shuffled()은 무작위로 순서가 변경된 배열을 반환한다.

//: This return a shuffled array.  To sort in place you can simply call `shuffle()`

var names = ["Cosmin", "Oana", "Sclip", "Nori"]
names.shuffle()
