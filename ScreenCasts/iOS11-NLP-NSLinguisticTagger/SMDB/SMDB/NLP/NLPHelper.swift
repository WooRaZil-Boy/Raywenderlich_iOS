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
  //NSLinguisticTagger는 품사 및 어휘 클래스에 태그를 지정하는 등 텍스트를 분석한다.
  //dominantLanguage로 지정된 문자열의 주요 언어를 반환한다.
}

func getSearchTerms(text: String, block: (String) -> Void) {
  let tagger = NSLinguisticTagger(tagSchemes: [.lemma], options: 0)
  //기본형 추출(stem = .lemma)할 NSLinguisticTagger를 생성한다.
  tagger.string = text //분석할 텍스트를 입력해 준다.
  
  let options: NSLinguisticTagger.Options = [.omitWhitespace, //공백 생략
                                             .omitPunctuation, //구두점 생략
                                             .omitOther, //기호 생략
                                             .joinNames] //단일 토큰으로
  //option을 지정해 준다.
  
  let range = NSRange(text.startIndex..., in: text) //분석할 범위(텍스트 전체)
  tagger.enumerateTags(in: range, unit: .word, scheme: .lemma, options: options) { (tag, tokenRange, _) in
    //입력된 text로 tag를 생성한다. //지정한 range 범위에서, word 단위로 토큰화 하고, lemma(기본형) 정보를, options로 enumeration 한다.
    guard let tag = tag else { return } //tag가 존재하는 지 확인한다.
    block(tag.rawValue.lowercased()) //소문자로
    
    //기본형을 찾기 때문에 dance를 입력해도, dancing, dances 등을 함께 찾는다.
    //good을 검색해도, best까지 찾을 수 있다.
    //cf. scheme를 .tokenType 으로 입력하면, 정확히 일치하는 해당 토큰만 찾는다.
  }
}

func getPeopleNames(text: String, block: (String) -> Void) {
  let tagger = NSLinguisticTagger(tagSchemes: [.nameType], options: 0)
  //이름 추출(.nameType)할 NSLinguisticTagger를 생성한다.
  tagger.string = text //분석할 텍스트를 입력해 준다.
  
  let options: NSLinguisticTagger.Options = [.omitWhitespace,
                                             .omitOther,
                                             .omitPunctuation,
                                             .joinNames]
  //option을 지정해 준다.
    
  let range = NSRange(text.startIndex..., in: text) //분석할 범위(텍스트 전체)
  
  tagger.enumerateTags(in: range, unit: .word, scheme: .nameType, options: options) { (tag, tokenRange, _) in
    //입력된 text로 tag를 생성한다. //지정한 range 범위에서, word 단위로 토큰화 하고, nameType(이름) 정보를, options로 enumeration 한다.
    guard let tag = tag, tag == .personalName else { return }
    //tag가 존재하는 지 확인한다. 사람이름이어야 한다.
    
    let token = Range(tokenRange, in: text)! //해당 text에서 토큰(이름)의 range
    block(String(text[token])) //해당 text에서 이름이 위치하고 있는 range를 잘라서 이름만 가져온다.
  }
}

func predictSentiment(text: String) -> Int? {
  // To be replaced
  return nil
}

func tokenizeAndCountWords(text: String) -> [Int] {
   // To be replaced
  return []
}

private let words = ["Austria", "Billy", "Chris", "Doctor", "Ellie", "I", "IDE", "Ms.", "Ning", "No", "Tiberius", "Xcode", "a", "all", "along", "also", "and", "annoy", "anything", "apocalypse", "aspiration", "at", "awful", "back", "background", "bad", "band", "be", "become", "believe", "better", "between", "big", "boo", "boring", "boy", "bug", "burger", "but", "by", "caffè", "can", "classic", "come", "confront", "contentious", "control", "crash", "cure", "dance", "dancing", "deadlock", "deadly", "die", "director", "disease", "do", "dragon", "dropping", "duet", "even", "eventually", "everything", "fabled", "famous", "fight", "film", "find", "finish", "fire", "follow", "for", "forget", "four", "from", "generation", "get", "go", "good", "great", "hah", "hat", "have", "he", "heartthrob", "hold", "horrible", "hour", "how", "iPhone", "ides", "in", "into", "involve", "it", "jaw", "joint", "joke", "journey", "keep", "killer", "leader", "learn", "legend", "life", "like", "literally", "little", "local", "lose", "loser", "loud", "love", "machine", "magnificent", "make", "many", "minus", "model", "money", "more", "most", "movie", "music", "need", "never", "nib", "night", "nil", "not", "now", "of", "oh", "on", "only", "oompah", "optional", "philosopher", "plague", "plot", "popular", "pretty", "punch", "really", "ride", "robot", "rule", "see", "service", "set", "show", "sing", "so", "spend", "star", "stop", "story", "straight", "stuff", "superb", "than", "that", "the", "there", "they", "thing", "think", "this", "three", "thrill", "through", "thumb", "time", "to", "total", "truly", "up", "use", "want", "watchdog", "way", "western", "what", "who", "why", "ya", "you", "young", "zombie"]
