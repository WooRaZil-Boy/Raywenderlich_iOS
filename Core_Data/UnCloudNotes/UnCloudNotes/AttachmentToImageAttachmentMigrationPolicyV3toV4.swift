//
//  AttachmentToImageAttachmentMigrationPolicyV3toV4.swift
//  UnCloudNotes
//
//  Created by 근성가이 on 2018. 3. 16..
//  Copyright © 2018년 Ray Wenderlich. All rights reserved.
//

import CoreData
import UIKit

let errorDomain = "Migration"

class AttachmentToImageAttachmentMigrationPolicyV3toV4: NSEntityMigrationPolicy {
  //엔티티 매핑에 대한 정책을 지정해 줄 수 있다.
  //Model 편집기에서 FUNCTION 표현식 이상의 정책을 지정해 주려면 NSEntityMigrationPolicy를 직접 만들어야 한다.
  //이렇게 인스턴스별로 처리할 수 있는 코드를 작성하면 다른 부분에서 호출해 마이그레이션 해 줄 수 있다.
  //mapping model에서 엔티티 매핑의 Custom Policy를 모듈 이름을 포함한 이 클래스 이름으로 지정해 주면 된다.
  //이후 Custom Policy 위의 type이 Custom으로 바뀐다.
  
  override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
    //NSEntityMigrationPolicy의 구현을 재정의. migration manager가 대상 엔티티의 인스턴스를 만드는 데 사용한다.
    //sInstance가 원본 Data Model의 managed object이다. 이를 이용해 마이그레이션이 제대로 되도록 해야 한다.
    let description = NSEntityDescription.entity(forEntityName: "ImageAttachment", in: manager.destinationContext)
    //새로운 Data Model의 managedObjectContext로 새 Data Model의 객체 인스턴스를 만든다.
    //manager.destinationContext로 새로운 Data Model의 managedObjectContext를 가져온다.
    //NSMigrationManager에는 원본 Data Model의 CoreDatastack과 새 Data Model의 CoreDataStack 모두 있다.
    let newAttachment = ImageAttachment(entity: description!, insertInto: manager.destinationContext)
    //새 Data Model에서 사용할 managedObject를 생성한다.
    //ImageAttachment(context: )로 생성하지 않는다.
    //그 이유는 마이그레이션이 완료되지 않은 상태에서 완료된 모델에서 managedObjectContext를 가져오면 충돌? 아무튼 안씀.
    
    func traversePropertyMappings(block: (NSPropertyMapping, String) -> ()) throws { //내부 함수
      //마이그레이션 중에 반복문을 실행한다.
      //throws로 에러를 던지는 것을 명시해 준다. 해당 에러를 처리하는 부분은 이 함수 내부가 아닌 다른 곳에 있다.
      if let attributeMappings = mapping.attributeMappings {
        //매핑 인스턴스 엔티티의 attribute 배열을 가져온다. //NSPropertyMapping 배열이 된다.
        for propertyMapping in attributeMappings {
          if let destinationName = propertyMapping.name {
            block(propertyMapping, destinationName) //(매핑, 이름) 튜플로 block 클로저를 실행한다.
          } else {
            let message = "Attribute destination not configured properly"
            let userInfo = [NSLocalizedFailureReasonErrorKey: message]
            throw NSError(domain: errorDomain, code: 0, userInfo: userInfo) //에러를 던진다.
          }
        }
      } else {
        let message = "No Attribute Mappings found!"
        let userInfo = [NSLocalizedFailureReasonErrorKey: message]
        throw NSError(domain: errorDomain, code: 0, userInfo: userInfo) //에러를 던진다.
      }
    }
    
    try traversePropertyMappings { propertyMapping, destinationName in
      //traversePropertyMappings 함수를 실행해 유효한 값이 있다면 이 내부 클로저가 실행된다.
      //반복문을 돌면서 매핑된 이름에 따라 각 속성을 새로운 오브젝트에 넣는다.
      if let valueExpression = propertyMapping.valueExpression { //매핑 인스턴스의 표현식을 가져온다.
        let context: NSMutableDictionary = ["source": sInstance]
        //sInstance는 원본 Data Model의 managed object이다.
        
        guard let destinationValue = valueExpression.expressionValue(with: sInstance, context: context) else {
          //지정된 객체와 컨텍스트를 사용해 표현식 평가. 매핑모델에서 이미 정의한 식을 사용.
          return
        }
        
        newAttachment.setValue(destinationValue, forKey: destinationName)
        //새 Data Model에서 사용할 managedObject에 값을 할당한다.
        //자동으로 생성되어 매핑되어 있는 attribute를 새 Data Model 객체에 할당한다. //주로 이름이 이전과 같은 속성
      }
    } //이 코드 블럭 안에서는 매핑모델에서 정의된, 이전 Data Model과 매핑된 새 속성만 할당된다(주로 이름이 같은 속성).
    
    if let image = sInstance.value(forKey: "image") as? UIImage {
      //이전 Data Model에서 이미지를 가져온다. //이미지 변수는 v4에서는 삭제될 것이다.
      newAttachment.setValue(image.size.width, forKey: "width")
      newAttachment.setValue(image.size.height, forKey: "height")
      //새 Data Model의 각 값에 할당
    }
    
    let body = sInstance.value(forKey: "note.body") as? NSString ?? ""
    newAttachment.setValue(body.substring(to: 80), forKey: "caption")
    //caption 속성은 이전 Data Model의 본문에서 처음 80자를 가져와 할당한다.
    
    manager.associate(sourceInstance: sInstance, withDestinationInstance: newAttachment, for: mapping)
    //manager로 원본 Data Model의 오브젝트와 새로 Data Model을 지정된 매핑으로 연결한다.
    //이 메서드를 호출하지 않으면 새 Data Model의 데이터가 누락된다.
  }
  
  //CoreData가 마이그레이션을 실행하면 Custom Policy에 따라 이 클래스의 코드를 실행한다.
}

//CoreData는 v3 Data Model의 저장소가 있으면 지정된 매핑 모델로 새로운 Data Model(v4)를 만들고 마이그레이션 한다.
//그 때 NSEntityMigrationPolicy를 상속한 이 클래스가 매핑 모델에서 연결되어 있으므로
//위의 코드에 지정된 대로 마이그레이션 되며, 완료되면 이전 v3 저장소는 삭제된다.
//만약 마이그레이션 중 오류가 발생하면, 마이그레이션은 중단되고, v3 저장소는 삭제되지 않는다.
