import FluentPostgreSQL
import Foundation

final class AcronymCategoryPivot: PostgreSQLUUIDPivot, ModifiablePivot {
    //PostgreSQLUUIDPivot을 구현하는 객체 정의. PostgreSQLUUIDPivot는 Fluent Pivot의 helper protocol이다.
    //ModifiablePivot를 구현 해, 관계를 추가하고 제거할 수 있다.
    var id: UUID? //모델의 id //UUID이므로 Foundation이 필요하다.
    
    var acronymID: Acronym.ID
    var categoryID: Category.ID
    //두 등록 정보를 정의하여 Acronym 및 Category의 id를 링크한다.
    //이 프로퍼티들로 관계를 유지한다.
    
    typealias Left = Acronym
    typealias Right = Category
    //Pivot에서 필요한 Left와 Right의 유형을 정의한다. Fluent가 관계 있는 두 모델이 무엇인지 설명할 수 있게 한다.
    
    static let leftIDKey: LeftIDKey = \.acronymID
    static let rightIDKey: RightIDKey = \.categoryID
    //Fluent에게 관계의 각 side에 대한 id의 경로를 전달한다.
    
    init(_ acronym: Acronym, _ category: Category) throws {
        self.acronymID = try acronym.requireID()
        //Fluent의 메서드 requireID로 id를 가져온다.
        self.categoryID = try category.requireID()
    }
}

extension AcronymCategoryPivot: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        //prepare(on)을 override한다. //DB에서 실행할 마이그레이션 변경 설정
        return Database.create(self, on: connection) { builder in
            //DB에서 AcronymCategoryPivot에 대한 테이블을 생성한다.
            try addProperties(to: builder)
            //모든 필드를 DB에 추가한다(수동으로 추가할 필요가 없다).
            
            builder.reference(from: \.acronymID, to: \Acronym.id, onDelete: .cascade)
            //AcronymCategoryPivot의 acronymID 속성과 Acronym의 id 속성 사이에 참조를 추가한다(외래키 제약 조건).
            //cascade로 설정해 두면, Acronym를 삭제할 때, 관계가 자동으로 제거된다(원래대로 라면 삭제되지 않고 오류 발생 해야 한다).
            builder.reference(from: \.categoryID, to: \Category.id, onDelete: .cascade)
            //AcronymCategoryPivot의 categoryID 속성과 Category의 id 속성 사이에 참조를 추가한다.
        }
    }
    
    //Foreign key constraints
    //부모 자식 관계에서와 마찬가지로 형제 관계에서도 외래 키 제약 조건을 사용하는 것이 좋다.
    //현재 AcronymCategoryPivot은 Acronym 및 Category의 id를 확인하지 않는다.
    //이런 상황에서 피벗에 의해 연결된 Acronym와 Category를 삭제하면 오류가 표시되지 않고 관계가 유지된다.
    
    //새로운 외래키 제약 조건이 설정되면, DB를 재설정해야 한다(출시 전이라면 삭제 후 재설치). p.163
}

//Creating a pivot
//Parent Child Relationship에서 Acronym과 User 사이의 관계를 만들 때 Acronym에 User에 대한 참조를 추가했다.
//그러나 이런 관계는 쿼리하기에 너무 비효율적이므로 Sibling relationship을 모델링할 수 없다.
//예를 들어 한 Category 안에 Acronym 배열이 있을 때, 한 Acronym가 해당하는 Category를 가져오려면 각각의 Category를 모두 검색해야 한다.
//따라서 Sibling relationship을 유지하려면 별도의 모델이 필요하다. Fluent에서는 이것을 Pivot이라 한다.
//Pivot은 관계가 있는 Fluent로 이루어진 또 다른 유형이다.





