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
import UIKit

enum CardViewMode {
  case full
  case card
}

enum CardViewType {
  case appOfTheDay(bgImage: UIImage, bgType: BackgroundType?, app: AppViewModel)
  case appCollection(apps: [AppViewModel], title: String, subtitle: String)
  case appArticle(bgImage: UIImage, bgType: BackgroundType?, title: String, subtitle: String, description: String, app: AppViewModel)
  
  var backgroundImage: UIImage? {
    switch self {
    case .appOfTheDay(let bgImage, _, _), .appArticle(let bgImage, _, _, _, _, _):
      return bgImage
    default:
      return nil
    }
  }
}

class CardViewModel {
  
  var viewMode: CardViewMode = .card
  let viewType: CardViewType
  var title: String? = nil
  var subtitle: String? = nil
  var description: String? = nil
  var app: AppViewModel? = nil
  var appCollection: [AppViewModel]? = nil
  var backgroundImage: UIImage? = nil
  var backgroundType: BackgroundType = .light
  
  init(viewType: CardViewType) {
    self.viewType = viewType
    switch viewType {
    case .appArticle(let bgImage, let bgType, let title, let subtitle, let description, let app):
      self.backgroundImage = bgImage.imageWith(newSize: CGSize(width: 375, height: 450))
      self.title = title
      self.subtitle = subtitle
      self.description = description
      self.app = app
      self.backgroundType = bgType ?? .light
    case .appOfTheDay(let bgImage, let bgType, let app):
      self.backgroundImage = bgImage.imageWith(newSize: CGSize(width: 375, height: 450))
      self.app = app
      self.backgroundType = bgType ?? .light
    case .appCollection(let apps, let title, let subtitle):
      self.appCollection = apps
      self.title = title
      self.subtitle = subtitle
    }
  }
}

