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

struct RobinhoodDataModel {
  var cards: [RobinhoodCardViewModel] = []
  
  init(jsonContent: [[String: String]]) {
    self.cards = jsonContent.compactMap({ (cardModelJSON) -> RobinhoodCardViewModel? in
      guard let title = cardModelJSON["title"],
        let text = cardModelJSON["text"],
        let link = cardModelJSON["link"] else { return nil }
      
      return RobinhoodCardViewModel(title: title, text: text, link: link)
    })
  }
}

class RobinhoodData {
  static let jsonURL = Bundle.main.url(forResource: "RobinhoodData", withExtension: "json")!
  
  static var data: RobinhoodDataModel {
    do {
      let cardsData = try Data(contentsOf: jsonURL)
      
      if let cardsContent = try JSONSerialization.jsonObject(with: cardsData, options: JSONSerialization.ReadingOptions()) as? [[String: String]] {
        
        return RobinhoodDataModel(jsonContent: cardsContent)
        
      } else {
        return RobinhoodDataModel(jsonContent: [])
      }
    }
      
    catch {
      return RobinhoodDataModel(jsonContent: [])
    }
  }
}

struct RobinhoodChartData {
  let openingPrice: Double
  let data: [(date: Date, price: Double)]
  
  static var portfolioData: RobinhoodChartData {
    var chartData: [(date: Date, price: Double)] = []
    
    var dateComponents = DateComponents()
    dateComponents.year = 2018
    dateComponents.month = 5
    dateComponents.day = 4
    dateComponents.minute = 0
    
    let calendar = Calendar.current
    var startDateComponents = dateComponents
    startDateComponents.hour = 9
    let startDate = calendar.date(from: startDateComponents)
    
    var endDateComponents = dateComponents
    endDateComponents.hour = 16
    let endDate = calendar.date(from: endDateComponents)
    
    var dateInterval = DateInterval(start: startDate!, end: endDate!)
    
    let secondsInMinute = 60
    let timeIntervalIncrement = 5 * secondsInMinute
    let duration = Int(dateInterval.duration)
    
    let startPrice: Double = 240.78
    
    for i in stride(from: 0, to: duration, by: timeIntervalIncrement) {
      let date = startDate!.addingTimeInterval(TimeInterval(i))
      var randomPriceMovement = Double(arc4random_uniform(100))/50
      let upOrDown = arc4random_uniform(2)
      
      if upOrDown == 0 { randomPriceMovement = -randomPriceMovement }
      let chartDataPoint = (date: date, price: startPrice + randomPriceMovement)
      chartData.append(chartDataPoint)
    }

    let portfolioData = RobinhoodChartData(openingPrice: startPrice, data: chartData)
    
    return portfolioData
  }
}
