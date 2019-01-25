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

class Story {
  var title: String
  var content: String
  
  init(title: String, content: String) {
    self.title = title
    self.content = content
  }
  
  static func loadStories(_ completion: (@escaping ([Story]) -> Void)) {
    
    let path = Bundle.main.bundlePath
    let manager = FileManager.default
    
    var stories: [Story] = []
    
    if var contents = try? manager.contentsOfDirectory(atPath: path){
      contents = contents.sorted(by: <)
      
      for file in contents {
        
        if file.hasSuffix(".grm") {
          
          guard let filePath = URL(string: "file://" + path)?.appendingPathComponent(file) else { continue }
          let title = String(file.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: true)[0])
          
          if let content = try? NSString(contentsOf: filePath, encoding: String.Encoding.utf8.rawValue) {
            let story = Story(title: title, content: content as String)
            stories.append(story)
          }
        }
      }
    }
    
    DispatchQueue.main.async {
      completion(stories)
    }
  }
  
}

extension Story: CustomStringConvertible {
  
  var description: String {
    return title
  }
  
}
