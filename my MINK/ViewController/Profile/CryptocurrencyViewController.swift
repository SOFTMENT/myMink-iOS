// Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit

// MARK: - CryptocurrencyViewController

class CryptocurrencyViewController: UIViewController {
    @IBOutlet var backView: UIView!
    @IBOutlet var priceName: UILabel!
    @IBOutlet var pricePicker: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchTF: UITextField!

    var cryptoModel: [CryptoModelElement] = []
    var filter: [CryptoModelElement] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupDelegates()
        fetchCrypto(currency: "aud")
    }

    private func setupViews() {
        backView.isUserInteractionEnabled = true
        backView.dropShadow()
        backView.layer.cornerRadius = 8
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))

        pricePicker.isUserInteractionEnabled = true
        pricePicker.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pricePickerClicked)))

        searchTF.setLeftIcons(icon: UIImage(systemName: "magnifyingglass")!)
    }

    private func setupDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
        searchTF.delegate = self
    }

    private func fetchCrypto(currency: String) {
        ProgressHUDShow(text: "")
        getAllCryptoAssets(currency: currency) { [weak self] cryptoModel, error in
            DispatchQueue.main.async {
                self?.ProgressHUDHide()
                if let error = error {
                    self?.showError(error)
                } else if let cryptoModel = cryptoModel {
                    self?.cryptoModel = cryptoModel
                    self?.filter = cryptoModel
                    self?.tableView.reloadData()
                }
            }
        }
    }

    @objc private func pricePickerClicked() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "AUD", style: .default) { _ in
            self.priceName.text = "AUD"
            self.fetchCrypto(currency: "aud")
        })
        alert.addAction(UIAlertAction(title: "USD", style: .default) { _ in
            self.priceName.text = "USD"
            self.fetchCrypto(currency: "usd")
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func backViewClicked() {
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension CryptocurrencyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return filter.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cryptoCell", for: indexPath) as? CryptoTableViewCell else {
            return CryptoTableViewCell()
        }

        let crypto = filter[indexPath.row]
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
        cell.mPrice.text = "\(addCommaInLargeNumber(largeNumber: crypto.currentPrice ?? 0.0)!) \(priceName.text ?? "AUD")"
        cell.mMarketPrice.text = "\(addCommaInLargeNumber(largeNumber: Double(crypto.marketCap ?? Int(0.0)))!) \(priceName.text ?? "AUD")"
        return cell
    }
}

// MARK: - UITextFieldDelegate

extension CryptocurrencyViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let searchText = textField.text?.lowercased(), !searchText.isEmpty else {
            filter = cryptoModel
            tableView.reloadData()
            return
        }

        filter = cryptoModel.filter { crypto in
            let nameMatches = crypto.name?.lowercased().contains(searchText) ?? false
            let symbolMatches = crypto.symbol?.lowercased().contains(searchText) ?? false
            return nameMatches || symbolMatches
        }
        tableView.reloadData()
    }
}
