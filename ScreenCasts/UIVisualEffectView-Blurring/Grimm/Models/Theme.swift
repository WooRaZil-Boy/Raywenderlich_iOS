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

import UIKit

enum Font: Int {
  case firaSans, notoSans, openSans, pztSans, sourceSansPro, system
}

enum ReadingMode: Int {
  case dayTime, nightTime
}

enum TitleAlignment: Int {
  case center, left
}

let ThemeDidChangeNotification = Notification.Name("ThemeDidChangeNotification")

protocol ThemeAdopting {
  func reloadTheme()
}

class Theme {
  
  static var shared = Theme()
  
  private let fonts = [
    ["FiraSans-Regular",
     "NotoSans",
     "OpenSans",
     "PTSans-Regular",
     "SourceSansPro-Regular"],
    ["FiraSans-SemiBold",
     "NotoSans-Bold",
     "OpenSans-Semibold",
     "PTSans-Bold",
     "SourceSansPro-Semibold"]
  ]
  
  private let textBackgroundColors = [UIColor.white, UIColor.nightTimeTextBackground]
  private let textColors = [UIColor.darkText, UIColor.nightTimeText]
  
  var font: Font = .firaSans {
    didSet{
      notifyObservers()
    }
  }
  
  var readingMode: ReadingMode = .dayTime {
    didSet {
      notifyObservers()
    }
  }
  var titleAlignment: TitleAlignment = .center {
    didSet {
      notifyObservers()
    }
  }
  
  var barTintColor: UIColor {
    let color = textBackgroundColors[readingMode.rawValue]
    return color.colorForTranslucency()
  }
  
  var tintColor: UIColor? {
    return readingMode == .dayTime ? nil : UIColor.nightTimeTint
  }
  
  var separatorColor: UIColor {
    return readingMode == .dayTime ? UIColor.defaultSeparator : UIColor.nightTimeTint
  }
  
  var textBackgroundColor: UIColor {
    return textBackgroundColors[readingMode.rawValue]
  }
  
  var textColor: UIColor {
    return textColors[readingMode.rawValue]
  }

  func preferredFont(forTextStyle style: UIFont.TextStyle) -> UIFont {
    let systemFont = UIFont.preferredFont(forTextStyle: style)
    
    if font == .system {
      return systemFont
    }
    
    let size = systemFont.pointSize
    var preferredFont: UIFont
    
    if style == .headline {
      preferredFont = UIFont(name: fonts[1][font.rawValue], size: size)!
    } else {
      preferredFont = UIFont(name: fonts[0][font.rawValue], size: size)!
    }
    
    return preferredFont
  }
  
  private func notifyObservers() {
    NotificationCenter.default.post(name: ThemeDidChangeNotification, object: nil)
  }
  
}
