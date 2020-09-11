/// Copyright (c) 2019 Razeware LLC
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

struct Question {
  let title: String
  let isTrue: Bool
}

let questions = [
  ("As far as has ever been reported, no-one has ever seen an ostrich bury its head in the sand.", true),
  ("Approximately one quarter of human bones are in the feet.", true),
  ("Popeye’s nephews were called Peepeye, Poopeye, Pipeye and Pupeye.", true),
  ("In ancient Rome, a special room called a vomitorium was available for diners to purge food in during meals.", false),
  ("The average person will shed 10 pounds of skin during their lifetime.", false),
  ("The Great Wall Of China is visible from the moon.", false),
  ("Virtually all Las Vegas gambling casinos ensure that they have no clocks.", true),
  ("Risotto is a common Italian rice dish.", true),
  ("The prefix \"mega-\" represents one million.", true),
  ("The \"Forbidden City\" is in Beijing.", true),
  ("Hurricanes and typhoons are the same thing.", true),
  ("In Shakespeare's play, Hamlet commits suicide.", false),
  ("An American was the first man in space.", false),
  ("The \"China Syndrome\" is what hostages experience when they begin to feel empathy for their captors.", false),
  ("Other than water, coffee is the world's most popular drink.", true)
].map(Question.init)
