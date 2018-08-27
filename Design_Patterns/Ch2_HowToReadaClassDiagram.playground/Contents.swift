//class diagram 은 청사진과 같다. 그림, 기호, 주석 등으로 정보를 표현한다.
//class diagram 을 작성하기 위한 표준 언어는 Unified Modeling Language(UML) 이다.

//What's in a class diagram? p.28
//class diagram 으로 class, protocol, property, method, relationship 을 표현할 수 있다.
//클래스는 네모 박스로 표현하고, 클래스의 이름은 박스 안에 쓸 수 있다.
//상속 관계를 표현할 때는 빈 화살표로 표현한다. 화살촉이 가리키는 대상이 부모이다. 상속 관계는 "inherits from," 이 아닌 "is a" 로 읽는다.
//ex. a "SheepDog" is a "Dog" (SheepDog, Dog은 클래스)
//일반 화살표로는 속성을 표현한다(UML에서는 association이라고 한다). 속성 관계는 "has a" 로 읽는다.
//ex. a "Farmer" has a "Dog" (Dog은 Farmer의 속성)
//상속 화살표는 항상 수퍼 클래스를 가리키고, 속성 화살표는 항상 속성 클래스를 가리킨다(영어로, "is a", "has a"로 표현해 보면 명확하다).
//속성 화살표 옆에 범위를 지정하여 one-to-many 관계를 나타낼 수 있다. 화살표 옆에 1...* 등으로 표시해 주면 된다.
//따라서, one-to-many의 관계를 표현할 때에도 class diagram의 클래스명은 항상 단수로 써야 한다.
//프로토콜도 클래스와 마찬가지로 네모 박스로 표현하지만, 구분하기 위해 프로토콜 명은 << name >> 으로 쓴다.
//프로토콜의 구현도 상속과 마찬가지로 구분하기 위해 점선의 빈 화살표로 나타낸다. 구현 관계는 "implements" 나 "conforms to" 로 읽는다.
//ex. "Farmer" conforms to "PetOwning" (Farmer가 PetOwning 프로토콜 구현)
//따라서 구현 화살표에서도 클래스의 상속과 같이 화살촉이 가리키는 대상이 프로토콜이다.
//점섬의 일반 화살표로는 use나 dependency를 표현한다(UML에서는 dependency).
//하지만 종속 화살표는 모호한 경우가 많기 때문에 목적에 따라 주석을 달아줘야 한다. 종속 화살표는 다음과 같은 사항을 나타낼 수 있다.
//• weak property 혹은 delegate
//• 메서드의 매개 변수로 전달되었지만 property가 없는 객체
//• IBAction과 같은 A loose coupling 혹은 callback
//class diagram 으로 각 속성과 메서드를 같이 나타낼 수도 있다.
//화살표의 의미가 분명한 경우, 설명 텍스트를 생략할 수 있다. 일반적으로 상속, 속성, 구현 화살표가 이에 해당한다.
//use(dependency) 화살표는 주석을 달아야 한다.
