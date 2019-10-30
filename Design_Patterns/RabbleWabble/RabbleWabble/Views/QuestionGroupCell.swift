//
//  QuestionGroupCell.swift
//  RabbleWabble
//
//  Created by 근성가이 on 2019/10/25.
//  Copyright © 2019 근성가이. All rights reserved.
//

import UIKit
import Combine

public class QuestionGroupCell: UITableViewCell {
    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var percentageLabel: UILabel!
    
    public var percentageSubscriber: AnyCancellable? //Observer Pattern
}

//subscriber 객체는 Life cycle과 관련이 되어 있으므로,
//이 앱에서는 QuestionGroupCell에 작성하는 것이 타당하다.
