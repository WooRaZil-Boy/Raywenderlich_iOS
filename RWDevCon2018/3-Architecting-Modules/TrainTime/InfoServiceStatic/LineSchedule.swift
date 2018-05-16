/**
 * Copyright (c) 2017 Razeware LLC
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
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
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

public struct LineSchedule: Codable {

  public struct Run: Codable {
    public let train: Int
    public let departs: Date
    public let arrives: Date

    public init(from decoder: Decoder) throws {
      let values = try decoder.container(keyedBy: CodingKeys.self)
      train = try values.decode(Int.self, forKey: .train)

      //custom decoding to get basic date string into right NSDate
      departs = try Run.convertDate(values, key: .departs)
      arrives = try Run.convertDate(values, key: .arrives)
    }

    private static func convertDate(_ values: KeyedDecodingContainer<LineSchedule.Run.CodingKeys>, key: CodingKeys) throws -> Date {
      let hms = try values.decode(Date.self, forKey: key)
      var components = Calendar.current.dateComponents([.minute, .hour], from: hms)
      components.timeZone = TimeZone.current
      return Calendar.current.date(bySettingHour: components.hour!, minute: components.minute!, second: 0, of: Date())!
    }
  }

  public let lineId: Int
  public let schedule: [Run]
}
