//
//  Attachment.swift
//  UnCloudNotes
//
//  Created by 근성가이 on 2018. 3. 16..
//  Copyright © 2018년 Ray Wenderlich. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Attachment: NSManagedObject {
  @NSManaged var dateCreated: Date
//  @NSManaged var image: UIImage? //v4에서 삭제
  @NSManaged var note: Note? //이건 optional되면 안 되는 것 아닌가?
}

//새로운 데이터 모델에 맞춰 Managed Object를 만든다.
//v3에서는 이전 엔티티의 요소가 삭제, 분할되고 관계가 생긴다.
