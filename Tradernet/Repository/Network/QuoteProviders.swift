//
//  QuoteProviders.swift
//  Tradernet
//
//  Created by Alexander Karpenko on 03.05.2024.
//

import Foundation

typealias QuotesWebSocketContract = WebSocketConnectionProvider & QuotesWebSocketProvider

// Protocol for managing the WebSocket connection.
protocol WebSocketConnectionProvider {
    func connect()
    func disconnect()
    var onConnected: (() -> Void)? { get set }
    var onDisconnected: ((Error?) -> Void)? { get set }
    var onError: ((Error) -> Void)? { get set }
}

// Protocol for handling quote-specific WebSocket communications.
protocol QuotesWebSocketProvider: WebSocketConnectionProvider {
    func subscribe(to quotes: [String])
    var onReceivedData: ((Data?) -> Void)? { get set }
}
