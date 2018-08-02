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

class CustomData {
  static let shared = CustomData()
  
  let jsonContent: [String: AnyObject]
  
  var cardTiles: [CardViewModel] {
    let parseOne = parseCards(for: jsonContent)
    let parseTwo = parseCards(for: jsonContent)
    var totalParse = parseCards(for: jsonContent)
    totalParse.append(contentsOf: parseOne)
    totalParse.append(contentsOf: parseTwo)
    return totalParse
  }
  
  init() {
    guard let cardsURL = Bundle.main.url(forResource: "CardTilesData", withExtension: "json") else {
      jsonContent = [:]
      return
    }
    do {
      let cardsData = try Data(contentsOf: cardsURL)
      
      if let cardsContent = try JSONSerialization.jsonObject(with: cardsData, options: JSONSerialization.ReadingOptions()) as? [String: AnyObject] {
        
        jsonContent = cardsContent
        
      } else {
        jsonContent = [:]
        print("Error parsing CardTilesData.json data.")
      }
    }
      
    catch {
      jsonContent = [:]
      print("Error parsing .json data.")
    }
  }
  
  func parseApp(for JSON: [String: String], viewType: AppViewType) -> AppViewModel? {
    guard let name = JSON["name"],
      let tagline = JSON["tagline"],
      let categoryString = JSON["category"],
      let cost = JSON["cost"],
      let iconName = JSON["iconName"],
      let image = UIImage(named: iconName),
      let hasInAppPurchase = JSON["hasInAppPurchase"]?.boolValue(),
      let alreadyPurchased = JSON["alreadyPurchased"]?.boolValue(),
      let onDevice = JSON["onDevice"]?.boolValue() else
    { return nil }
    
    return AppViewModel(name: name, tagline: tagline, category: categoryString, cost: Cost.cost(fromString: cost), hasInAppPurchase: hasInAppPurchase, alreadyPurchased: alreadyPurchased, isOnDevice: onDevice, iconImage: image, appViewType: viewType)
  }
  
  func parseCards(for JSON: [String: AnyObject]) -> [CardViewModel] {
    guard let cardsData = JSON["cardTiles"] as? [[String: AnyObject]] else { return [] }
    
    let cards = cardsData.compactMap({ (cardsDictionary) -> CardViewModel? in
      guard let cardTypeString = cardsDictionary["type"] as? String else { return nil }
      
      let bgImageString = cardsDictionary["backgroundImage"] as? String
      let bgTypeString = cardsDictionary["backgroundType"] as? String
      let bgType = BackgroundType(rawValue: bgTypeString ?? "")
      let title = cardsDictionary["title"] as? String
      let subtitle = cardsDictionary["subtitle"] as? String
      let description = cardsDictionary["description"] as? String
      let apps = cardsDictionary["apps"] as? [[String: String]]
      
      switch cardTypeString {
      case "appOfTheDay":
        guard let bgImage = UIImage(named: bgImageString ?? "rwdevcon-bg"),
          let app = apps?.first,
          let appViewModel = parseApp(for: app, viewType: AppViewType.featured) else { break }
        
        let cardType = CardViewType.appOfTheDay(bgImage: bgImage, bgType: bgType, app: appViewModel)
        return CardViewModel(viewType: cardType)
        
      case "appCollection":
        guard let title = title,
          let subtitle = subtitle,
          let apps = apps else { break }
        
        let appViewModels = apps.compactMap { parseApp(for: $0, viewType: AppViewType.horizontal) }
        let cardType = CardViewType.appCollection(apps: appViewModels, title: title, subtitle: subtitle)
        return CardViewModel(viewType: cardType)
        
      case "appArticle":
        guard let bgImage = UIImage(named: bgImageString ?? "rwdevcon-bg"),
          let title = title,
          let subtitle = subtitle,
          let app = apps?.first,
          let appViewModel = parseApp(for: app, viewType: AppViewType.none),
          let description = description else { break }
        
        let cardType = CardViewType.appArticle(bgImage: bgImage, bgType: bgType, title: title, subtitle: subtitle, description: description, app: appViewModel)
        return CardViewModel(viewType: cardType)
      default:
        return nil
      }
      
      return nil
    })
    return cards
  }
}

