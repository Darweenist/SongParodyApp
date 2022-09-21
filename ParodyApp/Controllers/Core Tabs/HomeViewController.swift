//
//  FeedViewController.swift
//  ParodyApp
//
//  Created by Dawson Chen on 6/13/22.
//

import Foundation
import UIKit

class HomeViewController: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        print("on home screen")
    }
}
