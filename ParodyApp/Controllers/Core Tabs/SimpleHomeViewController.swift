//
//  SimpleHomeViewController.swift
//  ParodyApp
//
//  Created by Dawson Chen on 7/28/22.
//

import UIKit

class SimpleHomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func parodyExists() -> Bool {
        return false
    }

    @IBAction func newParodyPressed(_ sender: UIButton) {
        if !parodyExists() {
            performSegue(withIdentifier: K.Segues.simpleHomeToCompose, sender: self)
        } 
    }
    
}
