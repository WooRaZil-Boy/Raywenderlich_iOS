//
//  ViewController.swift
//  StyleGuide
//
//  Created by Ellen Shapiro on 2/4/18.
//  Copyright © 2018 RayWenderlich.com. All rights reserved.
//

import UIKit
import SpacetimeUI

class ViewController: UITableViewController {
    
    private lazy var styles: [[StyleGuideViewable]] = {
        return [
            // TODO: Add styles
            SpacetimeColor.allCases,
            SpacetimeFont.allCases,
            SpacetimeFontSize.allCases,
            SpacetimeLabelStyle.allCases,
            SpacetimeButtonStyle.allCases,
            //RawRepresentable
        ]
    }() //StyleGuideViewable을 각각 적용하기 위한 배열
    
    private let reuseIdentifier = "StyleTypeCell"
    
    private func styleName(at index: Int) -> String {
        let casesAtIndex = self.styles[index]
        return type(of: casesAtIndex.first!).styleName
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.styles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath)
        
        cell.textLabel?.text = styleName(at: indexPath.row)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let casesForStyle = self.styles[indexPath.row]
        let viewController = StyleGuideViewableViewController(styles: casesForStyle, title: styleName(at: indexPath.row))
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
