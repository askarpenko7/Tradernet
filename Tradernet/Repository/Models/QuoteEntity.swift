//
//  QuoteEntity.swift
//  Tradernet
//
//  Created by Alexander Karpenko on 03.05.2024.
//

import Foundation

struct QuoteEntity {
    /// c (String): The stock ticker symbol.
    let ticker: String

    /// name (String): The name of the security.
    let name: String?

    /// pcp (Double): Percentage change relative to the closing price of the previous trading session.
    let percentageChangeFromPreviousClose: Double?

    /// ltr (String): The exchange of the latest trade.
    let latestTradeExchange: String?

    /// ltp (Double): Last trade price.
    let lastTradePrice: Double?

    /// chg (Double): Change in the price of the last trade in points.
    let priceChangePoints: Double?
    
    /// Minimum price increment
    let minStep: Double?

    internal init(
        ticker: String,
        name: String? = nil,
        percentageChangeFromPreviousClose: Double? = nil,
        latestTradeExchange: String? = nil,
        lastTradePrice: Double? = nil,
        priceChangePoints: Double? = nil,
        minStep: Double? = nil
    ) {
        self.ticker = ticker
        self.name = name
        self.percentageChangeFromPreviousClose = percentageChangeFromPreviousClose
        self.latestTradeExchange = latestTradeExchange
        self.lastTradePrice = lastTradePrice
        self.priceChangePoints = priceChangePoints
        self.minStep = minStep
    }
}
