//
//  TableViewCell_Album.swift
//  test2
//
//  Created by huy on 5/22/23.
//

import UIKit

class TableViewCell_Album: UITableViewCell {

    @IBOutlet weak var imge: UIImageView!
    
    @IBOutlet weak var NameLabel: UILabel!
    
    @IBOutlet weak var quantity_Label: UILabel!
    
    @IBOutlet weak var Rename_Delete: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
