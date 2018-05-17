/*
 * Copyright (c) 2018 Razeware LLC
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
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

struct GlobalConstants {
  struct Sizes {
    struct Margin {
      let horizontal = 60
      let vertical = 40
      
      var dictionary: [String : Any] {
        return [
          "horizontal" : horizontal,
          "vertical" : vertical
        ]
      }
    }
    struct Spacing {
      let horizontal = 20
      let vertical = 20
      
      var dictionary: [String : Any] {
        return [
          "horizontal": horizontal,
          "vertical": vertical
        ]
      }
    }
    
    let margin = Margin()
    let spacing = Spacing()
    let collectionTileWidth = 300
    let videoTileWidth = 240
    let progressBarHeight = 8
    
    var dictionary: [String : Any] {
      return [
        "margin" : margin,
        "spacing" : spacing,
        "collectionTileWidth" : collectionTileWidth,
        "videoTileWidth": videoTileWidth,
        "progressBarHeight": progressBarHeight
      ]
    }
  }
  
  let sizes = Sizes()
  
  var dictionary: [String : Any] {
    return [
      "sizes" : sizes
    ]
  }
}

let GLOBAL_CONSTANTS = GlobalConstants()
