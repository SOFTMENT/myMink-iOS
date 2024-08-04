//
//  ShowProductDetailsViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 09/04/24.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import MapKit
import SDWebImage
import EventKit
import TTGSnackbar

class ShowProductDetailsViewController: UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var headerCollectionView: UICollectionView!
    @IBOutlet weak var myPageView: UIPageControl!
    @IBOutlet weak var navigationBar: UIView!
    @IBOutlet weak var topProfileImage: SDAnimatedImageView!
    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var ticketBtn: UIButton!
    @IBOutlet weak var topOrganizerName: UILabel!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventDescritption: UILabel!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var share: UIImageView!
    @IBOutlet weak var ticketPrice: UILabel!
    @IBOutlet weak var userName: UILabel!
    
    var product: MarketplaceModel?
    var imgArr: [String] = []
    var timer = Timer()
    var counter = 0
    var userModel: UserModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI(product: product)
    }
    
    func updateUI(product: MarketplaceModel?) {
        guard let product = product else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        categoryLbl.text = product.categoryName ?? ""
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backClicked)))
        
        headerCollectionView.delegate = self
        headerCollectionView.dataSource = self
        myPageView.currentPage = 0
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.changeImage), userInfo: nil, repeats: true)
        }
        
        topProfileImage.makeRounded()
        ticketBtn.layer.cornerRadius = 8
        topProfileImage.setImage(imageKey: "", placeholder: "profile-placeholder", width: 100, height: 100, shouldShowAnimationPlaceholder: true)
        
        getUserDataByID(uid: product.uid!) { userModel, error in
            if let userModel = userModel {
                self.userModel = userModel
                self.topOrganizerName.text = userModel.fullName ?? ""
                self.userName.text = "@\(userModel.username!)"
                if let path = userModel.profilePic, !path.isEmpty {
                    self.topProfileImage.setImage(imageKey: path, placeholder: "profile-placeholder", width: 100, height: 100, shouldShowAnimationPlaceholder: true)
                }
            }
        }
        
        eventTitle.text = product.title ?? "Something Went Wrong"
        navigationTitle.text = product.title ?? "Something Went Wrong"
        eventDescritption.text = product.about ?? ""
        
        if let images = product.productImages {
            imgArr.append(contentsOf: images)
        }
        
        headerCollectionView.reloadData()
        myPageView.numberOfPages = imgArr.count
        ticketPrice.text = "\(getCurrencyCode(forRegion: Locale.current.regionCode!) ?? "AU") \(String(format: "%.2f", Double(product.cost ?? "0")!))"
        ticketBtn.setTitle("Contact", for: .normal)
        
        share.isUserInteractionEnabled = true
        share.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(shareProduct)))
    }
    
    @objc func shareProduct() {
        if let shareURL = product?.productUrl, !shareURL.isEmpty {
            let items: [Any] = [shareURL]
            let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
            if let popoverController = activityViewController.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            self.present(activityViewController, animated: true)
        } else {
            self.showSnack(messages: "Share URL not found.")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewProfileSeg", let VC = segue.destination as? ViewUserProfileController {
            VC.user = self.userModel
        } else if segue.identifier == "showChatSeg", let vc = segue.destination as? ShowChatViewController {
            guard let userModel = self.userModel else { return }
            let lastModel = LastMessageModel()
            lastModel.senderName = userModel.fullName ?? "Full Name"
            lastModel.senderUid = userModel.uid ?? "123"
            lastModel.senderToken = userModel.notificationToken ?? "Token"
            lastModel.senderImage = userModel.profilePic ?? ""
            lastModel.senderDeviceToken = userModel.deviceToken ?? ""
            vc.lastMessage = lastModel
        }
    }
    
    @IBAction func ticketBtnClicked(_ sender: Any) {
        performSegue(withIdentifier: "showChatSeg", sender: nil)
    }
    
    @objc func changeImage() {
        if counter < imgArr.count {
            let index = IndexPath(item: counter, section: 0)
            self.headerCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
            myPageView.currentPage = counter
            counter += 1
        } else {
            counter = 0
            let index = IndexPath(item: counter, section: 0)
            self.headerCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
            myPageView.currentPage = counter
            counter = 1
        }
    }
    
    @objc func backClicked() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ShowProductDetailsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = headerCollectionView.frame.size
        return CGSize(width: size.width, height: size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}

extension ShowProductDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "headercell", for: indexPath) as? HeaderViewCell {
            let img = imgArr[indexPath.row]
            cell.mImage.setImage(imageKey: img, placeholder: "placeholder", width: 600, height: 600, shouldShowAnimationPlaceholder: true)
            return cell
        }
        return HeaderViewCell()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let visibleIndex = Int(targetContentOffset.pointee.x / headerCollectionView.frame.width)
        myPageView.currentPage = visibleIndex
        counter = visibleIndex
    }
}
