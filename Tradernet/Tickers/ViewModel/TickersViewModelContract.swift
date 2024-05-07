//
//  TickersViewModelContract.swift
//  Tradernet
//
//  Created by Alexander Karpenko on 06.05.2024.
//

import Foundation

protocol TickersViewModelContract: AnyObject {
    var view: TickersViewContract? { get set }
    var tickers: [String] { get }

    func fetchTickers()
    func saveTicker(at position: Int)
}
