//
//  PPLTableView.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 7/17/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation
import UIKit

class PPLTableView: UITableView {
    
    override func dequeueReusableCell(withIdentifier identifier: String) -> UITableViewCell? {
        if super.dequeueReusableCell(withIdentifier: identifier) == nil {
            register(PPLTableViewCell.nib(), forCellReuseIdentifier: PPLTableViewCellIdentifier)
        }
        let cell = super.dequeueReusableCell(withIdentifier: PPLTableViewCellIdentifier)!
        cell.backgroundColor = .clear
        cell.focusStyle = .custom
        cell.contentView.clipsToBounds = false
        return cell
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .clear
        separatorStyle = .none
    }
    
}
