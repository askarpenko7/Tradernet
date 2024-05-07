//
//  QuotesStorageManager.swift
//  Tradernet
//
//  Created by Alexander Karpenko on 04.05.2024.
//

import CoreData
import Foundation

final class QuotesStorageManager {
    private let manager: CoreDataManager
    var onError: ((Error) -> Void)?

    init(manager: CoreDataManager = .shared) {
        self.manager = manager
    }

    private var viewContext: NSManagedObjectContext {
        return manager.viewContext
    }
}

// MARK: QuoteMO update

private extension QuoteMO {
    enum PercentageChangeDirection: String {
        case none
        case up
        case down

        static func direction(old: Double, new: Double) -> Self {
            if new > old {
                return .up
            } else if new < old {
                return .down
            } else {
                return .none
            }
        }
    }

    func update(from entity: QuoteEntity) {
        let changes: [String: Any?] = [
            "ticker": entity.ticker.uppercased(),
            "name": entity.name,
            "percentageChangeFromPreviousClose": entity.percentageChangeFromPreviousClose,
            "latestTradeExchange": entity.latestTradeExchange,
            "lastTradePrice": entity.lastTradePrice,
            "priceChangePoints": entity.priceChangePoints,
        ]

        let direction: String
        if let newPercentage = entity.percentageChangeFromPreviousClose {
            direction = PercentageChangeDirection.direction(old: percentageChangeFromPreviousClose, new: newPercentage)
                .rawValue
        } else {
            direction = PercentageChangeDirection.none.rawValue
        }
        setValue(direction, forKey: "percentageChangeDirection")

        changes.forEach { key, value in
            if value != nil {
                let currentValue = self.value(forKey: key)
                if String(describing: currentValue) != String(describing: value) {
                    self.setValue(value, forKey: key)
                }
            }
        }
    }
}

// MARK: - Contract

extension QuotesStorageManager: QuotesStorageContract {
    func fetchQuotesController() -> NSFetchedResultsController<QuoteMO> {
        let fetchRequest: NSFetchRequest<QuoteMO> = QuoteMO.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "ticker", ascending: true)]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        do {
            try controller.performFetch()
        } catch {
            onError?(error)
        }
        return controller
    }

    func saveOrUpdateQuote(quote: QuoteEntity, completion: @escaping (Result<QuoteMO, Error>) -> Void) {
        viewContext.perform {
            let request: NSFetchRequest<QuoteMO> = QuoteMO.fetchRequest()
            request.predicate = NSPredicate(format: "ticker == %@", quote.ticker)

            do {
                let results = try self.viewContext.fetch(request)
                let quoteManagedObject = results.first ?? QuoteMO(context: self.viewContext)
                quoteManagedObject.update(from: quote)
                try self.viewContext.save()
                completion(.success(quoteManagedObject))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func processBatchUpdates(quotes: [QuoteEntity], completion: @escaping (Result<[QuoteMO], Error>) -> Void) {
        viewContext.perform {
            var managedQuotes = [QuoteMO]()
            for quote in quotes {
                let request: NSFetchRequest<QuoteMO> = QuoteMO.fetchRequest()
                request.predicate = NSPredicate(format: "ticker == %@", quote.ticker.uppercased())

                do {
                    let results = try self.viewContext.fetch(request)
                    let quoteManagedObject = results.first ?? QuoteMO(context: self.viewContext)
                    quoteManagedObject.update(from: quote)
                    managedQuotes.append(quoteManagedObject)
                } catch {
                    completion(.failure(error))
                    return
                }
            }
            do {
                try self.viewContext.save()
                completion(.success(managedQuotes))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func fetchUniqueTickers(completion: @escaping (Result<[String], Error>) -> Void) {
        viewContext.perform {
            let request = NSFetchRequest<NSDictionary>(entityName: "Quote")
            request.resultType = .dictionaryResultType
            request.propertiesToFetch = ["ticker"]
            request.returnsDistinctResults = true

            do {
                let results = try self.viewContext.fetch(request)
                let tickers = results.compactMap { $0["ticker"] as? String }
                completion(.success(tickers))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func save(tickers: [String]) {
        let entities = tickers.map { QuoteEntity(ticker: $0) }

        viewContext.perform {
            var managedObjects = [QuoteMO]()

            for quote in entities {
                let request: NSFetchRequest<QuoteMO> = QuoteMO.fetchRequest()
                request.predicate = NSPredicate(format: "ticker == %@", quote.ticker)

                do {
                    let results = try self.viewContext.fetch(request)
                    let quoteManagedObject = results.first ?? QuoteMO(context: self.viewContext)
                    quoteManagedObject.update(from: quote)
                    managedObjects.append(quoteManagedObject)
                } catch {
                    return
                }
            }

            do {
                try self.viewContext.save()
            } catch {}
        }
    }

    func delete(quote: QuoteMO, completion: @escaping (Result<Bool, Error>) -> Void) {
        do {
            viewContext.delete(quote)
            try viewContext.save()
            completion(.success(true))
        } catch {
            completion(.failure(error))
        }
    }
}
