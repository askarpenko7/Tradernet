//
//  TickerManager.swift
//  Tradernet
//
//  Created by Alexander Karpenko on 06.05.2024.
//

import Foundation

final class TickerManager: TickerProvider {
    private let baseURL = URL(string: "https://tradernet.com/")!

    func fetchTickers(exchange: String, limit: Int, completion: @escaping (Result<[String], Error>) -> Void) {
        guard var components = URLComponents(string: baseURL.absoluteString) else {
            fatalError("Invalid base URL")
        }

        components.path = "/api/"
        var queryItems = components.queryItems ?? []

        let query: [String: Any] = [
            "cmd": "getTopSecurities",
            "params": [
                "type": "stocks",
                "exchange": exchange,
                "gainers": 0,
                "limit": limit,
            ],
        ]

        if let jsonData = try? JSONSerialization.data(withJSONObject: query, options: []),
           let queryString = String(data: jsonData, encoding: .utf8)
        {
            let queryItem = URLQueryItem(name: "q", value: queryString)
            queryItems.append(queryItem)
            components.queryItems = queryItems
        }

        guard let url = components.url else {
            fatalError("Invalid URL")
        }

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? NSError(
                    domain: "",
                    code: 2,
                    userInfo: [NSLocalizedDescriptionKey: "Network request failed"]
                )))
                return
            }

            do {
                // Parse JSON data
                if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let tickers = jsonResult["tickers"] as? [String]
                {
                    completion(.success(tickers))
                } else {
                    completion(.failure(NSError(
                        domain: "",
                        code: 3,
                        userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure"]
                    )))
                }
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
}
