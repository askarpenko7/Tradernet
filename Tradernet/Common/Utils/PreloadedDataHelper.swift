//
//  PreloadedDataHelper.swift
//  Tradernet
//
//  Created by Alexander Karpenko on 08.05.2024.
//

import Foundation

final class PreloadedDataHelper {
    private static let fileName = "preloaded_data"

    static func fetchPreloadedData() -> [String] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
              let data = try? Data(contentsOf: url)
        else {
            return []
        }

        do {
            let tickers = try JSONDecoder().decode([String].self, from: data)
            return tickers
        } catch {
            print("Failed to decode tickers: \(error)")
            return []
        }
    }
}
