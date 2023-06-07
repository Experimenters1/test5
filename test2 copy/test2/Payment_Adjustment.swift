//
//  Payment_Adjustment.swift
//  test2
//
//  Created by huy on 5/25/23.
//

import UIKit

class Payment_Adjustment: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Add right bar button item
               let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "circle"), style: .plain, target: self, action: #selector(rightBarButtonItemTapped))
              rightBarButtonItem.tintColor = UIColor(hex: "#F17946")
               self.navigationItem.rightBarButtonItem = rightBarButtonItem
        // Do any additional setup after loading the view.
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
