//
//  StyleGuideViewableViewController.swift
//  SpacetimeUI
//
//  Created by Ellen Shapiro on 2/4/18.
//  Copyright © 2018 RayWenderlich.com. All rights reserved.
//

import UIKit
import SpacetimeUI

public class StyleGuideViewableViewController: UITableViewController {
  
  private let cellIdentifier = "StyleCell"
  private let styles: [StyleGuideViewable]
  
  public init(styles: [StyleGuideViewable], title: String) {
    self.styles = styles
    super.init(nibName: nil, bundle: nil)
    self.title = title
    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override public func numberOfSections(in tableView: UITableView) -> Int {
    return self.styles.count
  }
  
  override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  override public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    let style = self.styles[section]
    return style.itemName
  }
  
  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
    
    let style = self.styles[indexPath.section]
    
    // TODO: Show Style
    cell.replaceContentViewSubviewsWith(style.view)
    
    return cell
  }
}

//StyleGuideViewable 객체 배열을 가져와 UITableView에 표시한다.

