//
//  TickerProvider.swift
//  Tradernet
//
//  Created by Alexander Karpenko on 06.05.2024.
//

import Foundation

protocol TickerProvider {
    func fetchTickers(exchange: String, limit: Int, completion: @escaping (Result<[String], Error>) -> Void)
}
