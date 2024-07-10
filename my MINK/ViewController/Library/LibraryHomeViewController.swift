//
//  LibraryHomeViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 08/07/24.
//

import UIKit

import MediaPlayer

class LibraryHomeViewController : UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var searchBtn: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    var bookModels = Array<BookResult>()
    var useBookModels = Array<BookResult>()
    
    @IBOutlet weak var no_results_found: UILabel!
    override func viewDidLoad() {
        
        
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        searchBtn.layer.cornerRadius = 8
        searchBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(searchBtnClicked)))
        
        searchTF.delegate = self
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        let flowLayout = UICollectionViewFlowLayout()
        let width = self.collectionView.bounds.width
        flowLayout.itemSize = CGSize(width: (width / 3) - 5, height: (width / 2) - 5)
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.vertical
        flowLayout.minimumInteritemSpacing = 0
        self.collectionView.collectionViewLayout = flowLayout
        
        self.ProgressHUDHide()
        self.ProgressHUDShow(text: "")
        
        self.getMostPopularBooks { bookModel, error in
            
            DispatchQueue.main.async {
                self.ProgressHUDHide()
                self.bookModels.removeAll()
                self.useBookModels.removeAll()
                
                if let bookmodel = bookModel{
                    if let results = bookmodel.results, !results.isEmpty {
                        for book in results {
                           
                            
                            self.bookModels.append(book)
                            self.useBookModels.append(book)
                        
                        }
              
                    }
                   
                }
                self.collectionView.reloadData()
            }
          
        }
    }
    
    
  
    
    @objc func cellClicked(gest : MyGesture){
        
        openBookTapped(url: self.useBookModels[gest.index].formats!.applicationEpubZip!)
    
    }
    
 

    @objc private func openBookTapped(url : String) {
           let epubURLString = url// Replace with your EPUB URL
           guard let epubURL = URL(string: epubURLString) else {
               print("Invalid EPUB URL")
               return
           }
           openBook(url: epubURL)
       }

       private func openBook(url: URL) {
           let bookViewController = BookViewController()
           bookViewController.epubURL = url
           let navigationController = UINavigationController(rootViewController: bookViewController)
           navigationController.modalPresentationStyle = .fullScreen // Set to full screen
           present(navigationController, animated: true, completion: nil)
       }
    
  
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    
    @objc func searchBtnClicked(){
        if let searchText = searchTF.text, !searchText.isEmpty {
            self.searchBook(searchText: searchText)
        }
    }
    
    func searchBook(searchText : String){
        self.ProgressHUDHide()
        ProgressHUDShow(text: "Searching...")
        self.searchBooks(bookName: searchText) { bookModel, error in
            DispatchQueue.main.async {
                self.ProgressHUDHide()
               
                self.useBookModels.removeAll()
                
                if let bookmodel = bookModel{
                    if let results = bookmodel.results, !results.isEmpty {
                        for book in results {
                           
                         
                            self.useBookModels.append(book)
                        
                        }

                    }
                   
                }
                
                
                self.collectionView.reloadData()
            }
        }
    }
}

extension LibraryHomeViewController : UICollectionViewDelegate, UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout
{
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let width = self.collectionView.bounds.width
        return CGSize(width: (width / 3) - 5, height: (width / 2) - 5)
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
       
        no_results_found.isHidden = useBookModels.count > 0 ? true : false
        
        return self.useBookModels.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "bookCell",
            for: indexPath
        ) as? BookLibraryCollectionViewCell {
            let bookModel = self.useBookModels[indexPath.row]
            
          
            let image = "https://www.gutenberg.org/cache/epub/\(bookModel.id ?? 0)/pg\(bookModel.id ?? 0).cover.medium.jpg"
            cell.mImage.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "placeholder"))
            
            cell.mImage.layer.cornerRadius = 6
            cell.mImage.dropShadow()
            cell.mImage.layoutIfNeeded()
            
            cell.layer.cornerRadius = 6
            
            cell.mImage.isUserInteractionEnabled = true
            let gest = MyGesture(target: self, action: #selector(cellClicked))
            gest.index  = indexPath.row
            cell.mImage.addGestureRecognizer(gest)
            
            return cell
        }

        return BookLibraryCollectionViewCell()
    }
}

extension LibraryHomeViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Get the current text, assuming it is a Swift string
        let currentText = textField.text ?? ""
        
        // Calculate the new text string after the change
        guard let stringRange = Range(range, in: currentText) else {
            return false
        }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // Check if the updated text is empty
        if updatedText.isEmpty {
            self.useBookModels.removeAll()
            self.useBookModels.append(contentsOf: self.bookModels)
            self.collectionView.reloadData()
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            if textField == searchTF {
                if let searchText = textField.text, !searchText.isEmpty {
                    self.searchBook(searchText: searchText)
                }
                else {
                    self.useBookModels.removeAll()
                    self.useBookModels.append(contentsOf: self.bookModels)
                    self.collectionView.reloadData()
                }
               
            }
            return true
        }
}
