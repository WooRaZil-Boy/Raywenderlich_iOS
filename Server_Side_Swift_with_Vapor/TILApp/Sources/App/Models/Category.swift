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
    
    static func addCategory(_ name: String, to acronym: Acronym, on req: Request) throws -> Future<Void> {
        //Category 추가
        return Category.query(on: req)
            .filter(\.name == name) //파라미터의 name으로 동일한 Category 필터링한다.
            .first()
            .flatMap(to: Void.self) { foundCategory in
                if let existingCategory = foundCategory { //동일한 name을 가진 Category가 있다면
                    return acronym.categories
                        .attach(existingCategory, on: req)
                        //해당 acronym에 Category를 추가해주는 관계를 설정한다.
                        .transform(to: ())
                } else { //Category가 없다면
                    let category = Category(name: name)
                    //제공된 name으로 Category 객체를 만들어
                    
                    return category.save(on: req)
                        .flatMap(to: Void.self) { savedCategory in
                            //Category를 DB에 생성한다.
                            return acronym.categories
                                .attach(savedCategory, on: req)
                                //해당 acronym에 Category를 추가해주는 관계를 설정한다.
                                .transform(to: ())
                        }
                }
            }
    }
    
    //iOS 같은 REST API 클라이언트에서는 카테고리 하나 당 여러 request를 보낼 수 있다.
    //하지만, 웹의 경우에는 이 같은 작업이 불가능하다. 웹은 하나의 request에 모든 정보를 받고, 해당 Fluent 작업으로 request를 변환해야 하기 때문이다.
    //또한 사용자가 카테고리를 선택하기 전에 카테고리를 만들어야만 한다.
}





