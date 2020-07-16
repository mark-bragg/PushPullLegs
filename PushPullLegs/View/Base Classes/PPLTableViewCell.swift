//
//  PPLTableViewCell.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 7/12/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

class PPLTableViewCell: UITableViewCell {

    @IBOutlet weak var greenBackground: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        greenBackground.layer.borderWidth = 4
        greenBackground.layer.borderColor = UIColor.white.cgColor
        greenBackground.layer.cornerRadius = greenBackground.frame.height/2
        greenBackground.layer.shadowPath = UIBezierPath.init(roundedRect: greenBackground.bounds, cornerRadius: greenBackground.bounds.height / 2).cgPath
        greenBackground.layer.shadowColor = PPLColor.darkGrey?.cgColor
        greenBackground.layer.shadowOpacity = 0.6
        greenBackground.layer.shadowOffset = .zero
        greenBackground.layer.shadowRadius = 2
        greenBackground.layer.shouldRasterize = true
        greenBackground.layer.rasterizationScale = UIScreen.main.scale
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
