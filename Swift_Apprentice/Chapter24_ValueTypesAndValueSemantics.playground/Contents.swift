//: Chapter 24: Value Types and Value Semantics

//Reference types
struct Color: CustomStringConvertible { //CustomStringConvertible으로 print() 형식을 지정해 줄 수 있다.
    var red, green, blue: Double
    var description: String { //CustomStringConvertible프로토콜에서는 description을 구현해야 한다.
        return "r: \(red) g: \(green) b: \(blue)"
    }
}

extension Color {
    static var black = Color(red: 0, green: 0, blue: 0)
    static var white = Color(red: 1, green: 1, blue: 1)
    static var blue  = Color(red: 0, green: 0, blue: 1)
    static var green = Color(red: 0, green: 1, blue: 0)
}

class Bucket {
    var color: Color
    var isRefilled = false
    
    init(color: Color) {
        self.color = color
    }
    
    func refill() {
        isRefilled = true
    }
}

let azurePaint = Bucket(color: .blue)
let wallBluePaint = azurePaint

wallBluePaint.isRefilled // => false, initially
azurePaint.refill()
wallBluePaint.isRefilled // => true, unsurprisingly!
//class는 reference 타입이므로

//Value types
extension Color {
    mutating func darken() { //메서드 내에서 프로퍼티의 값을 직접 바꿔주려면 mutating키워드를 사용해야 한다.
        red *= 0.9; green *= 0.9; blue *= 0.9
    }
}

var azure = Color.blue
var wallBlue = azure
azure  // r: 0.0 g: 0.0 b: 1.0
wallBlue.darken()
azure  // r: 0.0 g: 0.0 b: 1.0 (unaffected)
//struct는 value 타입이므로

//Defining value semantics
//Case 1. Primitive value types : 일반적인 값 유형. Int, String 등.
//Case 2. Composite value types : 복합적인 값 유형. Struct, Enum 등
//Case 3. Reference types : 레퍼런스 타입도 값 유형처럼 쓸 수 있다. immutable, read only로 선언해서 값이 변경되지 않도록 하면 된다. : UIKit에서 주로 사용
//Case 4. Value types containing mutable reference types : 변경 가능한 참조 유형을 포함하는 값 유형
struct PaintingPlan1
{
    var accent = Color.white
    var bucket = Bucket(color: .blue)
}

var artPlan1 = PaintingPlan1()
var housePlan1 = artPlan1

artPlan1.bucket.color // => blue
housePlan1.bucket.color = Color.green
artPlan1.bucket.color // => green. oops!
//bucket이 class 이므로

//Copy-on-write to the rescue
struct PaintingPlan2
{
    var accent = Color.white
    private var bucket = Bucket(color: .blue) //private로 접근할 수 없도록 한다. //일종의 스토리지

    var bucketColor: Color { //bucketColor를 수정할 때 마다 새로 Bucket을 작성한다.
        //COW 패턴으로 리소스 낭비를 줄일 수 있다. 평소에 리소스를 공유하면서, 수정할 경우가 발생하면 복사본을 쓰는 것.
        get {
            return bucket.color
        }
        set {
            bucket = Bucket(color: newValue)
        }
    }
}

var artPlan2 = PaintingPlan2()
var housePlan2 = artPlan2

housePlan2.bucketColor = Color.green
artPlan2.bucketColor // blue. better!

struct PaintingPlan
{
    var accent = Color.white
    private var bucket = Bucket(color: .blue) //일종의 스토리지

    var bucketColor: Color {
        get {
            return bucket.color
        }
        set {
            if isKnownUniquelyReferenced(&bucket) { //isKnownUniquelyReferenced로 단일 참조 여부 확인
                bucket.color = bucketColor //같은 레퍼런스로 변경하는 경우
            } else {
                bucket = Bucket(color: newValue)
            }
        }
    }
}

var artPlan = PaintingPlan()
var housePlan = artPlan

housePlan.bucketColor = Color.green
artPlan.bucketColor // blue. good!

//Beyond copy-on-write
//https://github.com/apple/swift/blob/master/docs/OwnershipManifesto.md



