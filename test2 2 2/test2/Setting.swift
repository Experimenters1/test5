//
//  Setting.swift
//  test2
//
//  Created by huy on 5/31/23.
//

import UIKit
import StoreKit

class Setting: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Do any additional setup after loading the view.
        let newTitleColor = UIColor.white

        // Lấy navigation bar hiện tại của view controller
        if let navigationBar = self.navigationController?.navigationBar {
            // Tạo một bản sao của thuộc tính titleTextAttributes hiện tại
            var titleTextAttributes = navigationBar.titleTextAttributes ?? [:]
            // Đặt màu chữ mới vào thuộc tính titleTextAttributes
            titleTextAttributes[NSAttributedString.Key.foregroundColor] = newTitleColor
            
            // Thiết lập thuộc tính titleTextAttributes mới
            navigationBar.titleTextAttributes = titleTextAttributes
        }
    }
    
    @IBAction func Feed_back(_ sender: Any) {
        let alertController = UIAlertController(title: "Feed_back", message: "Mọi thắc mắc liên hệ với Huy", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func Rate_us(_ sender: Any) {
        showAppStoreRating()
    }
    
    
    func showAppStoreRating() {
        if #available(iOS 14.0, *) {
            SKStoreReviewController.requestReview()
        } else {
            // Handle older iOS versions where SKStoreReviewController is not available.
            // You can navigate the user to the App Store page using a regular link or prompt them to rate the app in a different way.
        }
    }


    @IBAction func shareLink(_ sender: Any) {
        let link = "https://github.com/Experimenters1"
            
            // Tạo một mảng chứa các đối tượng bạn muốn chia sẻ
            let items = [URL(string: link)!]
            
            // Khởi tạo một activity view controller với các đối tượng chia sẻ
            let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
            
            // Hiển thị activity view controller
            if let popoverController = activityViewController.popoverPresentationController {
                popoverController.barButtonItem = sender as? UIBarButtonItem
            }
            present(activityViewController, animated: true, completion: nil)
    }
    

}
