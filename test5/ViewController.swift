    //
//  ViewController.swift
//  test5
//
//  Created by huy on 25/04/2023.
//

    import UIKit
    import AVFoundation
    import AVKit
    import MobileCoreServices


    class ViewController: UIViewController {
        
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
        
        @IBAction func addLinkButtonTapped(_ sender: Any) {
            // Display file picker to select a file
            let filePicker = UIDocumentPickerViewController(documentTypes: ["public.data"], in: .import)
            filePicker.delegate = self
            present(filePicker, animated: true)
        }
        
        
        @IBAction func selectPhotoButtonTapped(_ sender: Any) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            picker.mediaTypes = [kUTTypeMovie as String]
            present(picker, animated: true)
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

    extension ViewController: UITableViewDataSource {

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
            
            cell.textLabel?.text = links[indexPath.row].name
            cell.detailTextLabel?.text = links[indexPath.row].date
            cell.detailTextLabel?.text = links[indexPath.row].url.path
            return cell
        }
        
    }


    // MARK: - UITableViewDelegate

    extension ViewController: UITableViewDelegate {

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


    extension ViewController: UIDocumentPickerDelegate {

        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let sourceURL = urls.first else { return }
            let destinationURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileName = sourceURL.lastPathComponent

            do {
                
                let newName = try copyFileToDocumentsFolder(sourceURL: sourceURL, destinationURL: destinationURL, fileName: fileName)
                links.append((name: newName, date: "", type: sourceURL.pathExtension, url: destinationURL.appendingPathComponent(newName)))
                saveLinks()
                tableView.reloadData()
            } catch {
                print("Error copying file: \(error.localizedDescription)")
            }
        }
    }


extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)

        guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
              mediaType == (kUTTypeMovie as String),
              let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL else {
            return
        }
        let documentsFolderURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsFolderURL.appendingPathComponent(url.lastPathComponent)
        do {
            let fileName = try copyFileToDocumentsFolder(sourceURL: url, destinationURL: documentsFolderURL, fileName: url.lastPathComponent)
            let type = url.pathExtension.lowercased()
            links.append((name: fileName, date: DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .medium), type: type, url: destinationURL))
            tableView.reloadData()
            saveLinks()
        } catch {
            print(error.localizedDescription)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

