//
//  Link.swift
//  Swifty Proteins
//
//  Created by Kondelelani NEDZINGAHE on 2019/10/29.
//  Copyright © 2019 Kondelelani NEDZINGAHE. All rights reserved.
//

import UIKit

class Link: NSObject {
    
    var from: String = "";
    var to: String = "";
    
    init(from: String, to: String){
        self.from = from;
        self.to = to;
    }
}

func ==(lhs: Link, rhs: Link) -> Bool{
    return (lhs.from == rhs.from && lhs.to == rhs.to) || (lhs.from == rhs.to && lhs.to == rhs.from);
}
