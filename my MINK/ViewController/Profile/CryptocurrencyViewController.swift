// Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit

// MARK: - CryptocurrencyViewController

class CryptocurrencyViewController: UIViewController {
    @IBOutlet var backView: UIView!

    @IBOutlet var priceName: UILabel!
    @IBOutlet var pricePicker: UIView!
    @IBOutlet var tableView: UITableView!
    var cryptoModel = CryptoModel()
    var filter = CryptoModel()
    @IBOutlet var searchTF: UITextField!

    override func viewDidLoad() {
        self.backView.isUserInteractionEnabled = true
        self.backView.dropShadow()
        self.backView.layer.cornerRadius = 8
        self.backView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.backViewClicked)
        ))

        ProgressHUDShow(text: "")

        self.getCrypto(currency: "aud")

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.pricePicker.isUserInteractionEnabled = true
        self.pricePicker.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.pricePickerClicked)
        ))

        self.searchTF.delegate = self

        self.searchTF.setLeftIcons(icon: UIImage(systemName: "magnifyingglass")!)
    }

    func getCrypto(currency: String) {
        getAllCryptoAssets(currency: currency) { cryptoModel, error in
            DispatchQueue.main.async {
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error)
                } else {
                    self.cryptoModel.removeAll()
                    self.filter.removeAll()
                    if let cryptoModel = cryptoModel {
                        self.cryptoModel.append(contentsOf: cryptoModel)
                        self.filter.append(contentsOf: cryptoModel)
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }

    @objc func pricePickerClicked() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "AUD", style: .default, handler: { _ in
            self.priceName.text = "AUD"
            self.getCrypto(currency: "aud")
        }))
        alert.addAction(UIAlertAction(title: "USD", style: .default, handler: { _ in
            self.priceName.text = "USD"
            self.getCrypto(currency: "usd")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    @objc func backViewClicked() {
        dismiss(animated: true)
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension CryptocurrencyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        self.filter.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: "cryptoCell",
            for: indexPath
        ) as? CryptoTableViewCell {
            let crypto = self.filter[indexPath.row]
            cell.mImage.sd_setImage(with: URL(string: crypto.image ?? ""), placeholderImage: UIImage(named: "dollar"))
            cell.mView.layer.cornerRadius = 8
            cell.mRankView.layer.cornerRadius = 2

            let priceChangePercentage24H = crypto.priceChangePercentage24H ?? 0
            if priceChangePercentage24H >= 0 {
                cell.upDownIcon.tintColor = UIColor(red: 33 / 255, green: 199 / 255, blue: 135 / 255, alpha: 1)
                cell.change24Hours.textColor = UIColor(red: 33 / 255, green: 199 / 255, blue: 135 / 255, alpha: 1)
                cell.upDownIcon.image = UIImage(systemName: "chevron.up.circle.fill")
            } else {
                cell.upDownIcon.tintColor = UIColor.red
                cell.change24Hours.textColor = UIColor.red
                cell.upDownIcon.image = UIImage(systemName: "chevron.down.circle.fill")
            }

            cell.change24Hours.text = "\(String(format: "%.1f", priceChangePercentage24H))%"
            cell.mName.text = crypto.name ?? "Bitcoin"
            cell.mRank.text = "\(crypto.marketCapRank ?? 1)"
            cell.mSymbol.text = (crypto.symbol ?? "BTC").uppercased()
            cell.mPrice
                .text =
                "\(addCommaInLargeNumber(largeNumber: crypto.currentPrice ?? 0.0)!) \(self.priceName.text ?? "AUD")"
            cell.mMarketPrice
                .text =
                "\(addCommaInLargeNumber(largeNumber: Double(crypto.marketCap ?? Int(0.0)))!) \(self.priceName.text ?? "AUD")"
            return cell
        }
        return CryptoTableViewCell()
    }
}

extension CryptocurrencyViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let searchText = textField.text, !searchText.isEmpty {
            self.filter = self.cryptoModel.filter { cryptoModel in
                let searchTextLowercased = searchText.lowercased()
                if let name = cryptoModel.name?.lowercased(), name.contains(searchTextLowercased) {
                    return true
                }
                if let symbol = cryptoModel.symbol?.lowercased(), symbol.contains(searchTextLowercased) {
                    return true
                }
                return false
            }

        } else {
            self.filter = self.cryptoModel
        }
        self.tableView.reloadData()
    }
}
