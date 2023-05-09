//
//  Files.swift
//  test2
//
//  Created by huy on 07/05/2023.
//

import UIKit
import AVFoundation
import AVKit
import MobileCoreServices



class Files: UIViewController {
     

    
    @IBOutlet weak var tableView: UITableView!
    var links: [(name: String, date: String, type: String, url: URL)] = []
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Register the table view cell class
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tableView")
                    
        // Do any additional setup after loading the view.
        loadLinks()
                  
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }

    
     
func saveLinks() {
    let fileManager = FileManager.default
    guard let documentsFolderURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
        return
    }
    let fileURLs = try? fileManager.contentsOfDirectory(at: documentsFolderURL, includingPropertiesForKeys: nil)
    let fileNames = fileURLs?.map { $0.lastPathComponent }
    userDefaults.set(fileNames, forKey: "fileName")
}

func loadLinks() {
     guard let fileNames = userDefaults.array(forKey: "fileName") as? [String] else {
        return
    }
    let fileManager = FileManager.default
    guard let documentsFolderURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
        return
    }
    print("Mac dinh : \(documentsFolderURL)")
               
    for fileName in fileNames {
        let fileURL = documentsFolderURL.appendingPathComponent(fileName)
        let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path)
        let creationDate = attributes?[.creationDate] as? Date ?? Date()
        let type = fileURL.pathExtension.lowercased()
        links.append((name: fileName, date: DateFormatter.localizedString(from: creationDate, dateStyle: .medium, timeStyle: .medium), type: type, url: fileURL))
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
        return links.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
     
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "tableView", for: indexPath) as? UITableViewCell else {
            return UITableViewCell()
            
        }
        
        cell.textLabel?.text = "Henvfbhvfbfhbvfvfbhv"
        cell.textLabel?.text = links[indexPath.row].name
        cell.detailTextLabel?.text = links[indexPath.row].date
        cell.detailTextLabel?.text = links[indexPath.row].url.path
        return cell
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
