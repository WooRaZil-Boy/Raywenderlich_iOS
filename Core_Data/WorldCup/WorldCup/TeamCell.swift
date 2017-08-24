//
//  TeamCell.swift
//  WorldCup
//
//  Created by 근성가이 on 2017. 1. 2..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit

class TeamCell: UITableViewCell {
    //MARK: - IBOutlets
    @IBOutlet weak var teamLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!
    
    //MARK: - View Life Cycle    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        teamLabel.text = nil
        scoreLabel.text = nil
        flagImageView.image = nil
    }
}
