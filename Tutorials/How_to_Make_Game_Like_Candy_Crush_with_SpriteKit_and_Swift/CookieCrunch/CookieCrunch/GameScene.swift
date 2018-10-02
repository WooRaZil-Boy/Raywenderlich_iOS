/**
 * GameScene.swift
 * CookieCrunch
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

import SpriteKit
import GameplayKit

class GameScene: SKScene {
  // Sound FX
  let swapSound = SKAction.playSoundFileNamed("Chomp.wav", waitForCompletion: false)
  let invalidSwapSound = SKAction.playSoundFileNamed("Error.wav", waitForCompletion: false)
  let matchSound = SKAction.playSoundFileNamed("Ka-Ching.wav", waitForCompletion: false)
  let fallingCookieSound = SKAction.playSoundFileNamed("Scrape.wav", waitForCompletion: false)
  let addCookieSound = SKAction.playSoundFileNamed("Drip.wav", waitForCompletion: false)
  //게임에서 사용할 사운드를 로드하고 필요에 따라 사용할 수 있다.
  
  var level: Level!
  
  let tileWidth: CGFloat = 32.0 //격자 하나의 너비
  let tileHeight: CGFloat = 36.0 //격자 하나의 폭
  
  let gameLayer = SKNode() //기본 레이어. 다른 모든 레이어의 컨테이너이며 화면 중앙에 배치된다.
  let cookiesLayer = SKNode() //쿠키 스프라이트를 추가할 레이어
  
  let tilesLayer = SKNode()
  let cropLayer = SKCropNode() //CropNode는 마스크에 픽셀이 포함되어 있는 경우에만 child를 그린다.
  //이렇게 하면, 배경에 타일이 있는 곳에서만 쿠키를 그린다.
  let maskLayer = SKNode()
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder) is not used in this app")
  }
  
  override init(size: CGSize) {
    super.init(size: size)
    
    anchorPoint = CGPoint(x: 0.5, y: 0.5) //배경 이미지는 항상 화면 가운데에 배치된다.
    
    let background = SKSpriteNode(imageNamed: "Background") //배경을 가져온다.
    background.size = size
    addChild(background)
    
    addChild(gameLayer) //빈 SKNode 추가. 다른 노드를 추가할 수 있는 투명한 평면으로 생각할 수 있다.
    
    let layerPosition = CGPoint(
      x: -tileWidth * CGFloat(numColumns) / 2,
      y: -tileHeight * CGFloat(numRows) / 2)
    
    tilesLayer.position = layerPosition
    maskLayer.position = layerPosition
    cropLayer.maskNode = maskLayer
    gameLayer.addChild (tilesLayer)
    gameLayer.addChild (cropLayer)
    //순서대로 추가해 줘야 한다.
    
    cookiesLayer.position = layerPosition
//    gameLayer.addChild(cookiesLayer) //빈 SKNode 추가. 다른 노드를 추가할 수 있는 투명한 평면으로 생각할 수 있다.
    cropLayer.addChild(cookiesLayer)
  }
}




extension GameScene {
  func addSprites(for cookies: Set<Cookie>) {
    //anchorPoint를 (0.5, 0.5)로 설정했기에, child를 추가하면 시작점 (0, 0)이 자동으로 중앙에 위치하게 된다.
    //하지만 여기서 (0, 0)은 좌측 하단이 되어야 하므로 레이어를 이동해야 한다.
    for cookie in cookies { //반복하면서 SKSpriteNode 객체를 cookiesLayer에 추가한다.
      let sprite = SKSpriteNode(imageNamed: cookie.cookieType.spriteName)
      sprite.size = CGSize(width: tileWidth, height: tileHeight)
      sprite.position = pointFor(column: cookie.column, row: cookie.row)
      cookiesLayer.addChild(sprite)
      cookie.sprite = sprite
    }
  }
  
  private func pointFor(column: Int, row: Int) -> CGPoint { //열과 행 번호로 객체가 위치할 CGPoint 반환
    return CGPoint(
      x: CGFloat(column) * tileWidth + tileWidth / 2,
      y: CGFloat(row) * tileHeight + tileHeight / 2)
  }
}




//Making the Tiles Visible
//쿠키 스프라이트 배경을 더 돋보이게 쿠키 뒤에 약간 더 어두운 타일 스프라이트를 그려준다.
extension GameScene {
  func addTiles() {
    for row in 0..<numRows { //행
      for column in 0..<numColumns { //열
        if level.tileAt(column: column, row: row) != nil { //타일이 있는 곳이라면(0이 아니라면, 1이라면)
          let tileNode = SKSpriteNode(imageNamed: "MaskTile") //MaskTile 스프라이트를 불러와서
          tileNode.size = CGSize(width: tileWidth, height: tileHeight) //사이즈 지정
          tileNode.position = pointFor(column: column, row: row) //위치 지정
          maskLayer.addChild(tileNode) //추가해서 MaskTile이 보이게 한다.
        }
      }
    }
    
    for row in 0...numRows { //행
      for column in 0...numColumns { //열
        //각 모서리 부분은 모든 면에 MaskTile이 필요하지 않다. 경계면을 매끄럽게 해 준다.
        let topLeft     = (column > 0) && (row < numRows)
          && level.tileAt(column: column - 1, row: row) != nil
        let bottomLeft  = (column > 0) && (row > 0)
          && level.tileAt(column: column - 1, row: row - 1) != nil
        let topRight    = (column < numColumns) && (row < numRows)
          && level.tileAt(column: column, row: row) != nil
        let bottomRight = (column < numColumns) && (row > 0)
          && level.tileAt(column: column, row: row - 1) != nil
        
        var value = topLeft.hashValue
        value = value | topRight.hashValue << 1
        value = value | bottomLeft.hashValue << 2
        value = value | bottomRight.hashValue << 3
        
        // Values 0 (no tiles), 6 and 9 (two opposite tiles) are not drawn.
        if value != 0 && value != 6 && value != 9 {
          let name = String(format: "Tile_%ld", value)
          let tileNode = SKSpriteNode(imageNamed: name)
          tileNode.size = CGSize(width: tileWidth, height: tileHeight)
          var point = pointFor(column: column, row: row)
          point.x -= tileWidth / 2
          point.y -= tileHeight / 2
          tileNode.position = point
          tilesLayer.addChild(tileNode)
        }
      }
    }
  }
}




