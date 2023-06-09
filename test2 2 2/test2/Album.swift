//
//  Album.swift
//  test2
//
//  Created by huy on 5/22/23.
//

import UIKit
import UIKit
import AVFoundation
import AVKit
import MobileCoreServices
import SDWebImageSwiftUI
import SwiftUI


var fileTab2: Album?

class Album: UIViewController {
    
    let userDefaults = UserDefaults.standard

    var albumsDictionary: [String: [String]] = [:]
    
    var links: [(name: String, time: String, type: String, url: URL)] = []
    
    @IBOutlet weak var TableView_Album: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fileTab2 = self
        
        
        // Do any additional setup after loading the view.
        TableView_Album.register(UINib(nibName: "TableViewCell_Album", bundle: nil), forCellReuseIdentifier: "cell_Album")
        
        // Load albums data from UserDefaults
        if let savedAlbums = userDefaults.dictionary(forKey: "albumsDictionary") as? [String: [String]] {
            albumsDictionary = savedAlbums
        }
//        TableView_Album.backgroundColor = UIColor(red: 0.525, green: 0.525, blue: 0.525, alpha: 1)
        TableView_Album.reloadData()
        
        //NotificationCenter.default.addObserver(self, selector: #selector(albumsDictionaryDidChange), name: UserDefaults.didChangeNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let savedAlbums = userDefaults.dictionary(forKey: "albumsDictionary") as? [String: [String]] {
            albumsDictionary = savedAlbums
        }
     
        TableView_Album.reloadData()
    }

    
    
    @IBAction func btn_add_Album(_ sender: Any) {
        let alert = UIAlertController(title: "Create Album", message: "Enter album name", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Album name"
        }
        
        let createAction = UIAlertAction(title: "Create", style: .default) { [weak self, weak alert] _ in
            guard let albumName = alert?.textFields?.first?.text else { return }
            self?.createNewAlbum(withName: albumName)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(createAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func createNewAlbum(withName name: String) {
        if albumsDictionary.keys.contains(name) {
            print("Album name already exists.")
            return
        }
        
        albumsDictionary[name] = []
        userDefaults.set(albumsDictionary, forKey: "albumsDictionary")
        
        TableView_Album.reloadData()
        print("New album created: \(name)")
    }
    
    func addSong(_ songName: String, toAlbum albumName: String) {
        if var albumSongs = albumsDictionary[albumName] {
            albumSongs.append(songName)
            albumsDictionary[albumName] = albumSongs
            userDefaults.set(albumsDictionary, forKey: "albumsDictionary")
            
            // Perform any additional actions after adding the song to the album
            
            print("Song added to album: \(songName) - \(albumName)")
            
        } else {
            print("Album not found.")
        }
    }
    
    deinit {
            NotificationCenter.default.removeObserver(self)
        }
        
    @objc func albumsDictionaryDidChange() {
        if let savedAlbums = userDefaults.dictionary(forKey: "albumsDictionary") as? [String: [String]] {
            albumsDictionary = savedAlbums
            TableView_Album.reloadData()
        }
    }
}



extension Album: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumsDictionary.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell_Album", for: indexPath) as? TableViewCell_Album else {
            return UITableViewCell()
        }
        
        let albumNames = Array(albumsDictionary.keys)
        
        if indexPath.row < albumNames.count {
            let albumName = albumNames[indexPath.row]
            cell.NameLabel.text = albumName
            
            // Update albumsDictionary and thumbnail image for the cell
            updateAlbumsDictionary(for: cell, albumName: albumName)
            updateSongCount(forCell: cell, atIndexPath: indexPath)
        }
        
        cell.backgroundColor = UIColor(red: 0.525, green: 0.525, blue: 0.525, alpha: 1)
        cell.tag = indexPath.row // Gán giá trị indexPath.row cho thuộc tính tag của cell
        
        // Gọi hàm setMoreButton để gán hành động cho nút Rename_Delete
        setMoreButton(for: cell, at: indexPath)
        
        return cell
    }
    
    func cropImage(fromURL url: URL, completion: @escaping (UIImage?) -> Void) {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let cgImage = try imageGenerator.copyCGImage(at: CMTime(seconds: 1, preferredTimescale: 1), actualTime: nil)
            let image = UIImage(cgImage: cgImage)
            
            // Thực hiện việc cắt ảnh ở đây (ví dụ: resize, crop, ...)
            // Ví dụ: Cắt ảnh thành kích thước 200x200
            let croppedImage = image.sd_resizedImage(with: CGSize(width: 200, height: 200), scaleMode: .aspectFill)
            
            completion(croppedImage)
        } catch {
            print(error.localizedDescription)
            completion(nil)
        }
    }
    
    
    func updateAlbumsDictionary(for cell: TableViewCell_Album, albumName: String) {
        // Retrieve the existing albumsDictionary from UserDefaults
        guard var albumsDictionary = UserDefaults.standard.dictionary(forKey: "albumsDictionary") as? [String: [String]],
            let documentsFolderURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let firstSongName = albumsDictionary[albumName]?.first else {
                return
        }
        
        // Get videoURL for the song in the specified album
        let videoURL = documentsFolderURL.appendingPathComponent(firstSongName)
        print("huy1 \(firstSongName)")
        print("huy2 \(firstSongName)")
        cropImage(fromURL: videoURL) { croppedImage in
            DispatchQueue.main.async {
                if let image = croppedImage {
                    // Lưu ảnh vào bộ nhớ cache của SDWebImageSwiftUI
                    let cacheKey = "album_\(albumName)"
                    SDImageCache.shared.store(image, forKey: cacheKey, toDisk: true) {
                        // Hiển thị ảnh từ bộ nhớ cache bằng SDWebImageSwiftUI
                        if let cachedImage = SDImageCache.shared.imageFromCache(forKey: cacheKey) {
                            cell.imge.image = cachedImage
                        } else {
                            cell.imge.image = UIImage(named: "album thumbnail")
                        }
                    }
                } else {
                    cell.imge.image = UIImage(named: "album thumbnail")
                }
            }
        }
    }
    
    
    func updateSongCount(forCell cell: TableViewCell_Album, atIndexPath indexPath: IndexPath) {
        let albumNames = Array(albumsDictionary.keys)
        
        if indexPath.row < albumNames.count {
            let albumName = albumNames[indexPath.row]
            cell.NameLabel.text = albumName
            
            if let albumSongs = albumsDictionary[albumName] {
                let songCount = albumSongs.count
                cell.quantity_Label.text = "\(songCount) \(songCount != 1 ? " " : "")"
            } else {
                cell.quantity_Label.text = "0 songs"
            }
        }
    }
    


    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath) as? TableViewCell_Album
        if let albumName = selectedCell?.NameLabel.text {
            let paymentAdjustmentViewController = Payment_Adjustment.makeSelf(withAlbumName: albumName)
            self.navigationController?.pushViewController(paymentAdjustmentViewController, animated: true)
        }
    }


}

fileprivate extension Album {
    func configure() {
        self.title = "UIMenu Sample"
    }
    
    func setMoreButton(for cell: TableViewCell_Album, at indexPath: IndexPath) {
        
        let menu = UIMenu(title: "", children: [actionEdit(at: indexPath), actionDelete(at: indexPath)])
        cell.Rename_Delete.menu = menu
        cell.Rename_Delete.showsMenuAsPrimaryAction = true  // Nhấn vào thì hiển thị Menu
        
    }
    
    func actionEdit(at indexPath: IndexPath) -> UIAction {
        return UIAction(title: "Rename", image: UIImage(systemName: "pencil")) { [weak self] action in
            guard let self = self,
                let button = action.sender as? UIButton,
                let cell = button.superview?.superview as? TableViewCell_Album else { return }
            
            let alertController = UIAlertController(title: "Rename Album", message: nil, preferredStyle: .alert)
            
            alertController.addTextField { textField in
                textField.placeholder = "Enter new album name"
                
                let albumNames = Array(self.albumsDictionary.keys)
                if indexPath.row < albumNames.count {
                    let oldAlbumName = albumNames[indexPath.row]
                    textField.text = oldAlbumName // Hiển thị tên album hiện tại trong text field
                }
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            let renameAction = UIAlertAction(title: "Rename", style: .default) { _ in
                guard let textField = alertController.textFields?.first,
                    let albumName = textField.text else {
                        return
                }
                
                // Cập nhật dữ liệu trong UserDefaults
                let albumNames = Array(self.albumsDictionary.keys)
                if indexPath.row < albumNames.count {
                    let oldAlbumName = albumNames[indexPath.row]
                    
                    if albumName.isEmpty {
                        // Nếu album name trống, không thực hiện hành động
                        return
                    } else {
                        // Nếu có album name mới khác tên album cũ, cập nhật vào UserDefaults
                        if albumName != oldAlbumName {
                            let albumValue = self.albumsDictionary[oldAlbumName]
                            self.albumsDictionary.removeValue(forKey: oldAlbumName)
                            self.albumsDictionary[albumName] = albumValue
                            
                            // Lưu lại dữ liệu vào UserDefaults
                            UserDefaults.standard.set(self.albumsDictionary, forKey: "albumsDictionary")
                        }
                    }
                    
                    // Cập nhật tên mới trên UITableView
                    if let cell = self.TableView_Album.cellForRow(at: indexPath) as? TableViewCell_Album {
                        cell.NameLabel.text = albumName
                    }
                }
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(renameAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }

    
    func actionDelete(at indexPath: IndexPath) -> UIAction {
        return UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] action in
            guard let self = self,
                  let button = action.sender as? UIButton,
                  let cell = button.superview?.superview as? TableViewCell_Album else { return }
            
            let albumNames = Array(self.albumsDictionary.keys)
            if indexPath.row < albumNames.count {
                let albumName = albumNames[indexPath.row]
                
                // Tạo thông báo xác nhận xoá file
                let alert = UIAlertController(title: "Delete File", message: "Confirm the deletion of the file", preferredStyle: .alert)
                
                // Thêm hành động Cancel
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                // Thêm hành động Delete
                alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                    // Xoá dữ liệu trong UserDefaults
                    self.albumsDictionary.removeValue(forKey: albumName)
                    UserDefaults.standard.set(self.albumsDictionary, forKey: "albumsDictionary")
                    
                    // Xoá cell trong UITableView
                    self.TableView_Album.deleteRows(at: [indexPath], with: .automatic)
                }))
                
                // Hiển thị thông báo
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

}
