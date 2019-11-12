//
//  LigandTableViewCell.swift
//  Swifty Proteins
//
//  Created by Kondelelani NEDZINGAHE on 2019/10/26.
//  Copyright © 2019 Kondelelani NEDZINGAHE. All rights reserved.
//

import UIKit

class LigandTableViewCell: UITableViewCell {

    @IBOutlet weak var ligandName: UILabel!
    
    var name: String!{
        didSet{
            ligandName.text = name;
        }
    }
}
