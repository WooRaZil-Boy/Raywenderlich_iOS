import Vapor
import FluentPostgreSQL

final class Category: Codable {
    var id: Int? //optional
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

extension Category: PostgreSQLModel {}
extension Category: Content {}
extension Category: Migration {}
extension Category: Parameter {}

//Sibling relationships
extension Category {
    var acronyms: Siblings<Category, Acronym, AcronymCategoryPivot> {
        //Siblings<Base, Related, Through>
        //실제로 두 모델 사이의 관계를 만들려면 피벗을 사용해야 한다.
        //Acronym의 형제관계 computed property와 반대
        return siblings()
        //Fluent의 siblings() 함수를 메서드로 모든 Category를 검색한다.
    }
    
    //형제 관계는 두 모델을 서로 연결하는 관계를 설명한다. many-to-many relationship이라고도 한다.
    //parent-child relationship과 달리, 형제 관계에 있는 모델 간에는 제약 조건이 없다.
    //이 앱에서는 Acronym을 분류하는 것을 관계로 설정해 줄 수 있다.
    //Acronym이 하나 이상의 Category에 속할 수 있으며, Category에는 하나 이상의 Acronym이 포함될 수 있다.
}


