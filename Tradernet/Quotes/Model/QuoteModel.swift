//
//  QuoteModel.swift
//  Tradernet
//
//  Created by Alexander Karpenko on 05.05.2024.
//

import Foundation

struct QuoteModel {
    /// c (String): The stock ticker symbol.
    let ticker: String

    /// name (String): The name of the security.
    let name: String

    /// pcp (Double): Percentage change relative to the closing price of the previous trading session.
    let percentageChangeFromPreviousClose: Double

    /// ltr (String): The exchange of the latest trade.
    let latestTradeExchange: String

    /// ltp (Double): Last trade price.
    let lastTradePrice: Double

    /// chg (Double): Change in the price of the last trade in points.
    let priceChangePoints: Double

    /// Helps to determine direction of change comparing to previous value
    let percentageChangeDirection: PercentageChangeDirection

    /// Minimum price increment
    let minStep: Double

    var nameAndExchangeFormatted: String {
        String(format: "%@ | %@", latestTradeExchange, name)
    }

    var lastTradeFormatted: String {
        String(
            format: "%@ ( %@ )",
            roundAndFormat(value: lastTradePrice, minStep: minStep),
            roundAndFormat(value: priceChangePoints, minStep: minStep)
        )
    }

    var percentViewStyle: PercentView.Style {
        percentageChangeFromPreviousClose > 0 ? .positive : percentageChangeFromPreviousClose < 0 ? .negative : .neutral
    }

    var percentageChangeFormatted: String {
        String(format: "%.2f%%", percentageChangeFromPreviousClose)
    }

    init(from quote: QuoteMO) {
        self.ticker = quote.ticker ?? LocalizedString.unknown.localized
        self.name = quote.name ?? LocalizedString.unknown.localized
        self.percentageChangeFromPreviousClose = quote.percentageChangeFromPreviousClose
        self.latestTradeExchange = quote.latestTradeExchange ?? LocalizedString.unknown.localized
        self.lastTradePrice = quote.lastTradePrice
        self.priceChangePoints = quote.priceChangePoints
        self.percentageChangeDirection = PercentageChangeDirection(rawValue: quote.percentageChangeDirection)
        self.minStep = quote.minStep
    }

    ///// Determine the number of decimal places based on the minimum step
    private func decimalPlaces(from minStep: Double) -> Int {
        if minStep == 0 {
            return 0
        } else if minStep.remainder(dividingBy: 1) == 0 {
            return 0
        } else if minStep.description.contains("e-") {
            if let range = minStep.description.range(of: "e-") {
                return Int(minStep.description[range.upperBound...]) ?? 0
            }
            return 0
        } else {
            let parts = minStep.description.components(separatedBy: ".")
            return parts.count > 1 ? parts[1].count : 0
        }
    }

    /// Format the value based on the determined number of decimal places
    private func roundAndFormat(value: Double, minStep: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.decimalSeparator = "."
        let decimals = decimalPlaces(from: minStep)
        formatter.minimumFractionDigits = decimals
        formatter.maximumFractionDigits = decimals

        if let formattedString = formatter.string(from: NSNumber(value: value)) {
            return formattedString
        } else {
            return "\(value)"
        }
    }
}

extension QuoteModel {
    enum PercentageChangeDirection {
        case none
        case up
        case down

        init(rawValue: String?) {
            switch rawValue {
            case "none":
                self = .none
            case "up":
                self = .up
            case "down":
                self = .down
            default:
                self = .none
            }
        }
    }
}
