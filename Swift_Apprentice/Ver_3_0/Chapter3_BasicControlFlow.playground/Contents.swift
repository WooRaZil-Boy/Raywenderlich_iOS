//: Chapter 3: Basic Control Flow

//Comparison operators
let yes: Bool = true //let yes = true
let no: Bool = false //let no = false

//Boolean logic
let and = true && true
let or = true || false

//String equality
let guess = "dog"
let dogEqualsCat = guess == "cat"
let order = "cat" < "dog"

//The if statement
if 2 > 1 {
    print("Yes, 2 is greater than 1.")
}

let animal = "Fox"

if animal == "Cat" || animal == "Dog" {
    print("Animal is house pet.")
} else {
    print("Animal is not a house pet.")
}

let hourOfDay = 12
let timeOfDay: String
if hourOfDay < 6 {
    timeOfDay = "Early morning"
} else if hourOfDay < 12 {
    timeOfDay = "Morning"
} else if hourOfDay < 17 {
    timeOfDay = "Afternoon"
} else if hourOfDay < 20 {
    timeOfDay = "Evening"
} else if hourOfDay < 24 {
    timeOfDay = "Late evening"
} else {
    timeOfDay = "INVALID HOUR!"
}
print(timeOfDay) //하나만 실행 된다. 밑의 else if 조건문들이 모두 사실이라도.

//Short circuiting
//Bool을 판단해 다음 조건까지 고려해야 하는 지 아닌지에 따라 결정.

//The ternary conditional operator
//(<CONDITION>) ? <TRUE VALUE> : <FALSE VALUE>
let a = 5
let b = 10

let min = a < b ? a : b
let max = a > b ? a : b
//min, max function이 따로 있다.

//While loops
var sum = 1

while sum < 1000 {
    sum = sum + (sum + 1)
}
print(sum)

//Repeat-while loops
sum = 1

repeat {
    sum = sum + (sum + 1)
} while sum < 1000 //조건문이 false라도 최소 한 번은 실행 한다.
print(sum)

//Breaking out of a loop
sum = 1
while true {
    sum = sum + (sum + 1)
    if sum >= 1000 {
        break
    }
}



