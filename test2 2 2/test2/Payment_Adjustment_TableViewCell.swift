//
//  Payment_Adjustment_TableViewCell.swift
//  test2
//
//  Created by huy on 5/26/23.
//

import UIKit

class Payment_Adjustment_TableViewCell: UITableViewCell {

    @IBOutlet weak var videoImageView: UIImageView!
    
    @IBOutlet weak var videoNameLabel: UILabel!
    
    @IBOutlet weak var videoTimeLabel: UILabel!
    
    @IBOutlet weak var Delete: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setVideoName(name: String?) {
        videoNameLabel.text = name
    }

func setVideoTime(timeInterval: TimeInterval) {
       let formattedDuration = formattedDurationString(from: timeInterval)
       videoTimeLabel.text = formattedDuration
   }



private func formattedDurationString(from timeInterval: TimeInterval) -> String {
       let minutes = Int(timeInterval / 60)
       let seconds = Int(timeInterval) % 60
       
       return String(format: "%02d:%02d", minutes, seconds)
   }
    
}
