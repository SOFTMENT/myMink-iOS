//
//  LibraryHomeViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 08/07/24.
//

import UIKit
import MediaPlayer

class LibraryHomeViewController: UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var searchBtn: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var bookModels = [BookResult]()
    var useBookModels = [BookResult]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchMostPopularBooks()
    }
    
    private func setupUI() {
        setupBackView()
        setupSearchButton()
        setupSearchTextField()
        setupCollectionView()
    }
    
    private func setupBackView() {
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
    }
    
    private func setupSearchButton() {
        searchBtn.layer.cornerRadius = 8
        searchBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(searchBtnClicked)))
    }
    
    private func setupSearchTextField() {
        searchTF.delegate = self
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        let flowLayout = UICollectionViewFlowLayout()
        let width = collectionView.bounds.width
        flowLayout.itemSize = CGSize(width: (width / 3) - 5, height: (width / 2) - 5)
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = 0
        collectionView.collectionViewLayout = flowLayout
    }
    
    private func fetchMostPopularBooks() {
        ProgressHUDShow(text: "")
        getMostPopularBooks { [weak self] bookModel, error in
            DispatchQueue.main.async {
                self?.ProgressHUDHide()
                self?.handleBookFetchResponse(bookModel: bookModel)
            }
        }
    }
    
    private func handleBookFetchResponse(bookModel: BookModel?) {
        bookModels.removeAll()
        useBookModels.removeAll()
        
        if let results = bookModel?.results, !results.isEmpty {
            bookModels.append(contentsOf: results)
            useBookModels.append(contentsOf: results)
        }
        collectionView.reloadData()
    }
    
    @objc private func backViewClicked() {
        dismiss(animated: true)
    }
    
    @objc private func searchBtnClicked() {
        if let searchText = searchTF.text, !searchText.isEmpty {
            searchBook(searchText: searchText)
        }
    }
    
    private func searchBook(searchText: String) {
        ProgressHUDShow(text: "Searching...".localized())
        searchBooks(bookName: searchText) { [weak self] bookModel, error in
            DispatchQueue.main.async {
                self?.ProgressHUDHide()
                self?.handleBookFetchResponse(bookModel: bookModel)
            }
        }
    }
    
    @objc private func cellClicked(gesture: MyGesture) {
        openBookTapped(url: useBookModels[gesture.index].formats?.applicationEpubZip ?? "")
    }
    
    @objc private func openBookTapped(url: String) {
        guard let epubURL = URL(string: url) else {
            print("Invalid EPUB URL".localized())
            return
        }
        openBook(url: epubURL)
    }
    
    private func openBook(url: URL) {
        let bookViewController = BookViewController()
        bookViewController.epubURL = url
        let navigationController = UINavigationController(rootViewController: bookViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
}

extension LibraryHomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        return CGSize(width: (width / 3) - 5, height: (width / 2) - 5)
    }
    
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
    
        return useBookModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bookCell", for: indexPath) as? BookLibraryCollectionViewCell {
            let bookModel = useBookModels[indexPath.row]
            let imageUrl = "https://www.gutenberg.org/cache/epub/\(bookModel.id ?? 0)/pg\(bookModel.id ?? 0).cover.medium.jpg"
            
            cell.mImage.setImageOther(imageURL: imageUrl, placeholder: "placeholder",shouldShowAnimationPlaceholder: true)
            
            cell.mImage.layer.cornerRadius = 6
            cell.mImage.dropShadow()
            cell.mImage.isUserInteractionEnabled = true
            let gest = MyGesture(target: self, action: #selector(cellClicked))
            gest.index = indexPath.row
            cell.mImage.addGestureRecognizer(gest)
            cell.layer.cornerRadius = 8
            return cell
        }
        return BookLibraryCollectionViewCell()
    }
}

extension LibraryHomeViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text else { return false }
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if updatedText.isEmpty {
            useBookModels = bookModels
            collectionView.reloadData()
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchTF, let searchText = textField.text, !searchText.isEmpty {
            searchBook(searchText: searchText)
        } else {
            useBookModels = bookModels
            collectionView.reloadData()
        }
        return true
    }
}
