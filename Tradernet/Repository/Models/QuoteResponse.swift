//
//  QuoteResponse.swift
//  Tradernet
//
//  Created by Alexander Karpenko on 03.05.2024.
//

import Foundation

struct QuoteResponse: Codable {
    /// c (String): The stock ticker symbol.
    let ticker: String

    /// name (String): The name of the security.
    let name: String?

    /// pcp (Double): Percentage change relative to the closing price of the previous trading session.
    let percentageChangeFromPreviousClose: Double?

    /// ltr (String): The exchange of the latest trade.
    let latestTradeExchange: String? // Corrected type to String

    /// ltp (Double): Last trade price.
    let lastTradePrice: Double?

    /// chg (Double): Change in the price of the last trade in points.
    let priceChangePoints: Double?

    /// Minimum price increment
    let minStep: Double?

    enum CodingKeys: String, CodingKey {
        case ticker = "c"
        case name
        case percentageChangeFromPreviousClose = "pcp"
        case latestTradeExchange = "ltr"
        case lastTradePrice = "ltp"
        case priceChangePoints = "chg"
        case minStep = "min_step"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.ticker = try container.decode(String.self, forKey: .ticker)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.percentageChangeFromPreviousClose = try container.decodeIfPresent(
            Double.self,
            forKey: .percentageChangeFromPreviousClose
        )
        self.latestTradeExchange = try container.decodeIfPresent(String.self, forKey: .latestTradeExchange)
        self.lastTradePrice = try container.decodeIfPresent(Double.self, forKey: .lastTradePrice)
        self.priceChangePoints = try container.decodeIfPresent(Double.self, forKey: .priceChangePoints)
        self.minStep = try container.decodeIfPresent(Double.self, forKey: .minStep)
    }
}

extension QuoteEntity {
    init(from response: QuoteResponse) {
        ticker = response.ticker
        name = response.name
        percentageChangeFromPreviousClose = response.percentageChangeFromPreviousClose
        latestTradeExchange = response.latestTradeExchange
        lastTradePrice = response.lastTradePrice
        priceChangePoints = response.priceChangePoints
        minStep = response.minStep
    }
}
