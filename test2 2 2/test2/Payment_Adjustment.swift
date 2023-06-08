//
//  Payment_Adjustment.swift
//  test2
//
//  Created by huy on 5/25/23.
//

import UIKit
import UIKit
import AVFoundation
import AVKit
import MobileCoreServices

var fileTab4: Payment_Adjustment?

class Payment_Adjustment: UIViewController {

    @IBOutlet weak var tableViewLs: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    var albumsDictionary: [String: [String]] = [:]
    let userDefaults = UserDefaults.standard
    var filesVC2: Album? // Khai báo biến filesVC2 ở mức độ lớp
    var links: [(name: String, time: String, type: String, url: URL)] = []
    var current_albums = ""
    
    var filteredArr = [String]()
    var searching: Bool = false
    
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
        loadLinks()
        tableViewLs.delegate = self // Set the delegate of the tableViewLs
        tableViewLs.dataSource = self // Set the data source of the tableViewLs
        tableViewLs.register(UINib(nibName: "Payment_Adjustment_TableViewCell", bundle: nil), forCellReuseIdentifier: "cell_Payment")
        tableViewLs.reloadData()
        
//        tableViewLs.backgroundColor = UIColor(red: 0.525, green: 0.525, blue: 0.525, alpha: 1)
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        loadLinks()
        tableViewLs.reloadData()
    }



    static func makeSelf(withAlbumName albumName: String) -> Payment_Adjustment {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let paymentAdjustmentViewController = storyboard.instantiateViewController(withIdentifier: "Payment_Adjustment") as! Payment_Adjustment
        paymentAdjustmentViewController.title = albumName
        paymentAdjustmentViewController.current_albums = albumName // Lưu lại vào biến current_albums
        return paymentAdjustmentViewController
    }
    
    @objc func rightBarButtonItemTapped() {
        let allFilesViewController = All_files.makeSelf(withAlbumName: current_albums )
        navigationController?.pushViewController(allFilesViewController, animated: true)
        // Handle right bar button item tap
        //print("Right bar button item tapped")
    }

    func addSong_Payment_Adjustment(_ songName: String, toAlbum albumName: String) {
        loadAlbumsDictionary()
        
        if var albumSongs = albumsDictionary[albumName] {
            albumSongs.append(songName)
            albumsDictionary[albumName] = albumSongs
            userDefaults.set(albumsDictionary, forKey: "albumsDictionary")
            
            // Perform any additional actions after adding the song to the album
            
            print("Song added to album: \(songName) - \(albumName)")
            // Reload tableViewLs to reflect the changes
                   tableViewLs.reloadData()
            
        } else {
            print("Album not found: \(albumName)")
        }
    }

    
    // Function to print the albumsDictionary array
    func printAlbumsDictionary() {
        print("albumsDictionary: \(albumsDictionary)")
    }
    
    func loadAlbumsDictionary() {
        if let savedAlbums = userDefaults.dictionary(forKey: "albumsDictionary") as? [String: [String]] {
            albumsDictionary = savedAlbums
            tableViewLs.reloadData()
        }
    }



    func loadLinks() {
        // Xoá danh sách links hiện có
            links.removeAll()
        
        guard let fileNames = userDefaults.array(forKey: "fileName") as? [String] else {
            return
        }

        let fileManager = FileManager.default
        guard let documentsFolderURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        if let savedAlbums = userDefaults.dictionary(forKey: "albumsDictionary") as? [String: [String]] {
            albumsDictionary = savedAlbums
            if let albumSongs = albumsDictionary[current_albums] {
                for fileName in albumSongs {
                    let fileURL = documentsFolderURL.appendingPathComponent(fileName)
                    let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path)
                    let creationDate = attributes?[.creationDate] as? Date ?? Date()
                    let type = fileURL.pathExtension.lowercased()
                    let time = DateFormatter.localizedString(from: creationDate, dateStyle: .medium, timeStyle: .medium)
                    links.append((name: fileName, time: time, type: type, url: fileURL))
                }
            }
        }
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

extension Payment_Adjustment: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell_Payment", for: indexPath) as? Payment_Adjustment_TableViewCell else {
            fatalError("Unable to dequeue Payment_Adjustment_TableViewCell")
        }
        
        if searching {
            cell.setVideoName(name: filteredArr[indexPath.row])
        } else {
            cell.setVideoName(name: links[indexPath.row].name)
            
            let videoURL = links[indexPath.row].url
            if let thumbnail = generateThumbnail(path: videoURL) {
                cell.videoImageView.image = thumbnail
            }
            
            let videoDuration = getVideoDuration(url: videoURL)
            cell.setVideoTime(timeInterval: videoDuration)
            
            
        }
        cell.Delete.addTarget(self, action: #selector(deleteButtonTapped(_:)), for: .touchUpInside)
        cell.tag = indexPath.row
        cell.backgroundColor = UIColor(red: 0.525, green: 0.525, blue: 0.525, alpha: 1)
    
        return cell
    }
    
    @objc func deleteButtonTapped(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? Payment_Adjustment_TableViewCell,
              let indexPath = tableViewLs.indexPath(for: cell) else {
            return
        }
        
        // Remove the song name from albumsDictionary
        if var albumSongs = albumsDictionary[current_albums], indexPath.row < albumSongs.count {
            albumSongs.remove(at: indexPath.row)
            albumsDictionary[current_albums] = albumSongs
            UserDefaults.standard.set(albumsDictionary, forKey: "albumsDictionary")
        }
        
        // Remove the link from the links array
        if indexPath.row < links.count {
            links.remove(at: indexPath.row)
        }
        
        // Reload the table view
        tableViewLs.reloadData()
    }


    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return filteredArr.count
        } else {
            return links.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 93
    }
    
    func getVideoDuration(url: URL) -> TimeInterval {
        let asset = AVAsset(url: url)
        let duration = asset.duration
        let durationSeconds = CMTimeGetSeconds(duration)
        return durationSeconds
    }
    
    func generateThumbnail(path: URL) -> UIImage? {
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
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {   // Hàm được gọi khi người dùng chọn một cell trong UITableView
        let url = links[indexPath.row].url
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        present(playerViewController, animated: true) {
            player.play()
        }
    }

}

extension Payment_Adjustment: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        searching = false
        searchBar.text = ""
        tableViewLs.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredArr = links.filter({ $0.name.lowercased().prefix(searchText.count) == searchText.lowercased() }).map({ $0.name })
        searching = true
        tableViewLs.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}


