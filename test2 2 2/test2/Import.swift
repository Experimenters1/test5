//
//  Import.swift
//  test2
//
//  Created by huy on 07/05/2023.
//

import UIKit
import AVFoundation
import AVKit
import MobileCoreServices


class Import: UIViewController {
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
}
    
extension Import: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let sourceURL = urls.first else { return }

        let navVC = self.navigationController?.tabBarController?.viewControllers?[1] as! UINavigationController

        guard let filesVC = navVC.viewControllers[0] as? Files else {
            return
        }
//        filesVC.view.backgroundColor = .red

        let destinationURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = sourceURL.lastPathComponent

        do {
            let newName = try filesVC.copyFileToDocumentsFolder(sourceURL: sourceURL, destinationURL: destinationURL, fileName: fileName)
            let videoDuration = getVideoDuration(url: destinationURL.appendingPathComponent(newName)) ?? ""
            filesVC.links.append((name: newName, time: videoDuration, type: sourceURL.pathExtension, url: destinationURL.appendingPathComponent(newName)))

            filesVC.saveLinks()

            if let tableView = filesVC.tableView {
                DispatchQueue.main.async {
                    tableView.reloadData()
                    print("Ok Huy")
                }
            } else {
                print("Error: Table view is nil")
            }
        } catch {
            print("Error copying file: \(error.localizedDescription)")
        }
    }
    
    func getVideoDuration(url: URL) -> String? {
        let asset = AVAsset(url: url)
        let duration = asset.duration
        let durationSeconds = CMTimeGetSeconds(duration)
        
        let minutes = Int(durationSeconds / 60)
        let seconds = Int(durationSeconds) % 60
        
        let formattedDuration = String(format: "%02d:%02d", minutes, seconds)
        return formattedDuration
    }
}


extension Import: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)

        guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
              mediaType == (kUTTypeMovie as String),
              let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL else {
            return
        }
        
        let navVC = self.navigationController?.tabBarController?.viewControllers?[1] as! UINavigationController

        guard let filesVC = navVC.viewControllers[0] as? Files else {
            return
        }
        
        let documentsFolderURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsFolderURL.appendingPathComponent(url.lastPathComponent)
        
        let asset = AVAsset(url: url)
        let duration = asset.duration
        let durationSeconds = CMTimeGetSeconds(duration)
        let minutes = Int(durationSeconds / 60)
        let seconds = Int(durationSeconds) % 60
        let videoDuration = String(format: "%02d:%02d", minutes, seconds)

        
        do {
            let fileName = try filesVC.copyFileToDocumentsFolder(sourceURL: url, destinationURL: documentsFolderURL, fileName: url.lastPathComponent)
            let type = url.pathExtension.lowercased()
            filesVC.links.append((name: fileName, time: videoDuration, type: type, url: destinationURL))

            filesVC.tableView.reloadData()
            filesVC.saveLinks()
        } catch {
            print(error.localizedDescription)
        }
        
        
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
}


