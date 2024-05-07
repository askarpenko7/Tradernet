//
//  TickerRepositoryContract.swift
//  Tradernet
//
//  Created by Alexander Karpenko on 06.05.2024.
//

import Foundation

protocol TickerRepositoryContract {
    func fetchTickers(completion: @escaping (Result<[String], Error>) -> Void)
    func saveTicker(_ ticker: String)
}
