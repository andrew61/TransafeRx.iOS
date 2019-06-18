//
//  CustomTabBarCell.swift
//  eHEARTT
//
//  Created by Tachl on 12/15/16.
//  Copyright © 2016 Tachl. All rights reserved.
//

import Foundation

class CustomTabBarCell: UICollectionViewCell{
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tabImage: UIImageView!
    @IBOutlet weak var tabView: UIView!
    @IBOutlet weak var selectedView: UIView!
    
    var title: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.autoresizesSubviews = true
    }
    
    func selected(){
        selectedView.backgroundColor = UIColor.orange
    }

}
