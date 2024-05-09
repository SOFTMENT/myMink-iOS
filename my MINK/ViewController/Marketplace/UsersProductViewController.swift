//
//  UsersProductViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 15/04/24.
//


import UIKit
import BSImagePicker
import Photos

class UsersProductViewController : UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var addView: UIView!
    var photoArray = [UIImage]()
   
    @IBOutlet weak var storeCollectionView: UICollectionView!
    @IBOutlet weak var noProductsAvailable: UILabel!
  
    var products = Array<MarketplaceModel>()
    
    override func viewDidLoad() {
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        addView.layer.cornerRadius = 8
        addView.dropShadow()
        addView.isUserInteractionEnabled = true
        addView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addViewClicked)))

        storeCollectionView.delegate = self
        storeCollectionView.dataSource = self
        let flowLayout = UICollectionViewFlowLayout()
        let width = self.storeCollectionView.bounds.width
        flowLayout.itemSize = CGSize(width: ( width / CGFloat(2)) , height: CGFloat((width / CGFloat(2)) + 78))
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.vertical
        flowLayout.minimumInteritemSpacing = 0
        self.storeCollectionView.collectionViewLayout = flowLayout
        
        self.ProgressHUDShow(text: "")
        
        getMarketplaceProductsBy(uid: FirebaseStoreManager.auth.currentUser!.uid) { products, error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error)
            }
            else {
                self.products.removeAll()
                self.products.append(contentsOf: products ?? [])
                self.storeCollectionView.reloadData()
            }
        }
    }
    
    @objc func addViewClicked(){
       uploadImages()
    }

    @objc func marketplaceCellClicked(value : MyGesture) {
  
        performSegue(withIdentifier: "editProductSeg", sender: value.index)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editProductSeg" {
            if let VC = segue.destination as? EditProductViewController{
                if let position = sender as? Int {
                    VC.product = self.products[position]
                    VC.position = position
                }
            }
        }
        else if segue.identifier == "addProductSeg" {
            if let VC = segue.destination as? AddProductViewController {
                VC.images = self.photoArray
                VC.delegate = self
            }
        }
    }
    
    
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
   
    func uploadImages() {
        let imagePicker = ImagePickerController()
        imagePicker.settings.selection.max = 4
        presentImagePicker(imagePicker, select: { _ in
            // User selected an asset. Do something with it. Perhaps begin processing/upload?
        }, deselect: { _ in
            // User deselected an asset. Cancel whatever you did when asset was selected.
        }, cancel: { _ in
            // User canceled selection.
        }, finish: { assets in

            var imageRequestOptions: PHImageRequestOptions {
                let options = PHImageRequestOptions()
                options.version = .current
                options.resizeMode = .exact
                options.deliveryMode = .highQualityFormat
                options.isNetworkAccessAllowed = true
                options.isSynchronous = true
                return options
            }

            self.photoArray.removeAll()

            for asset in assets {
                PHImageManager.default().requestImage(
                    for: asset,
                    targetSize: PHImageManagerMaximumSize,
                    contentMode: .aspectFit,
                    options: imageRequestOptions
                ) { image, _ in
                    if let image = image {
                        self.photoArray.append(image)
                    }
                }
            }
            if !self.photoArray.isEmpty {
                self.dismiss(animated: true) {
                    self.performSegue(withIdentifier: "addProductSeg", sender: nil)
                }
            }
        })
    }
    
   
    
}
extension UsersProductViewController : UICollectionViewDelegateFlowLayout {
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      
            let width = collectionView.bounds.width
            return CGSize(width: (width / 2) - 10, height: (width / 2) + 78)
       
    }
    
   
}

extension UsersProductViewController  : UICollectionViewDelegate, UICollectionViewDataSource {
    
  
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
    
            if products.count > 0 {
                self.noProductsAvailable.isHidden = true
            }
            else {
                self.noProductsAvailable.isHidden = false
            }
            
            return products.count
    
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
       
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "storeCell", for: indexPath) as? StoreCollectionViewCell {
                cell.mView.dropShadow()
                cell.mView.layer.cornerRadius = 12
                cell.storeImage.layer.cornerRadius = 12
                
                let product = self.products[indexPath.row]
                
                cell.storeName.text = product.title ?? ""
                cell.storeCategory.text = product.categoryName ?? ""
                
                if let sStoreImage = product.productImages!.first, !sStoreImage.isEmpty {
                    cell.storeImage.setImage(imageKey: sStoreImage, placeholder: "placeholder",width: 400, height: 400, shouldShowAnimationPlaceholder: true)
                }
                
                cell.cost.text = "AU$ \(product.cost ?? "")"
                
                let myGest = MyGesture(target: self, action: #selector(marketplaceCellClicked))
                myGest.index = indexPath.row
                cell.mView.addGestureRecognizer(myGest)
                
                return cell
            }
            return StoreCollectionViewCell()
        }
        
}

extension UsersProductViewController : ProductDelegate {
    func updateProduct(productModel: MarketplaceModel, position: Int) {
        self.products.remove(at: position)
        self.products.insert(productModel, at: position)
        self.storeCollectionView.reloadData()
    }
    
    func addProduct(productModel: MarketplaceModel) {
        products.append(productModel)
        self.storeCollectionView.reloadData()
    }
    
    func removeProduct(productModel: MarketplaceModel) {
        products.remove(productModel)
        self.storeCollectionView.reloadData()
    }
    
    
}
