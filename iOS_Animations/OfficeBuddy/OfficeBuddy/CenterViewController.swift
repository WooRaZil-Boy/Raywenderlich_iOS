//
//  CenterViewController.swift
//  OfficeBuddy
//
//  Created by 근성가이 on 2017. 1. 19..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit

class CenterViewController: UIViewController {
    
    var menuItem: MenuItem! {
        didSet {
            title = menuItem.title
            view.backgroundColor = menuItem.color
            symbol.text = menuItem.symbol
        }
    }
    
    @IBOutlet var symbol: UILabel!
    
    // MARK: ViewController
    
    var menuButton: MenuButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuButton = MenuButton()
        menuButton.tapHandler = {
            if let containerVC = self.navigationController?.parent as? ContainerViewController {
                containerVC.toggleSideMenu()
            }
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
        menuItem = MenuItem.sharedItems.first!
    }
    
}
