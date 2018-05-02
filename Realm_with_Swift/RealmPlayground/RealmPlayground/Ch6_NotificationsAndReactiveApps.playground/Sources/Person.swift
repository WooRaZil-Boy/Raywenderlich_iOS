/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import RealmSwift
import CoreLocation

////////////////////////////
//  Person Realm Object
////////////////////////////

public class Person: Object {
  // object properties
  // string
  @objc public dynamic var firstName = ""
  @objc public dynamic var lastName: String?

  // date
  @objc public dynamic var born = Date.distantPast
  @objc public dynamic var deceased: Date?

  // data
  @objc public dynamic var photo: Data?

  // primitive types
  // bool
  @objc public dynamic var isVIP = false
  public let hasConsentedPublication = RealmOptional<Bool>()

  // Int, Int8, Int16, Int32, Int64
  @objc public dynamic var id = 0 //defaults to Int
  @objc public dynamic var hairCount: Int64 = 0
  public let timesContacted = RealmOptional<Int>()

  // Float, Double
  @objc public dynamic var height: Float = 0.0
  @objc public dynamic var weigth: Double = 0.0

  // dynamic properties
  public var isDeceased: Bool {
    return deceased != nil
  }

  public var fullName: String {
    guard let last = lastName else {
      return firstName
    }
    return "\(firstName) \(last)"
  }

  // custom type CLLocation
  let lat = RealmOptional<Double>()
  let lng = RealmOptional<Double>()

  public var lastLocation: CLLocation? {
    get {
      guard let lat = lat.value, let lng = lng.value else {
        return nil
      }
      return CLLocation(latitude: lat, longitude: lng)
    }
    set {
      guard let location = newValue else {
        lat.value = nil
        lng.value = nil
        return
      }
      lat.value = location.coordinate.latitude
      lng.value = location.coordinate.longitude
    }
  }

  // lists
  public let aliases = List<String>()
  
  // ignored properties
  public let idPropertyName = "id"
  public var temporaryId = 0 // automatically ignored in Swift4, because no Objc?
  @objc public dynamic var temporaryUploadId = 0

  override public static func ignoredProperties() -> [String] {
    return ["temporaryUploadId"]
  }

  // required vs. optional properties, default values, and required to override
  public convenience init(firstName: String, born: Date, id: Int) {
    self.init()
    self.firstName = firstName
    self.born = born
    self.id = id
  }

  // primary key (primary vs. auto-increment)
  @objc public dynamic var key = UUID().uuidString
  public override static func primaryKey() -> String? {
    return "key"
  }
}
