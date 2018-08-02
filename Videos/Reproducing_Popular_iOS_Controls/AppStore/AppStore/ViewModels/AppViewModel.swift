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

enum AppAccess: CustomStringConvertible {
  case onCloud
  case onDevice
  case onStore(cost: Cost)
  
  var description: String {
    switch self {
    case .onCloud:
      return "☁️"
    case .onDevice:
      return "OPEN"
    case .onStore(let cost):
      return cost.description
    }
  }
}

enum Cost: CustomStringConvertible {
  case free
  case paid(cost: Float)
  
  var description: String {
    switch self {
    case .free:
      return "GET"
    case .paid(let cost):
      return "$\(cost)"
    }
  }
  
  static func cost(fromString string: String) -> Cost {
    if string.lowercased() == "free" {
      return .free
    }
    
    if let dollarSignIndex = string.index(of: "$") {
      var floatString = string
      floatString.remove(at: dollarSignIndex)
      let float = Float(floatString)
      return .paid(cost: float ?? 0.0)
    }
    
    return .paid(cost: 0.0)
  }
}

enum AppViewType {
  case horizontal
  case featured
  case none
  
  var imageSize: CGFloat {
    switch self {
    case .featured:
      return 90
    case .horizontal:
      return 50
    case .none:
      return 0
    }
  }
  
  var cornerRadius: CGFloat {
    return imageSize/5
  }
}

class AppViewModel {
  let iconImage: UIImage
  let name: String
  let tagline: String
  let category: String
  let cost: Cost
  let hasInAppPurchase: Bool
  let alreadyPurchased: Bool
  let isOnDevice: Bool
  let appAccess: AppAccess
  let appViewType: AppViewType
  
  init(name: String, tagline: String, category: String, cost: Cost, hasInAppPurchase: Bool, alreadyPurchased: Bool, isOnDevice: Bool, iconImage: UIImage, appViewType: AppViewType) {
    self.iconImage = iconImage
    self.name = name
    self.tagline = tagline
    self.category = category
    self.cost = cost
    self.hasInAppPurchase = hasInAppPurchase
    self.alreadyPurchased = alreadyPurchased
    self.isOnDevice = isOnDevice
    self.appAccess = alreadyPurchased ? ( isOnDevice ? .onDevice : .onCloud) : .onStore(cost: cost)
    self.appViewType = appViewType
  }
}



