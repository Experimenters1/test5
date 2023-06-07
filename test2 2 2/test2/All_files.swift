//
//  All_files.swift
//  test2
//
//  Created by huy on 5/25/23.
//

import UIKit
import AVFoundation
import AVKit
import MobileCoreServices



class All_files: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    var filteredArr = [String]()
    var searching: Bool = false
    
    var links: [(name: String, time: String, type: String, url: URL)] = []

    let userDefaults = UserDefaults.standard
    
    var indexSelect: Int = 0
    

    var isCheckedArray: [Bool] = []
    var selectedItems: [String] = []
    var current_albums = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(rightBarButtonItemTapped))
       rightBarButtonItem.tintColor = UIColor(hex: "#F17946")
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
        tableView.register(UINib(nibName: "TableViewCell_All_files", bundle: nil), forCellReuseIdentifier: "cell_All_files")
        
        tableView.dataSource = self
        searchBar.delegate = self
      
//        tableView.backgroundColor = UIColor(red: 0.525, green: 0.525, blue: 0.525, alpha: 1)
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
                UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = .white
        
        let filesVC1 = Files()
        fileTab3 = filesVC1
        loadLinks()
    
    }
    
    func loadLinks() {
        links.removeAll()

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

        let rowCount = links.count
        isCheckedArray = [Bool](repeating: false, count: rowCount)
        tableView.reloadData()
    }

    
  

    
    
    static func makeSelf(withAlbumName albumName: String) -> All_files {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let All_filesViewController = storyboard.instantiateViewController(withIdentifier: "All_files") as! All_files
        All_filesViewController.title = albumName
        All_filesViewController.current_albums = albumName
        return All_filesViewController
    }
    

    @objc func rightBarButtonItemTapped() {
        let filesVC4 = fileTab4!


        // Gọi hàm addSong với từng phần tử trong selectedItems
        for songName in selectedItems {
            filesVC4.addSong_Payment_Adjustment(songName, toAlbum: current_albums)
        }

        print("Right bar button item tapped")
        

        
        // Trở về màn hình trước
        navigationController?.popViewController(animated: true)
    }


}


extension All_files: UITableViewDataSource ,UITableViewDelegate {
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell_All_files", for: indexPath) as? TableViewCell_All_files else {
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
            }

        let isChecked = isCheckedArray[indexPath.row]
            cell.checkbox.isSelected = isChecked
            cell.checkbox.setImage(UIImage(named: isChecked ? "checkbox" : "checkbox 1"), for: .normal)

            var indexPathForClosure = indexPath // Tạo biến indexPath cục bộ

            cell.checkboxAction = { [weak self] isChecked in
                guard let self = self else { return }
                self.toggleCheckbox(at: indexPathForClosure.row, isChecked: isChecked) // Sử dụng biến indexPath cục bộ
                cell.checkbox.isSelected = isChecked
                cell.checkbox.setImage(UIImage(named: isChecked ? "checkbox" : "checkbox 1"), for: .normal)
            }


            cell.tag = indexPath.row
            cell.backgroundColor = UIColor(red: 0.525, green: 0.525, blue: 0.525, alpha: 1)
            return cell
        }

        private func toggleCheckbox(at index: Int, isChecked: Bool) {
            isCheckedArray[index] = isChecked
        }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? TableViewCell_All_files {
            let isChecked = !cell.checkbox.isSelected
            cell.checkbox.isSelected = isChecked
            cell.checkbox.setImage(UIImage(named: isChecked ? "checkbox" : "checkbox 1"), for: .normal)
            
            isCheckedArray[indexPath.row] = isChecked
            
            if isChecked {
                let name = links[indexPath.row].name
                selectedItems.append(name)
            } else {
                let name = links[indexPath.row].name
                if let index = selectedItems.firstIndex(of: name) {
                    selectedItems.remove(at: index)
                }
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
            // In ra mảng selectedItems
                    print(selectedItems)
        }
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
}



extension All_files: UISearchBarDelegate {
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

