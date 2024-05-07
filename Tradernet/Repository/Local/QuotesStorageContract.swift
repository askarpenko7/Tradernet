//
//  QuotesStorageProvider.swift
//  Tradernet
//
//  Created by Alexander Karpenko on 03.05.2024.
//

import CoreData
import Foundation

protocol QuotesStorageContract {
    func fetchQuotesController() -> NSFetchedResultsController<QuoteMO>
    func saveOrUpdateQuote(quote: QuoteEntity, completion: @escaping (Result<QuoteMO, Error>) -> Void)
    func processBatchUpdates(quotes: [QuoteEntity], completion: @escaping (Result<[QuoteMO], Error>) -> Void)
    func fetchUniqueTickers(completion: @escaping (Result<[String], Error>) -> Void)
    func save(tickers: [String])
    func delete(quote: QuoteMO, completion: @escaping (Result<Bool, Error>) -> Void)
}
