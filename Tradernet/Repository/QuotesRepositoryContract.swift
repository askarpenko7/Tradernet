//
//  QuotesRepositoryContract.swift
//  Tradernet
//
//  Created by Alexander Karpenko on 04.05.2024.
//

import CoreData
import Foundation

protocol QuotesRepositoryContract: AnyObject {
    var onError: ((Error) -> Void)? { get set }
    var isConnected: Bool { get }
    
    func fetchQuotesController() -> NSFetchedResultsController<QuoteMO>
    func connectToWebSocket(completion: @escaping (Result<Void, Error>) -> Void)
    func disconnect()
    func subscribeToSavedQuotes()
    func saveOrUpdateQuote(quote: QuoteEntity)
    func save(tickers: [String])
    func delete(quote: QuoteMO)
}
