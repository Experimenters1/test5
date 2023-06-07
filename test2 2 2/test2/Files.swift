import UIKit
import AVFoundation
import AVKit
import MobileCoreServices


var fileTab3: Files?

class Files: UIViewController {
     

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    var filteredArr = [String]()
    var searching: Bool = false
    

    var links: [(name: String, time: String, type: String, url: URL)] = []

    let userDefaults = UserDefaults.standard
    
    var indexSelect: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fileTab3 = self
        
        
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

        
        // Register the table view cell class

        
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        
                    
        // Do any additional setup after loading the view.
        loadLinks()
                  
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
      
//





        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
                UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = .white
        
        tableView.reloadData()
    }

    
     
func saveLinks() {
    let fileManager = FileManager.default
    guard let documentsFolderURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
        return
    }
     print("FVHBVFJVNJNFVF\(documentsFolderURL)")
    let fileURLs = try? fileManager.contentsOfDirectory(at: documentsFolderURL, includingPropertiesForKeys: nil)
    let fileNames = fileURLs?.map { $0.lastPathComponent }
    userDefaults.set(fileNames, forKey: "fileName")
}
    
    

    func loadLinks() {
        links.removeAll() // Xóa dữ liệu hiện có để làm mới

        guard let fileNames = userDefaults.array(forKey: "fileName") as? [String] else {
            return
        }

        let fileManager = FileManager.default
        guard let documentsFolderURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }

        for fileName in fileNames {
            let fileURL = documentsFolderURL.appendingPathComponent(fileName)
            let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path)
            let creationDate = attributes?[.creationDate] as? Date ?? Date()
            let type = fileURL.pathExtension.lowercased()

            let time = DateFormatter.localizedString(from: creationDate, dateStyle: .medium, timeStyle: .medium)
            links.append((name: fileName, time: time, type: type, url: fileURL))
        }
    }

            
           
           
func copyFileToDocumentsFolder(sourceURL: URL, destinationURL: URL, fileName: String) throws ->String {
        let fileManager = FileManager.default
           
    // Tạo thư mục Documents nếu nó chưa tồn tại
    if !fileManager.fileExists(atPath: destinationURL.path) {
        try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
    }
               
               let destinationFilePath = destinationURL.appendingPathComponent(sourceURL.lastPathComponent)
               
               // Kiểm tra nếu file đã tồn tại trong Documents thì sửa đổi tên file đó và lưu lại
               if fileManager.fileExists(atPath: destinationFilePath.path) {
                   let fileNameWithoutExtension = sourceURL.lastPathComponent.components(separatedBy: ".").first ?? "file"
                   let fileExtension = sourceURL.pathExtension
                   var newFileName = "\(fileNameWithoutExtension) (copy).\(fileExtension)"
                   var fileNumber = 1
                   while fileManager.fileExists(atPath: destinationURL.appendingPathComponent(newFileName).path) {
                       fileNumber += 1
                       newFileName = "\(fileNameWithoutExtension) (copy \(fileNumber)).\(fileExtension)"
                   }
                   try fileManager.copyItem(at: sourceURL, to: destinationURL.appendingPathComponent(newFileName))
                   return newFileName
               } else {
                   // Copy file vào thư mục Documents nếu file chưa tồn tại trong thư mục đó
                   try fileManager.copyItem(at: sourceURL, to: destinationFilePath)
               }
               
               return fileName
           }
    


}

extension Files: UITableViewDataSource {

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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TableViewCell else {
            return UITableViewCell()
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
            setMoreButton(for: cell)
        }
        cell.tag = indexPath.row
        cell.backgroundColor = UIColor(red: 0.525, green: 0.525, blue: 0.525, alpha: 1)
        return cell
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
    }

fileprivate extension Files {
    func configure() {
        self.title = "UIMenu Sample"
    }
    
    func setMoreButton(for cell: TableViewCell) {
        
        let menu = UIMenu(title: "", children: [actionEdit, actionDelete])
        cell.Rename_Delete.menu = menu
        cell.Rename_Delete.showsMenuAsPrimaryAction = true  //Nhan vao thi hien ra Menu
        
    }
    
    var actionEdit: UIAction {
        return UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { [weak self] action in
            guard let self = self,
                  let button = action.sender as? UIButton,
                  let cell = button.superview?.superview as? TableViewCell,
                  let indexPath = self.tableView.indexPath(for: cell) else { return }

            let alert = UIAlertController(title: "Set new name for file", message: "", preferredStyle: .alert)

            alert.addTextField { textField in
                textField.placeholder = "Enter new name"
                textField.text = cell.videoNameLabel.text
            }

            let update = UIAlertAction(title: "Rename", style: .default) { [weak self] action in
                guard let self = self,
                      let updateName = alert.textFields?.first?.text else { return }

                // Cập nhật tên video trong mảng dữ liệu của bạn
                let videoName: String
                if self.searching {
                    // Nếu đang tìm kiếm, cập nhật vào mảng filteredArr
                    if indexPath.row < self.filteredArr.count {
                        videoName = self.filteredArr[indexPath.row]
                        self.filteredArr[indexPath.row] = updateName
                    } else {
                        return
                    }
                } else {
                    // Nếu không tìm kiếm, cập nhật vào mảng links
                    if indexPath.row < self.links.count {
                        videoName = self.links[indexPath.row].name
                        self.links[indexPath.row].name = updateName
                    } else {
                        return
                    }
                }

                DispatchQueue.main.async {
                    let fileManager = FileManager.default
                    guard let documentsFolderURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                        return
                    }

                    let sourceURL = documentsFolderURL.appendingPathComponent(videoName)
                    let destinationURL = documentsFolderURL.appendingPathComponent(updateName)

                    do {
                        try fileManager.moveItem(at: sourceURL, to: destinationURL)

                        self.saveLinks() // Cập nhật dữ liệu trong saveLinks()

                        self.loadLinks() // Load lại dữ liệu từ Documents
                        self.tableView.reloadData()
                        print("Update btn Tapped")
                        print("Updated video name:", videoName)
                        print("Updated file name in Documents:", updateName)
                    } catch {
                        print("Error updating file name:", error)
                    }
                }
            }

            alert.addAction(update)

            // Thêm nút hủy bỏ
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancel)

            self.present(alert, animated: true, completion: nil)
        }
    }



    
    var actionDelete: UIAction {
        return UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] deleteAction in
            // Perform delete action here
            guard let self = self,
                  let button = deleteAction.sender as? UIButton,
                  let cell = button.superview?.superview as? TableViewCell,
                  let indexPath = self.tableView.indexPath(for: cell) else { return }

            let fileManager = FileManager.default
            let videoName: String

            if self.searching {
                if indexPath.row < self.filteredArr.count {
                    videoName = self.filteredArr[indexPath.row]
                    self.filteredArr.remove(at: indexPath.row)
                } else {
                    return
                }
            } else {
                if indexPath.row < self.links.count {
                    videoName = self.links[indexPath.row].name
                    self.links.remove(at: indexPath.row)
                } else {
                    return
                }
            }

            guard let documentsFolderURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return
            }

            let fileURL = documentsFolderURL.appendingPathComponent(videoName)

            let alert = UIAlertController(title: "Delete File", message: "Confirm the deletion of the file", preferredStyle: .alert)

            let delete = UIAlertAction(title: "Delete", style: .destructive) { [weak self] action in
                guard let self = self else { return }

                do {
                    try fileManager.removeItem(at: fileURL)

                    self.saveLinks() // Cập nhật dữ liệu trong saveLinks()
                    self.loadLinks() // Load lại dữ liệu từ Documents
                    self.tableView.reloadData()
                } catch {
                    print("Error deleting file:", error)
                }
            }

            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

            alert.addAction(delete)
            alert.addAction(cancel)

            self.present(alert, animated: true, completion: nil)
        }
    }


}



// MARK: - UITableViewDelegate
extension Files: UITableViewDelegate {

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




extension Files: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
            searchBar.showsCancelButton = true
            return true
        }
    
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
            searchBar.showsCancelButton = false
            searching = false
            searchBar.text = ""
            tableView.reloadData()
        }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            filteredArr = links.filter({$0.name.lowercased().prefix(searchText.count) == searchText.lowercased()})
                .map({$0.name})
           print(filteredArr)

            searching = true
            tableView.reloadData()
        }


    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}




