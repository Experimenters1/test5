//
//  Album.swift
//  test2
//
//  Created by huy on 5/22/23.
//

import UIKit

class Album: UIViewController {
    
    let userDefaults = UserDefaults.standard
    let fileManager = FileManager.default
    var albumsDictionary: [String: [String]] = [:]
    
    @IBOutlet weak var TableView_Album: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        TableView_Album.register(UINib(nibName: "TableViewCell_Album", bundle: nil), forCellReuseIdentifier: "cell_Album")
        
        // Load albums data from UserDefaults
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
}

extension Album: UITableViewDataSource,UITableViewDelegate {
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
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96
    }
}
