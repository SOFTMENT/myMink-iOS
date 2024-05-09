// Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit

class ContentCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var containerItem: SPTAppRemoteContentItem? = nil {
        didSet {
            self.needsReload = true
        }
    }

    var contentItems = [SPTAppRemoteContentItem]()
    var needsReload = true

    var appRemote: SPTAppRemote? {
        return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.appRemote
    }

    func loadContent() {
        guard self.needsReload == true else {
            return
        }

        if let container = containerItem {
            self.appRemote?.contentAPI?.fetchChildren(of: container) { items, _ in
                if let contentItems = items as? [SPTAppRemoteContentItem] {
                    self.contentItems = contentItems
                }
                self.collectionView?.reloadData()
            }
        } else {
            self.appRemote?.contentAPI?.fetchRecommendedContentItems(
                forType: SPTAppRemoteContentTypeDefault,
                flattenContainers: true
            ) { items, _ in
                if let contentItems = items as? [SPTAppRemoteContentItem] {
                    self.contentItems = contentItems
                }
                self.collectionView?.reloadData()
            }
        }

        self.needsReload = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.containerItem = nil
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.navigationItem.title = self.containerItem?.title ?? "Spotify"
        self.loadContent()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return self.contentItems.count
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ContentItemCell",
            for: indexPath
        ) as! ContentItemCell
        let item = self.contentItems[indexPath.item]

        cell.titleLabel?.text = item.title
        cell.subtitleLabel?.text = item.subtitle

        cell.imageView.image = nil
        self.appRemote?.imageAPI?.fetchImage(forItem: item, with: self.scaledSizeForCell(cell)) { image, _ in
            // If the cell hasn't been reused
            if cell.titleLabel.text == item.title {
                cell.imageView?.image = image as? UIImage
            }
        }

        return cell
    }

    private func scaledSizeForCell(_ cell: UICollectionViewCell) -> CGSize {
        let scale = UIScreen.main.scale
        let size = cell.frame.size
        return CGSize(width: size.width * scale, height: size.height * scale)
    }

    // MARK: UICollectionViewDelegateFlowLayout

    func collectionView(
        _ collectionView: UICollectionView,
        layout _: UICollectionViewLayout,
        sizeForItemAt _: IndexPath
    ) -> CGSize {
        let width = collectionView.frame.width / 2.0
        return CGSize(width: width, height: width)
    }

    func collectionView(
        _: UICollectionView,
        layout _: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt _: Int
    ) -> CGFloat {
        return 0.0
    }

    func collectionView(
        _: UICollectionView,
        layout _: UICollectionViewLayout,
        minimumLineSpacingForSectionAt _: Int
    ) -> CGFloat {
        return 0.0
    }

    override func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let id = restorationIdentifier,
              let newVc = storyboard?.instantiateViewController(withIdentifier: id) as? ContentCollectionViewController
        else {
            return
        }

        let selectedItem = self.contentItems[indexPath.item]

        if selectedItem.isContainer {
            newVc.containerItem = selectedItem

            navigationController?.pushViewController(newVc, animated: true)
        } else {
            self.appRemote?.playerAPI?.play(selectedItem, callback: { [weak self = self] _, error in
                if let errorMessage = (error as NSError?)?.userInfo["error-identifier"] as? String {
                    let alert = UIAlertController(
                        title: NSLocalizedString("Oops!", comment: ""),
                        message: errorMessage,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(
                        title: NSLocalizedString("OK", comment: ""),
                        style: .default,
                        handler: nil
                    ))
                    self?.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
}
