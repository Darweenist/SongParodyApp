//
//  LyricCell.swift
//  ParodyApp
//
//  Created by Dawson Chen on 6/17/22.
//

import UIKit

class LyricCell: UITableViewCell {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var label: UILabel!
    
    var delegate: ComposeViewController?
    var numLine: Int? = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func didEndEditingTextField(_ sender: UITextField) {
        delegate?.parody?.lines[numLine ?? 0] = sender.text!
    }
    
    
}
