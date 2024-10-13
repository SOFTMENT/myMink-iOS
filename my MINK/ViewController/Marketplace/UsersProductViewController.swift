//
//  UsersProductViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 15/04/24.
//

import UIKit



class UsersProductViewController: UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var addView: UIView!
    @IBOutlet weak var storeCollectionView: UICollectionView!
    @IBOutlet weak var noProductsAvailable: UILabel!
   
    var products = [MarketplaceModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchProducts()
    }
    
    private func setupViews() {
        setupBackView()
        setupAddView()
        setupCollectionView()
    }
    
    private func setupBackView() {
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
    }
    
    private func setupAddView() {
        addView.layer.cornerRadius = 8
        addView.dropShadow()
        addView.isUserInteractionEnabled = true
        addView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addViewClicked)))
    }
    
    private func setupCollectionView() {
        storeCollectionView.delegate = self
        storeCollectionView.dataSource = self
        let flowLayout = UICollectionViewFlowLayout()
        let width = self.storeCollectionView.bounds.width
        flowLayout.itemSize = CGSize(width: (width / 2) - 10, height: (width / 2) + 78)
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = 0
        self.storeCollectionView.collectionViewLayout = flowLayout
    }
    
    private func fetchProducts() {
        self.ProgressHUDShow(text: "")
        getMarketplaceProductsBy(uid: FirebaseStoreManager.auth.currentUser!.uid) { products, error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error)
            } else {
                self.products = products ?? []
                self.storeCollectionView.reloadData()
            }
        }
    }
    
    @objc private func addViewClicked() {
       performSegue(withIdentifier: "addProductSeg", sender: nil)
    }
    
    @objc private func marketplaceCellClicked(value: MyGesture) {
        performSegue(withIdentifier: "editProductSeg", sender: value.index)
    }
    
    @objc private func backViewClicked() {
        self.dismiss(animated: true)
    }
    
  
    
   
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editProductSeg", let VC = segue.destination as? EditProductViewController, let position = sender as? Int {
            VC.product = self.products[position]
            VC.position = position
           
        }
    }
}

extension UsersProductViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        return CGSize(width: (width / 2) - 10, height: (width / 2) + 78)
    }
}

extension UsersProductViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.noProductsAvailable.isHidden = products.count > 0
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "storeCell", for: indexPath) as? StoreCollectionViewCell else {
            return StoreCollectionViewCell()
        }
        configureCell(cell, indexPath: indexPath, with: products[indexPath.row])
        return cell
    }
    
    private func configureCell(_ cell: StoreCollectionViewCell, indexPath : IndexPath, with product: MarketplaceModel) {
        cell.mView.dropShadow()
        cell.mView.layer.cornerRadius = 12
        cell.storeImage.layer.cornerRadius = 12
        
        cell.storeName.text = product.title ?? ""
        cell.storeCategory.text = product.categoryName ?? ""
        
        if let sStoreImage = product.productImages?.first, !sStoreImage.isEmpty {
            cell.storeImage.setImage(imageKey: sStoreImage, placeholder: "placeholder", width: 400, height: 400, shouldShowAnimationPlaceholder: true)
        }
        
        cell.cost.text = "\(getCurrencyCode(forRegion: Locale.current.regionCode!) ?? "AU") \(String(format: "%.2f", Double(product.cost ?? "0")!))"
        
        let myGest = MyGesture(target: self, action: #selector(marketplaceCellClicked))
        myGest.index = indexPath.row
        cell.mView.addGestureRecognizer(myGest)
    }
}

