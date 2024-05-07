//
//  QuotesViewModel.swift
//  Tradernet
//
//  Created by Alexander Karpenko on 04.05.2024.
//

import CoreData
import Foundation

final class QuotesViewModel: NSObject {
    weak var view: QuotesViewContract?
    internal var repository: QuotesRepositoryContract

    var numberOfQuotes: Int {
        return fetchedResultsController?.sections?.first?.numberOfObjects ?? 0
    }

    private var fetchedResultsController: NSFetchedResultsController<QuoteMO>?

    // MARK: - Init

    init(repository: QuotesRepositoryContract) {
        self.repository = repository
        super.init()

        self.repository.onError = { [weak self] error in
            var message = ""
            if let dlError = error as? DLError {
                switch dlError {
                case .encodingFailed:
                    message = LocalizedString.unexpectedError.localized
                case let .connectionFailed(string):
                    message = string
                case .disconnected:
                    message = LocalizedString.disconnected.localized
                case .unexpectedResponse:
                    return
                case .noSavedQuotes:
                    self?.view?.showStateView()
                    return
                case .savingOperationFail:
                    message = LocalizedString.saveWasUnsuccessful.localized
                }
            } else {
                message = LocalizedString.unexpectedError.localized
            }
            self?.view?.showToast(with: message)
        }
    }

    // MARK: Private functions

    private func connectToWebSocket() {
        view?.showLoading()
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.repository.connectToWebSocket { result in
                DispatchQueue.main.async {
                    self?.view?.hideLoading()
                    switch result {
                    case .success:
                        self?.view?.showLoading()
                        self?.repository.subscribeToSavedQuotes()
                    case let .failure(failure):
                        self?.view?.showToast(with: String(
                            format: LocalizedString.webSocketError.localized,
                            failure.localizedDescription
                        ))
                    }
                }
            }
        }
    }

    private func setupFetchedResultsController() {
        fetchedResultsController = repository.fetchQuotesController()
        fetchedResultsController?.delegate = self

        do {
            try fetchedResultsController?.performFetch()
        } catch {
            view?.showToast(with: String(format: LocalizedString.webSocketError.localized, error.localizedDescription))
        }
    }
}

// MARK: - Contract

extension QuotesViewModel: QuotesViewModelContract {
    func notifyViewModel(with event: LifeCycleEvent) {
        switch event {
        case .viewDidLoad:
            connectToWebSocket()
            setupFetchedResultsController()
        case .viewDidDisappear:
            repository.disconnect()
        }
    }

    func quote(at indexPath: IndexPath) -> QuoteModel? {
        guard let managedObject = fetchedResultsController?.object(at: indexPath) else { return nil }
        return QuoteModel(from: managedObject)
    }

    func deleteQuote(at indexPath: IndexPath) {
        guard let managedObject = fetchedResultsController?.object(at: indexPath) else { return }
        repository.delete(quote: managedObject)
    }

    func addRecommendedQuotes() {
        let quotes = PreloadedDataHelper.fetchPreloadedData()
        repository.save(tickers: quotes)
        view?.showLoading()
        repository.subscribeToSavedQuotes()
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension QuotesViewModel: NSFetchedResultsControllerDelegate {
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        view?.hideLoading()
        view?.hideStateView()
        switch type {
        case .insert:
            view?.insertRowAt(newIndexPath)
        case .delete:
            view?.deleteRowAt(indexPath)
        case .update:
            view?.reloadRowAt(indexPath)
        case .move:
            view?.moveRow(at: indexPath, to: newIndexPath)
        @unknown default:
            fatalError("NSFetchedResultsController has received an unhandled change type.")
        }
    }
}
