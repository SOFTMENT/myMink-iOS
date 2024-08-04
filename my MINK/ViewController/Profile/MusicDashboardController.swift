// Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit

class MusicDashboardController: UIViewController {
    @IBOutlet var backView: UIView!
    @IBOutlet var searchTF: UITextField!
    @IBOutlet var searchBtn: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var noSongsAvailable: UILabel!
    var songModels = [Result]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        fetchLatestSongs()
    }

    private func setupUI() {
        searchTF.delegate = self
        searchBtn.layer.cornerRadius = 8
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        searchBtn.layer.cornerRadius = 8
    }

    private func setupActions() {
        searchBtn.isUserInteractionEnabled = true
        searchBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(searchClicked)))
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
    }

    private func fetchLatestSongs() {
        guard UserModel.data != nil else {
            dismiss(animated: true)
            return
        }
        ProgressHUDShow(text: "")
        searchSongs(songName: "latest+english") { songModel, error in
            DispatchQueue.main.async {
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error)
                } else if let results = songModel?.data?.results {
                    self.songModels = results
                    self.tableView.reloadData()
                }
            }
        }
    }

    @objc func songCellClicked(value: MyGesture) {
        performSegue(withIdentifier: "playMusicSeg", sender: value.index)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playMusicSeg",
           let VC = segue.destination as? PlayMusicViewController,
           let position = sender as? Int {
            VC.position = position
            VC.items = songModels
        }
    }

    @objc func backViewClicked() {
        dismiss(animated: true)
    }

    @objc func searchClicked() {
        guard let searchText = searchTF.text, !searchText.isEmpty else {
            songModels.removeAll()
            tableView.reloadData()
            return
        }

        ProgressHUDShow(text: "")
        let songName = searchText.replacingOccurrences(of: " ", with: "+")
        searchSongs(songName: songName) { songModel, error in
            DispatchQueue.main.async {
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error)
                } else if let results = songModel?.data?.results {
                    self.songModels = results
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension MusicDashboardController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        noSongsAvailable.isHidden = !songModels.isEmpty
        return songModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "songsCell", for: indexPath) as? SongsListTableViewCell else {
            return SongsListTableViewCell()
        }

        cell.mImage.layer.cornerRadius = 8
        cell.mView.layer.cornerRadius = 8

        let item = songModels[indexPath.row]
        
        if let images = item.image, images.count > 2 {
          
            cell.mImage.setImageOther(imageURL: images[2].link ?? "", placeholder: "placeholder", shouldShowAnimationPlaceholder: true)
        }
        cell.mTitle.text = item.name ?? ""
        cell.mArtist.text = item.primaryArtists ?? ""

        cell.mExplicitIcon.isHidden = item.explicitContent == 0

        let myGest = MyGesture(target: self, action: #selector(songCellClicked(value:)))
        myGest.index = indexPath.row
        cell.mView.isUserInteractionEnabled = true
        cell.mView.addGestureRecognizer(myGest)

        return cell
    }
}

extension MusicDashboardController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchTF {
            searchClicked()
        }
        return true
    }
}
