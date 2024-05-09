// Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit

class MusicDashboardController: UIViewController {
   

    @IBOutlet var backView: UIView!
    @IBOutlet var searchTF: UITextField!
    @IBOutlet var searchBtn: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var no_songs_available: UILabel!
    var songModels = Array<Result>()

    override func viewDidLoad() {
        guard UserModel.data != nil else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        searchTF.delegate = self
        searchBtn.layer.cornerRadius = 8
        searchBtn.isUserInteractionEnabled = true
        searchBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(searchClicked)))
      
        self.backView.layer.cornerRadius = 8
        self.backView.dropShadow()
        self.backView.isUserInteractionEnabled = true
        self.backView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.backViewClicked)
        ))

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.showsVerticalScrollIndicator = false

        self.searchBtn.layer.cornerRadius = 8

    
        ProgressHUDShow(text: "")
        searchSongs(songName:"latest+english") { songModel, error in
            DispatchQueue.main.async {
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error)
                }
                else {
                    self.songModels.removeAll()
                    if let songModel = songModel {
                        if let data = songModel.data {
                            if let results = data.results {
                                self.songModels.append(contentsOf: results)
                            }
                        }
                    }
                    self.tableView.reloadData()
                    
                }
            }
            
        }

    }
    
  
    @objc func songCellClicked(value : MyGesture){
        performSegue(withIdentifier: "playMusicSeg", sender: value.index)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playMusicSeg" {
            if let VC = segue.destination as? PlayMusicViewController {
                if let position = sender as? Int {
                    VC.position = position
                    VC.items = self.songModels
                }
            }
        }
    }
    
    @objc func backViewClicked() {
        self.dismiss(animated: true)
    }
    @objc func searchClicked(){
      
        if let strSearch = searchTF.text, !strSearch.isEmpty {
            self.ProgressHUDShow(text: "")
            let songName = strSearch.replacingOccurrences(of: " ", with: "+")
            searchSongs(songName: songName) { songModel, error in
                DispatchQueue.main.async {
                    self.ProgressHUDHide()
                    if let error = error {
                        self.showError(error)
                    }
                    else {
                        self.songModels.removeAll()
                        if let songModel = songModel {
                            if let data = songModel.data {
                                if let results = data.results {
                                    self.songModels.append(contentsOf: results)
                                }
                            }
                        }
                        self.tableView.reloadData()
                        
                    }
                }
                
            }
            
        }
        else {
            self.songModels.removeAll()
            self.tableView.reloadData()
        }
    }
    

}

extension MusicDashboardController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        self.no_songs_available.isHidden = self.songModels.count > 0 ? true : false
        return self.songModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: "songsCell",
            for: indexPath
        ) as? SongsListTableViewCell {
            cell.mImage.layer.cornerRadius = 8
            cell.mView.layer.cornerRadius = 8

            let item = self.songModels[indexPath.row]
            
            if let images = item.image {
                cell.mImage.sd_setImage(with: URL(string: images[2].link!), placeholderImage: UIImage(named: "placeholder"))
            }
            cell.mTitle.text = item.name!
            cell.mArtist.text = item.primaryArtists!

            cell.mExplicitIcon.isHidden = item.explicitContent == 0 ? true : false

            let myGest = MyGesture(target: self, action: #selector(self.songCellClicked(value:)))
            myGest.index = indexPath.row
            cell.mView.isUserInteractionEnabled = true
            cell.mView.addGestureRecognizer(myGest)

            return cell
        }

        return SongsListTableViewCell()
    }
}
extension MusicDashboardController : UITextFieldDelegate {
    
 
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
                if textField == searchTF {
                    self.searchClicked()
                }
            return true
        }
      
    
}
