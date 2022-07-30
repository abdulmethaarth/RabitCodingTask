//
//  TableViewCell.swift
//  Employee Directory
//
//  Created by Admin on 30/07/22.
//

import UIKit

class DashBoardListTableViewCell: UITableViewCell {

    @IBOutlet weak var empName: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var empProfileImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
