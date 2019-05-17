//
//  ProfileViewController.swift
//  ForMyRefrigerator
//
//  Created by 정기욱 on 10/05/2019.
//  Copyright © 2019 Nudge. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        
        // 네비게이션 타이틀의 색을 바꿔줌
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        // 네비게이션 바의 배경을 바꿔줌.
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.14, green:0.35, blue:0.91, alpha:1.0)
    }
    
}
