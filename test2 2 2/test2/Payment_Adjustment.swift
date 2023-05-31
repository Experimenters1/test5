//
//  Payment_Adjustment.swift
//  test2
//
//  Created by huy on 5/25/23.
//

import UIKit

var fileTab4: Payment_Adjustment?

class Payment_Adjustment: UIViewController {

    @IBOutlet weak var tableViewLs: UITableView!
    
    var albumsDictionary: [String: [String]] = [:]
    let userDefaults = UserDefaults.standard
    var filesVC2: Album? // Khai báo biến filesVC2 ở mức độ lớp
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fileTab4 = self


        // Add right bar button item
               let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "circle"), style: .plain, target: self, action: #selector(rightBarButtonItemTapped))
              rightBarButtonItem.tintColor = UIColor(hex: "#F17946")
               self.navigationItem.rightBarButtonItem = rightBarButtonItem
        // Do any additional setup after loading the view.
        
        filesVC2 = Album() // Gán giá trị cho biến filesVC2 trong phương thức viewDidLoad()
               fileTab2 = filesVC2
        // Load albums data from UserDefaults
          if let savedAlbums = userDefaults.dictionary(forKey: "albumsDictionary") as? [String: [String]] {
              albumsDictionary = savedAlbums
          }

    }
    


    static func makeSelf(withAlbumName albumName: String) -> Payment_Adjustment {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let paymentAdjustmentViewController = storyboard.instantiateViewController(withIdentifier: "Payment_Adjustment") as! Payment_Adjustment
        paymentAdjustmentViewController.title = albumName
        return paymentAdjustmentViewController
    }
    
    @objc func rightBarButtonItemTapped() {
        let allFilesViewController = All_files.makeSelf(withAlbumName: "All_files")
        navigationController?.pushViewController(allFilesViewController, animated: true)
        // Handle right bar button item tap
        //print("Right bar button item tapped")
    }

    func addSong(_ songName: String, toAlbum albumName: String) {
        if let albumSongs = filesVC2?.albumsDictionary[albumName] {
            var updatedAlbumSongs = albumSongs
            updatedAlbumSongs.append(songName)
            filesVC2?.albumsDictionary[albumName] = updatedAlbumSongs
            filesVC2?.userDefaults.set(filesVC2?.albumsDictionary, forKey: "albumsDictionary")
            
            // Perform any additional actions after adding the song to the album
            
            print("Song added to album: \(songName) - \(albumName)")
            
        } else {
            print("Album not found.")
        }
    }
    
    // Function to print the albumsDictionary array
    func printAlbumsDictionary() {
        print("albumsDictionary: \(albumsDictionary)")
    }

    
}

extension UIColor {
    convenience init(hex: String) {
        var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
