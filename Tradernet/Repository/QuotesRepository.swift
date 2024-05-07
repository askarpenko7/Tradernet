//
//  QuotesRepository.swift
//  Tradernet
//
//  Created by Alexander Karpenko on 04.05.2024.
//

import CoreData
import Foundation

final class QuotesRepository {
    private var webSocketManager: QuotesWebSocketContract
    private let storageManager: QuotesStorageContract

    var onError: ((Error) -> Void)?

    init(
        webSocketManager: QuotesWebSocketContract,
        storageManager: QuotesStorageContract
    ) {
        self.webSocketManager = webSocketManager
        self.storageManager = storageManager

        self.webSocketManager.onError = { [weak self] error in
            self?.onError?(error)
        }
    }

    private func subscribe(to quotes: [String]) {
        webSocketManager.onReceivedData = { [weak self] data in
            self?.handleReceivedData(data)
        }
        webSocketManager.subscribe(to: quotes)
    }

    private func handleReceivedData(_ data: Data?) {
        guard let data = data, let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [Any],
              jsonArray.count >= 2,
              let eventType = jsonArray[0] as? String,
              eventType == "q",
              let quoteData = jsonArray[1] as? [String: Any],
              let quoteDataSerialized = try? JSONSerialization.data(withJSONObject: quoteData)
        else {
            onError?(DLError.unexpectedResponse)
            return
        }

        decodeAndSaveQuoteData(quoteDataSerialized)
    }

    private func decodeAndSaveQuoteData(_ data: Data) {
        let decoder = JSONDecoder()
        do {
            let quoteResponse = try decoder.decode(QuoteResponse.self, from: data)
            let entity = QuoteEntity(from: quoteResponse)
            processEntities([entity])
        } catch {
            onError?(error)
        }
    }

    private func processEntities(_ entities: [QuoteEntity]) {
        storageManager.processBatchUpdates(quotes: entities) { result in
            switch result {
            case .success:
                return
            case let .failure(failure):
                self.onError?(failure)
            }
        }
    }
}

// MARK: - Contract

extension QuotesRepository: QuotesRepositoryContract {
    func fetchQuotesController() -> NSFetchedResultsController<QuoteMO> {
        storageManager.fetchQuotesController()
    }

    func connectToWebSocket(completion: @escaping (Result<Void, Error>) -> Void) {
        var isCompleted = false // To guard against multiple completion calls

        webSocketManager.onConnected = {
            guard !isCompleted else { return }
            isCompleted = true

            completion(.success(()))
        }

        webSocketManager.onDisconnected = { error in
            guard !isCompleted else { return }
            isCompleted = true

            if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(NSError(
                    domain: "WebSocket",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "WebSocket instance was deallocated"]
                )))
            }
        }

        webSocketManager.connect()
    }

    func disconnect() {
        webSocketManager.disconnect()
    }

    func subscribeToSavedQuotes() {
        storageManager.fetchUniqueTickers { [weak self] result in
            switch result {
            case let .success(symbols):
                self?.subscribe(to: symbols)
            case .failure:
                self?.onError?(DLError.noSavedQuotes)
            }
        }
    }

    func saveOrUpdateQuote(quote: QuoteEntity) {
        storageManager.saveOrUpdateQuote(quote: quote) { [weak self] result in
            switch result {
            case .success:
                return
            case .failure:
                self?.onError?(DLError.savingOperationFail)
            }
        }
    }

    func save(tickers: [String]) {
        storageManager.save(tickers: tickers)
    }
    
    func delete(quote: QuoteMO) {
        storageManager.delete(quote: quote, completion: { result in
            switch result {
            case .success:
                self.subscribeToSavedQuotes()
            case .failure:
                self.onError?(DLError.savingOperationFail)
            }
        })
    }
}
