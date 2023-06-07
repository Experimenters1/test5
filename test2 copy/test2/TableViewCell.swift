//
//  TableViewCell.swift
//  test2
//
//  Created by huy on 12/05/2023.
//

import UIKit

class TableViewCell: UITableViewCell {


    static let heigh_cell: CGFloat = 96
   
    @IBOutlet weak var videoImageView: UIImageView!
    
    @IBOutlet weak var videoNameLabel: UILabel!
    
    
    @IBOutlet weak var videoTimeLabel: UILabel!
    

    @IBOutlet weak var Rename_Delete: UIButton!
    

    
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
