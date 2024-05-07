//
//  TickersViewContract.swift
//  Tradernet
//
//  Created by Alexander Karpenko on 06.05.2024.
//

import Foundation

protocol TickersViewContract: AnyObject {
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showTickers(_ tickers: [String])
    func showError(message: String)
}
