/// Copyright (c) 2017 Razeware LLC
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
import Helpers

public class API {

  public init() {
  }

  func loadTrainLines(_ completion: @escaping (Result<[TrainLine], NSError>) -> Void) {
    loadResponse(file: "lines") { result in
      completion(result.map { (response: LineResponse) in
        response.lines
      })
    }
  }

  public func loadLineGeography(_ completion: @escaping (Result<[TrainLineGeography], NSError>) -> Void) {
    loadResponse(file: "geography") { result in
      completion(result.map { (response: GeographyResponse) in
        response.lines
      })
    }
  }

  func loadSchedule(_ completion: @escaping (Result<[LineSchedule], NSError>) -> Void) {
    loadResponse(file: "schedule") { result in
      completion(result.map { (response: ScheudleResponse) in
        response.lines
      })
    }
  }

  private func loadResponse<T: Codable>(file: String, _ completion: @escaping (Result<T, NSError>) -> Void) {
    DispatchQueue.global().async {
      let trainURL = Bundle.main.url(forResource: file, withExtension: "json")!
      do {
        let jsonData = try Data(contentsOf: trainURL)
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mma"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        let response = try decoder.decode(T.self, from: jsonData)
        completion(Result(value: response))
      } catch (let error as NSError) {
        completion(Result(error: error))
      }
    }
  }
}
