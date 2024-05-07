//
//  TickerRepository.swift
//  Tradernet
//
//  Created by Alexander Karpenko on 06.05.2024.
//

import Foundation

final class TickerRepository: TickerRepositoryContract {
    private let networkManager: TickerProvider
    private weak var quotesRepository: QuotesRepositoryContract?

    init(networkManager: TickerProvider, quotesRepository: QuotesRepositoryContract?) {
        self.networkManager = networkManager
        self.quotesRepository = quotesRepository
    }

    func fetchTickers(completion: @escaping (Result<[String], Error>) -> Void) {
        networkManager.fetchTickers(exchange: "russia", limit: 30, completion: completion)
    }

    func saveTicker(_ ticker: String) {
        quotesRepository?.save(tickers: [ticker])
        quotesRepository?.subscribeToSavedQuotes()
    }
}
