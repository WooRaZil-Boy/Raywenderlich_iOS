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
import HelpersStatic

public class Model {

  private let api: API
  public var lines: [TrainLine] = []

  public init(api: API = API()) {
    self.api = api
    api.loadTrainLines { result in
      guard let lines = result.value else { return }

      self.lines = lines
    }
  }

  public func line(forId id: Int) -> TrainLine? {
    return lines.first { $0.lineId == id }
  }

  public func schedule(forId id: Int, completion: @escaping (LineSchedule) -> ()) {
    api.loadSchedule { result in
      guard let lines = result.value else { return }

      let schedule = lines.first { $0.lineId == id }
      if let schedule = schedule {
        completion(schedule)
      }
    }
  }

  public func geography(forId id: Int, completion: @escaping (TrainLineGeography?) -> ()) {
    loadGeography { geography in
      let lineGeometry = geography.filter { $0.lineId == id }.first
      DispatchQueue.main.async {
        completion(lineGeometry)
      }
    }
  }

  fileprivate func loadGeography(_ completion: @escaping ([TrainLineGeography]) -> ()) {
    api.loadLineGeography { result in
      switch result {
      case .success(let geography):
        completion(geography)
      case .failure(let error):
        print("error loading geography: \(error)")
        completion([])
      }
    }
  }
}

