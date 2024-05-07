//
//  TickersViewModel.swift
//  Tradernet
//
//  Created by Alexander Karpenko on 06.05.2024.
//

import Foundation

final class TickersViewModel {
    weak var view: TickersViewContract?
    var tickers: [String] = []

    private var repository: TickerRepositoryContract

    init(repository: TickerRepositoryContract) {
        self.repository = repository
    }
}

extension TickersViewModel: TickersViewModelContract {
    func fetchTickers() {
        view?.showLoadingIndicator()
        repository.fetchTickers { [weak self] result in
            self?.view?.hideLoadingIndicator()
            switch result {
            case let .success(success):
                self?.tickers = success
                self?.view?.showTickers(success)
            case let .failure(failure):
                self?.view?.showError(message: failure.localizedDescription)
            }
        }
    }

    func saveTicker(at position: Int) {
        repository.saveTicker(tickers[position])
    }
}
