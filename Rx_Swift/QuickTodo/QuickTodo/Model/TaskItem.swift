/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation
import RealmSwift
import RxDataSources

class TaskItem: Object {
    //Realm에서 사용할 객체
    @objc dynamic var uid: Int = 0
    @objc dynamic var title: String = ""
    
    @objc dynamic var added: Date = Date()
    @objc dynamic var checked: Date? = nil
    
    override class func primaryKey() -> String? {
        return "uid"
    }
}

extension TaskItem: IdentifiableType {
    //RxDataSources 셋션에 사용되는 유형은 IdentifiableType을 구현해야 한다.
    var identity: Int {
        return self.isInvalidated ? 0 : uid
    }
}

//Realm의 객체를 사용할 때 알아두어야 할 점이 있다.
//• 객체는 스레드를 통과할 수 없다. 다른 스레드에 객체가 필요하면, 다시 쿼리하거나 ThreadSafeReference를 사용해야 한다.
//• 객체가 자동으로 업데이트 된다. DB를 변경하면, DB에서 쿼리된 객체들에도 바로 반영 된다.
//• 객체를 삭제하면, 기존의 복사본이 모두 무효화 된다. 삭제된 쿼리 객체에 엑세스 하면 오류가 난다.


