Chapter 2: How to Read a Class Diagram

클래스 다이어그램은 청사진과 같다. 이를 작성하기 위한 표준 언어는 Unified Modeling Language(UML) 이다.

What’s in a class diagram? p.29
클래스 다이어그램에는 Class, Protocol, Property, Method, relationship이 포함되어 있다.
Box는 클래스를 나타낸다. 클래스명은 박스 안에 표시한다.
상속 관계는 열린 화살표를 사용한다(화살표가 상위 클래스를 가리키도록 한다).
상속 대신 "is a" 로 읽는다. ex. "SheepDog 클래스가 Dog 클래스를 상속 : “SheepDog is a Dog."
속성은 일반 화살표로 표현한다(UML에서는 association이라고 한다). 화살표가 속성을 가리키도록 한다.
속성 관계는 "has a" 로 읽는다. ex. Dog 클래스가 Farmer 클래스의 속성 : "Farmer has a Dog."
화살표 옆에 범위를 지정하여 일대 다 관계를 나타낼 수 있다(1...*).
일대 다 관계를 표현하더라도 클래스 다이어그램에는 항상 단일 형식의 클래스 이름을 사용해야 한다(Dogs가 아닌 Dog).
프로토콜은 클래스와 같이 Box로 표시한다. 구별하기 위해 프로토콜 명 앞에 <<protocol>>를 붙인다.
점선으로 된 열린 화살표는 해당 프로토콜을 구현했음을 나타낸다. 
구현 관계는 "implements" 나 "conforms to" 로 읽는다. ex. "Farmer conforms to PetOwning."
클래스의 상속과 같이 화살표가 가리키는 대상이 프로토콜이다.
점섬으로된 일반 화사료는 use나 dependency를 표현한다(UML에서는 dependency).
종속 화살표는 모호한 경우가 많기 때문에 목적에 따라 주석을 달아줘야 한다. 종속 화살표는 다음과 같은 사항을 나타낼 수 있다.
 • weak property 혹은 delegate
 • 메서드의 매개 변수로 전달되었지만 property로 유지되지 않는 객체
 • IBAction과 같은 A loose coupling 혹은 callback
Class diagram 으로 각 속성과 메서드를 같이 나타낼 수도 있다. 박스 내부에 칸을 나눠 표기해 주면 된다.
화살표의 의미가 분명한 경우, 설명 텍스트를 생략할 수 있다. 일반적으로 상속, 속성, 구현 화살표가 이에 해당한다.
하지만, use(dependency) 화살표는 일반적으로 의미가 불분명한 경우가 많으므로 주석을 달아 준다.



