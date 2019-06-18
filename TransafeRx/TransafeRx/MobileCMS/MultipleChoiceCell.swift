//
//  MultipleChoiceCell.swift
//  eHEARTT
//
//  Created by Tachl on 11/7/16.
//  Copyright © 2016 Tachl. All rights reserved.
//

import Foundation
import UIKit

class MultipleChoiceCell: UITableViewCell {
    
    @IBOutlet weak var choiceLabel: UILabel!
    @IBOutlet weak var choiceImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
