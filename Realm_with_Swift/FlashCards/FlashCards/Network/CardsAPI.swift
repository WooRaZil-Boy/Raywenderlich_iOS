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

/// This is a mock CardsAPI class, which simulates asynchronous
/// communication with a JSON API

class CardsAPI {
  typealias SetName = String
  typealias Set = [String]

  typealias DownloadCallback = (SetName, [Set]) -> Void

  func downloadSet(named name: String,
                   callback: @escaping DownloadCallback) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      callback(name, downloadableSets[name] ?? [])
    }
  }
}

/// Predefined server responses

let downloadableSets: [CardsAPI.SetName: [CardsAPI.Set]] = [
  "Numbers": [["one", "uno"], ["two", "dos"], ["three", "tres"], ["four", "cuatro"],
              ["five", "cinco"], ["six", "seis"], ["seven", "siete"], ["eight", "ocho"],
              ["nine", "nueve"],["ten", "diez"]],

  "Colors": [["black", "negro"], ["blue", "azul"], ["brown", "marrón"], ["gold", "dorado"],
             ["gray", "gris"], ["green", "verde"], ["red", "rojo"], ["white", "blanco"]],

  "Greetings": [["How are you?", "¿Cómo está?"], ["Very good", "Muy bien"], ["Nice meeting you", "Mucho gusto"], ["Goodbye", "Adiós"],
                ["Hello", "Hola"], ["What's up?", "¿Qué tal?"]]
]
