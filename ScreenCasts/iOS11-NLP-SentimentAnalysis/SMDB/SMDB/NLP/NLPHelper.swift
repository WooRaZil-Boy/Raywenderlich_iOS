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
import CoreML

func getLanguage(text: String) -> String? {
  return NSLinguisticTagger.dominantLanguage(for: text)
}

func getSearchTerms(text: String, block: (String) -> Void) {
  let tagger = NSLinguisticTagger(tagSchemes: [.lemma], options: 0)
  tagger.string = text
  
  let options: NSLinguisticTagger.Options = [.omitWhitespace,
                                             .omitPunctuation,
                                             .omitOther,
                                             .joinNames]
  
  let range = NSRange(text.startIndex..., in: text)
  tagger.enumerateTags(in: range, unit: .word, scheme: .lemma, options: options) { (tag, tokenRange, _) in
    guard let tag = tag else { return }
    block(tag.rawValue.lowercased())
  }
}

func getPeopleNames(text: String, block: (String) -> Void) {
  let tagger = NSLinguisticTagger(tagSchemes: [.nameType], options: 0)
  tagger.string = text
  
  let options: NSLinguisticTagger.Options = [.omitWhitespace,
                                             .omitOther,
                                             .omitPunctuation,
                                             .joinNames]
  let range = NSRange(text.startIndex..., in: text)
  
  tagger.enumerateTags(in: range, unit: .word, scheme: .nameType, options: options) { (tag, tokenRange, _) in
    guard let tag = tag, tag == .personalName else { return }
    
    let token = Range(tokenRange, in: text)!
    block(String(text[token]))
  }
}

func predictSentiment(text: String) -> Int? {
  let counts = tokenizeAndCountWords(text: text) //NSLinguisticTagger로 분석.
  //해당 text의 토큰들이 Bag of word의 단어들의 index에 맞춰 count된 배열
  let model = Sentiment() //ML 모델을 가져온다.
  let input = try! MLMultiArray(shape: [1, NSNumber(value: words.count)], dataType: .int32)
  //ML model에 input할 데이터들을 담을 다차원 배열을 생성한다. input의 type은 ML 모델을 보면 확인할 수 있다(1, 189).
  //MLMultiArray는 모델의 input / output으로 주로 사용되는 다차원 배열이다.
  for (index, counts) in counts.enumerated() {
    input[index] = NSNumber(value: counts) //input할 데이터들을 배열에 담는다.
  }
  
  let prediction = try! model.prediction(wordCount: input) //모델로 추론한다(여기서는 lenear regression).
  let sentiment = prediction.sentiment //추론 결과
  
  return Int(sentiment) //T/F(1/0)으로 반환한다.
}

func tokenizeAndCountWords(text: String) -> [Int] {
  let tagger = NSLinguisticTagger(tagSchemes: [.lemma, .lexicalClass], options: 0)
  //NSLinguisticTagger는 품사 및 어휘 클래스에 태그를 지정하는 등 텍스트를 분석한다.
  //기본형 추출(stem = .lemma)할 NSLinguisticTagger를 생성한다.
  tagger.string = text //분석할 텍스트를 입력해 준다.
  let options: NSLinguisticTagger.Options = [.omitWhitespace, //공백 생략
                                             .omitPunctuation, //구두점 생략
                                             .joinNames, //단일 토큰으로
                                             .omitOther] //기호 생략
  //option을 지정해 준다.
    
  let range = NSRange(text.startIndex..., in: text) //분석할 범위(텍스트 전체)
  var wordCount = Array(repeating: 0, count: words.count) //words.count 수 만큼 0으로 채워진 배열 생성
  tagger.enumerateTags(in: range, unit: .word, scheme: .lemma, options: options) { (tag, _, _) in
    //입력된 text로 tag를 생성한다. //지정한 range 범위에서, word 단위로 토큰화 하고, lemma(기본형) 정보를, options로 enumeration 한다.
    guard let tag = tag else { return } //tag가 존재하는 지 확인한다.
    
    let word = tag.rawValue //index
    if let index = words.index(of: word) { //tag에 해당하는 단어가 Bag of word에 존재하는 경우
      wordCount[index] += 1 //tag의 index에 해당하는 배열의 요소를 1 증가시킨다(count).
    }
  }
  return wordCount //해당 text의 토큰들이 Bag of word의 단어들의 index에 맞춰 count된 배열
}

private let words = ["Austria", "Billy", "Chris", "Doctor", "Ellie", "I", "IDE", "Ms.", "Ning", "No", "Tiberius", "Xcode", "a", "all", "along", "also", "and", "annoy", "anything", "apocalypse", "aspiration", "at", "awful", "back", "background", "bad", "band", "be", "become", "believe", "better", "between", "big", "boo", "boring", "boy", "bug", "burger", "but", "by", "caffè", "can", "classic", "come", "confront", "contentious", "control", "crash", "cure", "dance", "dancing", "deadlock", "deadly", "die", "director", "disease", "do", "dragon", "dropping", "duet", "even", "eventually", "everything", "fabled", "famous", "fight", "film", "find", "finish", "fire", "follow", "for", "forget", "four", "from", "generation", "get", "go", "good", "great", "hah", "hat", "have", "he", "heartthrob", "hold", "horrible", "hour", "how", "iPhone", "ides", "in", "into", "involve", "it", "jaw", "joint", "joke", "journey", "keep", "killer", "leader", "learn", "legend", "life", "like", "literally", "little", "local", "lose", "loser", "loud", "love", "machine", "magnificent", "make", "many", "minus", "model", "money", "more", "most", "movie", "music", "need", "never", "nib", "night", "nil", "not", "now", "of", "oh", "on", "only", "oompah", "optional", "philosopher", "plague", "plot", "popular", "pretty", "punch", "really", "ride", "robot", "rule", "see", "service", "set", "show", "sing", "so", "spend", "star", "stop", "story", "straight", "stuff", "superb", "than", "that", "the", "there", "they", "thing", "think", "this", "three", "thrill", "through", "thumb", "time", "to", "total", "truly", "up", "use", "want", "watchdog", "way", "western", "what", "who", "why", "ya", "you", "young", "zombie"]
//Bag of word. 189(input의 수)
