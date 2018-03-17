//
//  ImageAttachment.swift
//  UnCloudNotes
//
//  Created by 근성가이 on 2018. 3. 16..
//  Copyright © 2018년 Ray Wenderlich. All rights reserved.
//

import UIKit
import CoreData

class ImageAttachment: Attachment {
  @NSManaged var image: UIImage?
  @NSManaged var width: Float
  @NSManaged var height: Float
  @NSManaged var caption: String
}

//부모 엔티티는 부모 클래스와 비슷하다. ImageAttachment는 Attachment의 attributes를 상속 받는다.
