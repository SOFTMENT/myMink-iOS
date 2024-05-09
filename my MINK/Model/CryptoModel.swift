// Copyright © 2023 SOFTMENT. All rights reserved.

import Foundation

// MARK: - CryptoModelElement

class CryptoModelElement: Codable {
    // MARK: Lifecycle

    init(
        id: String?,
        symbol: String?,
        name: String?,
        image: String?,
        currentPrice: Double?,
        marketCap: Int?,
        marketCapRank: Int?,
        fullyDilutedValuation: Int?,
        totalVolume: Double?,
        high24H: Double?,
        low24H: Double?,
        priceChange24H: Double?,
        priceChangePercentage24H: Double?,
        marketCapChange24H: Double?,
        marketCapChangePercentage24H: Double?,
        circulatingSupply: Double?,
        totalSupply: Double?,
        maxSupply: Double?,
        ath: Double?,
        athChangePercentage: Double?,
        athDate: String?,
        atl: Double?,
        atlChangePercentage: Double?,
        atlDate: String?,
        roi: Roi?,
        lastUpdated: String?
    ) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.image = image
        self.currentPrice = currentPrice
        self.marketCap = marketCap
        self.marketCapRank = marketCapRank
        self.fullyDilutedValuation = fullyDilutedValuation
        self.totalVolume = totalVolume
        self.high24H = high24H
        self.low24H = low24H
        self.priceChange24H = priceChange24H
        self.priceChangePercentage24H = priceChangePercentage24H
        self.marketCapChange24H = marketCapChange24H
        self.marketCapChangePercentage24H = marketCapChangePercentage24H
        self.circulatingSupply = circulatingSupply
        self.totalSupply = totalSupply
        self.maxSupply = maxSupply
        self.ath = ath
        self.athChangePercentage = athChangePercentage
        self.athDate = athDate
        self.atl = atl
        self.atlChangePercentage = atlChangePercentage
        self.atlDate = atlDate
        self.roi = roi
        self.lastUpdated = lastUpdated
    }

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case id
        case symbol
        case name
        case image
        case currentPrice = "current_price"
        case marketCap = "market_cap"
        case marketCapRank = "market_cap_rank"
        case fullyDilutedValuation = "fully_diluted_valuation"
        case totalVolume = "total_volume"
        case high24H = "high_24h"
        case low24H = "low_24h"
        case priceChange24H = "price_change_24h"
        case priceChangePercentage24H = "price_change_percentage_24h"
        case marketCapChange24H = "market_cap_change_24h"
        case marketCapChangePercentage24H = "market_cap_change_percentage_24h"
        case circulatingSupply = "circulating_supply"
        case totalSupply = "total_supply"
        case maxSupply = "max_supply"
        case ath
        case athChangePercentage = "ath_change_percentage"
        case athDate = "ath_date"
        case atl
        case atlChangePercentage = "atl_change_percentage"
        case atlDate = "atl_date"
        case roi
        case lastUpdated = "last_updated"
    }

    var id, symbol, name: String?
    var image: String?
    var currentPrice: Double?
    var marketCap, marketCapRank: Int?
    var fullyDilutedValuation: Int?
    var totalVolume: Double?
    var high24H, low24H, priceChange24H, priceChangePercentage24H: Double?
    var marketCapChange24H, marketCapChangePercentage24H: Double?
    var circulatingSupply: Double?
    var totalSupply, maxSupply: Double?
    var ath, athChangePercentage: Double?
    var athDate: String?
    var atl, atlChangePercentage: Double?
    var atlDate: String?
    var roi: Roi?
    var lastUpdated: String?
}

// MARK: - Roi

class Roi: Codable {
    // MARK: Lifecycle

    init(times: Double?, currency: Currency?, percentage: Double?) {
        self.times = times
        self.currency = currency
        self.percentage = percentage
    }

    // MARK: Internal

    var times: Double?
    var currency: Currency?
    var percentage: Double?
}

// MARK: - Currency

enum Currency: String, Codable {
    case btc
    case eth
    case usd
}

typealias CryptoModel = [CryptoModelElement]
