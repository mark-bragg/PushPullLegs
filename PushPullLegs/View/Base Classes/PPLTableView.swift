//
//  PPLTableView.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 7/17/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation
import UIKit

// TODO: continue layer/shadow stuff maybe move cell shadow to uiview extension or to the ppltableviewcell class

class PPLTableView: UITableView {
    
    override func dequeueReusableCell(withIdentifier identifier: String) -> UITableViewCell? {
        guard let cell = super.dequeueReusableCell(withIdentifier: identifier) as? PPLTableViewCell else { return nil }
        cell.backgroundColor = .clear
        cell.focusStyle = .custom
        cell.contentView.clipsToBounds = false
        return cell
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .clear
        backgroundColor = PPLColor.Grey
        separatorStyle = .none
    }
    
}
