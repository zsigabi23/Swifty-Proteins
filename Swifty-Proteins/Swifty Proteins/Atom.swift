//
//  Atom.swift
//  Swifty Proteins
//
//  Created by Kondelelani NEDZINGAHE on 2019/10/29.
//  Copyright © 2019 Kondelelani NEDZINGAHE. All rights reserved.
//

import UIKit

class Atom: NSObject {
    
    var id: String = "";
    var symbol: String = "";
    var x: Float = 0.0;
    var y: Float = 0.0;
    var z: Float = 0.0;
    var color: UIColor = UIColor.black;
    
    init(id: String, symbol: String, x: Float, y: Float, z: Float){
        super.init();
        
        self.id = id;
        self.symbol = symbol;
        self.x = x;
        self.y = y;
        self.z = z;
        
        setColor();
    }
    
    func setColor(){
      switch(symbol.lowercased()){
      case "h":
          color = UIColor.white;
      case "c":
          color = UIColor.gray;
      case "n":
          color = UIColor.blue;
      case "o":
          color = UIColor.red;
      case "f":
          color = UIColor.green;
      case "ci":
          color = UIColor.green;
      case "br":
          color = UIColor.brown;
      case "i":
          color = UIColor.blue;
      default:
          color = UIColor.black;
      }
    }
}
