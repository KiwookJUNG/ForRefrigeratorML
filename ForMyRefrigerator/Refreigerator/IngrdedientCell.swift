//
//  IngrdedientCell.swift
//  ForMyRefrigerator
//
//  Created by 정기욱 on 09/05/2019.
//  Copyright © 2019 Nudge. All rights reserved.
//

import UIKit

class IngredientCell: UITableViewCell {
    
    
    @IBOutlet weak var ingrdient: UILabel!
    
    @IBOutlet weak var want: UISwitch!
    
    var toggleHandler: ((UISwitch) -> Void)?
    
    @IBAction func toggleSwitch(_ sender: UISwitch) {
        toggleHandler?(sender)
    }
    
}
