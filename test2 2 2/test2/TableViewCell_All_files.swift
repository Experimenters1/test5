//
//  TableViewCell_All_files.swift
//  test2
//
//  Created by huy on 5/25/23.
//

import UIKit

class TableViewCell_All_files: UITableViewCell {

    @IBOutlet weak var videoImageView: UIImageView!
    
    @IBOutlet weak var videoNameLabel: UILabel!
    
    @IBOutlet weak var videoTimeLabel: UILabel!
    
    @IBOutlet weak var checkbox: UIButton!
    
        
    var checkboxAction: ((Bool) -> Void)?
 

        override func awakeFromNib() {
            super.awakeFromNib()
            // Initialization code
            
            checkbox.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
            
        }

        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
            // Configure the view for the selected state
        }
    
    @objc private func checkboxTapped() {
        checkboxAction?(checkbox.isSelected)
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
