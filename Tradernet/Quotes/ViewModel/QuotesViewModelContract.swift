//
//  QuotesViewModelContract.swift
//  Tradernet
//
//  Created by Alexander Karpenko on 04.05.2024.
//

import Foundation

protocol QuotesViewModelContract: AnyObject {
    var view: QuotesViewContract? { get set }
    var repository: QuotesRepositoryContract { get }
    var numberOfQuotes: Int { get }
    func notifyViewModel(with event: LifeCycleEvent)
    func quote(at indexPath: IndexPath) -> QuoteModel?
    func deleteQuote(at indexPath: IndexPath)
    func addRecommendedQuotes()
}
