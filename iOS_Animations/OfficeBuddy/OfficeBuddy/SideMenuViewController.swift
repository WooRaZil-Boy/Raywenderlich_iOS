//
//  SideMenuViewController.swift
//  OfficeBuddy
//
//  Created by 근성가이 on 2017. 1. 19..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit

class SideMenuViewController: UITableViewController {
    
    var centerViewController: CenterViewController!
    
    // MARK: UITableViewDataSource
    
    override func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        return MenuItem.sharedItems.count
    }
    
    override func tableView(_ tableView:UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for:indexPath) as UITableViewCell
        
        let menuItem = MenuItem.sharedItems[(indexPath as NSIndexPath).row]
        cell.textLabel?.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = UIFont(name: "Helvetica", size: 36.0)
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.text = menuItem.symbol
        
        cell.contentView.backgroundColor = menuItem.color
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView  {
        return tableView.dequeueReusableCell(withIdentifier: "HeaderCell")!
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView:UITableView, didSelectRowAt indexPath:IndexPath) {
        tableView.deselectRow(at: indexPath, animated:true)
        
        centerViewController.menuItem = MenuItem.sharedItems[(indexPath as NSIndexPath).row]
        
        let containerVC = parent as! ContainerViewController
        containerVC.toggleSideMenu()
    }
    
    override func tableView(_ tableView:UITableView, heightForRowAt indexPath:IndexPath) -> CGFloat {
        return 84.0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 64.0
    }
}
