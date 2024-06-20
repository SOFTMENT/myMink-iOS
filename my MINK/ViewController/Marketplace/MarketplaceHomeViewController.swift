//
//  MarketplaceHomeViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 14/03/24.
//

import UIKit

class MarketplaceHomeViewController : UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var searchBtn: UIView!
    @IBOutlet weak var myStoreView: UIButton!
    
    @IBOutlet weak var storeCollectionView: UICollectionView!
    
    
    @IBOutlet weak var noProductsAvailable: UILabel!
    @IBOutlet weak var searchTF: UITextField!
    var selectedIndex = 0
    var categories = [String]()
    var products = Array<MarketplaceModel>()
    var useProducts = Array<MarketplaceModel>()
    override func viewDidLoad() {
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        collectionView.showsHorizontalScrollIndicator = false
        
        searchBtn.layer.cornerRadius = 8
        
        categories.append(contentsOf: Constants.product_categories)
        categories.insert("All", at: 0)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        myStoreView.layer.cornerRadius = 8
        myStoreView.dropShadow()

        storeCollectionView.delegate = self
        storeCollectionView.dataSource = self
        let flowLayout = UICollectionViewFlowLayout()
        let width = self.storeCollectionView.bounds.width
        flowLayout.itemSize = CGSize(width: ( width / CGFloat(2)) , height: CGFloat((width / CGFloat(2)) + 78))
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.vertical
        flowLayout.minimumInteritemSpacing = 0
        self.storeCollectionView.collectionViewLayout = flowLayout
        
        self.ProgressHUDShow(text: "")
        
        
       let region = getCountryCode()
        
        getAllMarketplaceProducts(countryCode: region) { products, error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error)
            }
            else {
                self.products.removeAll()
                self.useProducts.removeAll()
                self.useProducts.append(contentsOf: products ?? [])
                self.products.append(contentsOf: products ?? [])
                self.storeCollectionView.reloadData()
            }
        }
        
    }
    
    @IBAction func myStoreClicked(_ sender: Any) {
            performSegue(withIdentifier: "myStoreSeg", sender: nil)
    }
    
    @objc func marketplaceCellClicked(value : MyGesture) {
  
        performSegue(withIdentifier: "productDetailSeg", sender: useProducts[value.index])

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "productDetailSeg" {
            if let VC = segue.destination as? ShowProductDetailsViewController {
                if let product = sender as? MarketplaceModel {
                    VC.product = product
                }
            }
        }
    }
    
    @objc func categoryCellSelected(value : MyGesture){
        selectedIndex = value.index
        
        self.useProducts.removeAll()
        
        if selectedIndex == 0 {
           
            self.useProducts.append(contentsOf: products)
            
        }
        else {
            self.useProducts.append(contentsOf: products.filter { $0.categoryName!.lowercased() == self.categories[selectedIndex].lowercased()})
        }
        self.collectionView.reloadData()
        self.storeCollectionView.reloadData()
    }
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    @IBOutlet weak var searchBtnClicked: UIView!
    
}
extension MarketplaceHomeViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
      
 
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
      
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == storeCollectionView {
            let width = collectionView.bounds.width
            return CGSize(width: (width / 2) - 10, height: (width / 2) + 78)
        }
        else {
            let size = collectionView.frame.size
            return CGSize(width: size.width, height: size.height)
        }
    }
    
   
}

extension MarketplaceHomeViewController : UICollectionViewDelegate, UICollectionViewDataSource {
  
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == storeCollectionView {
            
            self.noProductsAvailable.isHidden = useProducts.count > 0 ? true : false
            
            
            return useProducts.count
        }
        else {
            return categories.count
        }
      
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      
        if collectionView == storeCollectionView {
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "storeCell", for: indexPath) as? StoreCollectionViewCell {
                cell.mView.dropShadow()
                cell.mView.layer.cornerRadius = 12
                cell.storeImage.layer.cornerRadius = 12
                
                let product = self.useProducts[indexPath.row]
        
                cell.storeName.text = product.title ?? ""
                cell.storeCategory.text = product.categoryName ?? ""
                cell.cost.text = "\(product.currency ?? "AUD") \(product.cost ?? "")"
                if let sStoreImage = product.productImages!.first, !sStoreImage.isEmpty {
                    cell.storeImage.setImage(imageKey: sStoreImage, placeholder: "placeholder",width: 400, height: 400,shouldShowAnimationPlaceholder: true)
                }
                
                let myGest = MyGesture(target: self, action: #selector(marketplaceCellClicked))
                myGest.index = indexPath.row
                cell.mView.addGestureRecognizer(myGest)
                
                return cell
            }
            return StoreCollectionViewCell()
        }
        else {
            
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productCell", for: indexPath) as? ProductCategoryCell {
                    
                    
                    let title = categories[indexPath.row]
                    cell.categoryBtn.setTitle(title, for: .normal)
                    cell.categoryBtn.layer.cornerRadius = 8
                    
                    cell.categoryBtn.isUserInteractionEnabled = true
                    let gest = MyGesture(target: self, action: #selector(categoryCellSelected))
                    gest.index = indexPath.row
                    cell.categoryBtn.addGestureRecognizer(gest)
                    
                    if self.selectedIndex == indexPath.row {
                        cell.categoryBtn.backgroundColor = UIColor(red: 210/255, green: 0/255, blue: 1/255, alpha: 1)
                        cell.categoryBtn.setTitleColor(UIColor.white, for: .normal)
                        
                    }
                    else {
                        cell.categoryBtn.backgroundColor = UIColor.clear
                        cell.categoryBtn.layer.borderColor = UIColor.lightGray.cgColor
                        cell.categoryBtn.layer.borderWidth = 0.5
                        cell.categoryBtn.setTitleColor(UIColor.black, for: .normal)
                    }
                    
                    return cell
                }
                return ProductCategoryCell()
           
        }
        
    
    }
    
}
