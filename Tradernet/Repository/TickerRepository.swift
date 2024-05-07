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
        if quotesRepository?.isConnected == false {
            quotesRepository?.connectToWebSocket(completion: { [weak self] result in
                switch result {
                case .success:
                    self?.quotesRepository?.subscribeToSavedQuotes()
                case let .failure(failure):
                    print(failure.localizedDescription)
                }
            })
        } else {
            quotesRepository?.subscribeToSavedQuotes()
        }
    }
}
