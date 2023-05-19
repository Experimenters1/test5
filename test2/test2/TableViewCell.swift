//
//  TableViewCell.swift
//  test2
//
//  Created by huy on 12/05/2023.
//

import UIKit
import AVFoundation

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

    
    func setVideoImage(fromURL url: URL) {
            DispatchQueue.global().async {
                if let thumbnail = self.generateThumbnail(path: url) {
                    DispatchQueue.main.async {
                        self.videoImageView.image = thumbnail
                    }
                }
            }
        }
    

        func setVideoName(name: String?) {
            videoNameLabel.text = name
        }
    
    func setVideoTime(timeInterval: TimeInterval) {
           let formattedDuration = formattedDurationString(from: timeInterval)
           videoTimeLabel.text = formattedDuration
       }

    

    
    private func generateThumbnail(path: URL) -> UIImage? {
           let asset = AVAsset(url: path)
           let imageGenerator = AVAssetImageGenerator(asset: asset)
           do {
               let cgImage = try imageGenerator.copyCGImage(at: CMTime(seconds: 1, preferredTimescale: 1), actualTime: nil)
               let thumbnail = UIImage(cgImage: cgImage)
               return thumbnail
           } catch {
               print(error.localizedDescription)
               return nil
           }
       }
    
    private func formattedDurationString(from timeInterval: TimeInterval) -> String {
           let minutes = Int(timeInterval / 60)
           let seconds = Int(timeInterval) % 60
           
           return String(format: "%02d:%02d", minutes, seconds)
       }
}
