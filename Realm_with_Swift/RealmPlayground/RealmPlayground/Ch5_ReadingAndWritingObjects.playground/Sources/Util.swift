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

// MARK: - Create test data to play with

public class TestDataSet {
  public static func create(`in` realm: Realm) throws {

    let author1 = Person(firstName: "Klark", born: Date(timeIntervalSince1970: 0))
    author1.hairCount = 1284639265
    author1.born = Date(timeIntervalSince1970: 0)
    author1.lastName = "Kent"

    let author2 = Person(firstName: "John", born: Date(timeIntervalSince1970: -30000))
    author2.hairCount = 140
    author2.born = Date(timeIntervalSince1970: 1806750000)
    author2.lastName = "Smith"

    let person1 = Person(firstName: "Jane", born: Date(timeIntervalSince1970: +50000))
    person1.hairCount = 1284639265
    person1.lastName = "Doe"
    person1.allowedPublicationOn = Date()
    person1.key = "test-key"

    let person2 = Person(firstName: "Boe", born: Date(timeIntervalSince1970: +50000))
    person2.hairCount = 1284639265
    person2.lastName = "Carter"
    person2.deceased = Date(timeIntervalSince1970: 1806750000)
    person2.allowedPublicationOn = Date()

    let person3 = Person(firstName: "Frank", born: Date(timeIntervalSince1970: +30000))
    person3.hairCount = 100000
    person3.lastName = "Power"
    person3.allowedPublicationOn = nil
    person3.aliases.append("Franky The Cone")
    person3.aliases.append("Big Frank")

    let article1 = Article()
    article1.title = "Jane Doe launches a successfull new product"
    article1.author = author1
    article1.people.append(person1)

    let article2 = Article()
    article2.title = "Musem of Modern Art opens a Boe Carter retrospective curated by Jane Doe"
    article2.author = author2
    article2.people.append(person3)
    article2.people.append(person1)

    try! realm.write {
      realm.add(author1)
      realm.add(author2)
      realm.add(person1)
      realm.add(person2)
      realm.add(article1)
      realm.add(article2)
    }
  }
}
