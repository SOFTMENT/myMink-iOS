//
//  MarketplaceHomeViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 14/03/24.
//

import UIKit

class MarketplaceHomeViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var searchBtn: UIView!
    @IBOutlet weak var myStoreView: UIButton!
    @IBOutlet weak var storeCollectionView: UICollectionView!
    @IBOutlet weak var noProductsAvailable: UILabel!
    @IBOutlet weak var searchTF: UITextField!
    
    var selectedIndex = 0
    var categories = [String]()
    var products = [MarketplaceModel]()
    var useProducts = [MarketplaceModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupDelegates()
        setupGestures()
        
        categories.append(contentsOf: Constants.productCategories)
        categories.insert("All", at: 0)
        
        fetchMarketplaceProducts()
    }
    
    private func setupViews() {
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        
        collectionView.showsHorizontalScrollIndicator = false
        
        searchBtn.layer.cornerRadius = 8
        
        myStoreView.layer.cornerRadius = 8
        myStoreView.dropShadow()
        
        setupStoreCollectionViewLayout()
    }
    
    private func setupStoreCollectionViewLayout() {
        let flowLayout = UICollectionViewFlowLayout()
        let width = storeCollectionView.bounds.width
        flowLayout.itemSize = CGSize(width: width / 2 - 10, height: (width / 2) + 78)
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = 0
        storeCollectionView.collectionViewLayout = flowLayout
    }
    
    private func setupDelegates() {
        searchTF.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        storeCollectionView.delegate = self
        storeCollectionView.dataSource = self
    }
    
    private func setupGestures() {
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        searchBtn.isUserInteractionEnabled = true
        searchBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(searchBtnClicked)))
    }
    
    private func fetchMarketplaceProducts() {
        ProgressHUDShow(text: "")
        let region = getCountryCode()
        getAllMarketplaceProducts(countryCode: region) { products, error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error)
            } else {
                self.products = products ?? []
                self.useProducts = self.products
                self.storeCollectionView.reloadData()
            }
        }
    }
    
    @objc private func searchBtnClicked() {
        if let searchText = searchTF.text, !searchText.isEmpty {
            searchProducts(searchText: searchText)
        }
    }
    
    private func searchProducts(searchText: String) {
        ProgressHUDShow(text: "Searching...")
        let region = getCountryCode()
        algoliaSearch(searchText: searchText, indexName: .marketplace, filters: "isActive:true AND countryCode:\(region)") { models in
            DispatchQueue.main.async {
                self.ProgressHUDHide()
                self.useProducts = models as? [MarketplaceModel] ?? []
                self.storeCollectionView.reloadData()
            }
        }
    }
    
    @IBAction private func myStoreClicked(_ sender: Any) {
        performSegue(withIdentifier: "myStoreSeg", sender: nil)
    }
    
    @objc private func marketplaceCellClicked(value: MyGesture) {
        performSegue(withIdentifier: "productDetailSeg", sender: useProducts[value.index])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "productDetailSeg", let VC = segue.destination as? ShowProductDetailsViewController, let product = sender as? MarketplaceModel {
            VC.product = product
        }
    }
    
    @objc private func categoryCellSelected(value: MyGesture) {
        selectedIndex = value.index
        useProducts = selectedIndex == 0 ? products : products.filter { $0.categoryName?.lowercased() == categories[selectedIndex].lowercased() }
        collectionView.reloadData()
        storeCollectionView.reloadData()
    }
    
    @objc private func backViewClicked() {
        self.dismiss(animated: true)
    }
}

extension MarketplaceHomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == storeCollectionView {
            let width = collectionView.bounds.width
            return CGSize(width: (width / 2) - 10, height: (width / 2) + 78)
        } else {
            let size = collectionView.frame.size
            return CGSize(width: size.width, height: size.height)
        }
    }
}

extension MarketplaceHomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == storeCollectionView {
            noProductsAvailable.isHidden = !useProducts.isEmpty
            return useProducts.count
        } else {
            return categories.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == storeCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "storeCell", for: indexPath) as? StoreCollectionViewCell else {
                return StoreCollectionViewCell()
            }
            configureStoreCell(cell, at: indexPath)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productCell", for: indexPath) as? ProductCategoryCell else {
                return ProductCategoryCell()
            }
            configureProductCell(cell, at: indexPath)
            return cell
        }
    }
    
    private func configureStoreCell(_ cell: StoreCollectionViewCell, at indexPath: IndexPath) {
        let product = useProducts[indexPath.row]
        cell.mView.dropShadow()
        cell.mView.layer.cornerRadius = 12
        cell.storeImage.layer.cornerRadius = 12
        cell.storeName.text = product.title
        cell.storeCategory.text = product.categoryName
        cell.cost.text = "\(getCurrencyCode(forRegion: Locale.current.regionCode!) ?? "AU") \(String(format: "%.2f", Double(product.cost ?? "0")!))"
        if let sStoreImage = product.productImages?.first, !sStoreImage.isEmpty {
            cell.storeImage.setImage(imageKey: sStoreImage, placeholder: "placeholder", width: 400, height: 400, shouldShowAnimationPlaceholder: true)
        }
        let myGest = MyGesture(target: self, action: #selector(marketplaceCellClicked))
        myGest.index = indexPath.row
        cell.mView.addGestureRecognizer(myGest)
    }
    
    private func configureProductCell(_ cell: ProductCategoryCell, at indexPath: IndexPath) {
        let title = categories[indexPath.row]
        cell.categoryBtn.setTitle(title, for: .normal)
        cell.categoryBtn.layer.cornerRadius = 8
        let gest = MyGesture(target: self, action: #selector(categoryCellSelected))
        gest.index = indexPath.row
        cell.categoryBtn.addGestureRecognizer(gest)
        if selectedIndex == indexPath.row {
            cell.categoryBtn.backgroundColor = UIColor(red: 210/255, green: 0/255, blue: 1/255, alpha: 1)
            cell.categoryBtn.setTitleColor(UIColor.white, for: .normal)
        } else {
            cell.categoryBtn.backgroundColor = UIColor.clear
            cell.categoryBtn.layer.borderColor = UIColor.lightGray.cgColor
            cell.categoryBtn.layer.borderWidth = 0.5
            cell.categoryBtn.setTitleColor(UIColor.black, for: .normal)
        }
    }
}

extension MarketplaceHomeViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text, let rangeOfTextToReplace = Range(range, in: textFieldText) else {
            return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        if count == 0 {
            useProducts = products
            storeCollectionView.reloadData()
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchTF, let searchText = textField.text, !searchText.isEmpty {
            searchProducts(searchText: searchText)
        } else {
            useProducts = products
            storeCollectionView.reloadData()
        }
        return true
    }
}
