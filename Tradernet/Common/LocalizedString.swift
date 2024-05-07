//
//  LocalizedString.swift
//  Tradernet
//
//  Created by Alexander Karpenko on 07.05.2024.
//

import Foundation

enum LocalizedString: String {
    case quotes
    case unexpectedError = "unexpected_error"
    case disconnected
    case unexpectedResponse = "unexpected_response"
    case noSavedQuotes = "no_saved_quotes"
    case saveWasUnsuccessful = "save_was_unsuccessful"
    case webSocketError = "web_socket_error"
    case errorFetchingQuotes = "error_fetching_quotes"
    case deleteQuoteAlertTitle = "delete_quote_alert_title"
    case deleteQuoteAlertMessage = "delete_quote_alert_message"
    case cancel
    case delete
    case unknown
    case tickers
    case emptyStateMessage = "empty_state_message"
    case emptyStateButton = "empty_state_button"
    case emptyStateRecommendedButton = "empty_state_recommended_button"

    var localized: String {
        return NSLocalizedString(rawValue, comment: "")
    }
}
