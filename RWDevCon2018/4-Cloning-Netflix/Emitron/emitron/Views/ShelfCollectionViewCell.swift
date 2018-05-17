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

class ShelfCollectionViewCell: UICollectionViewCell {
  weak var delegate: ShelfSelectionDelegate?
  @IBOutlet weak var shelfTitleLabel: UILabel!
  
  var data: ShelfViewModel? {
    didSet {
      self.updateAppearance()
    }
  }
  
  @IBOutlet weak var collectionView: UICollectionView! {
    didSet {
      collectionView?.registerLayout(named: "CardCollectionViewCell.xml",
                                     state: EmptyCardState,
                                     constants: ["imageHeight": Double(GLOBAL_CONSTANTS.sizes.videoTileWidth) / 4 * 3],
                                     forCellReuseIdentifier: "CardCell")
      collectionView.dataSource = self
      collectionView.delegate = self
    }
  }
  
  func updateAppearance() {
    collectionView?.reloadData()
  }
}

extension ShelfCollectionViewCell: UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return data?.cards.count ?? 0
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let node = collectionView.dequeueReusableCellNode(withIdentifier: "CardCell", for: indexPath)
    if let cell = node.view as? CardCollectionViewCell {
      cell.data = data?.cards[indexPath.item]
    }
    return node.view as! UICollectionViewCell
  }
}

extension ShelfCollectionViewCell: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if let cardViewModel = data?.cards[indexPath.item] {
      delegate?.didSelect(cardViewModel: cardViewModel)
    }
  }
}
