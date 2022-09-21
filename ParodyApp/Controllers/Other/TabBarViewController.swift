//
//  TabBarViewController.swift
//  ParodyApp
//
//  Created by Dawson Chen on 6/21/22.
//

import Foundation
import UIKit

class TabBarViewController: UITabBarController {
    override func viewDidLoad() {
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
}

