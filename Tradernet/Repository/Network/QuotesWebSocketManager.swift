//
//  QuotesWebSocketManager.swift
//  Tradernet
//
//  Created by Alexander Karpenko on 03.05.2024.
//

import Foundation
import Starscream

final class QuotesWebSocketManager {
    var onConnected: (() -> Void)?
    var onDisconnected: ((Error?) -> Void)?
    var onError: ((Error) -> Void)?
    var onReceivedData: ((Data?) -> Void)?

    private var socket: WebSocket!
    private let serverURL = URL(string: "wss://wss.tradernet.com")!

    init() {
        var request = URLRequest(url: serverURL)
        request.timeoutInterval = 5
        self.socket = WebSocket(request: request)
        socket.delegate = self
    }
}

// MARK: WebSocketDelegate

extension QuotesWebSocketManager: WebSocketDelegate {
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected:
            onConnected?()
        case let .disconnected(reason, code):
            onDisconnected?(NSError(
                domain: "WebSocketDisconnected",
                code: Int(code),
                userInfo: [NSLocalizedDescriptionKey: reason]
            ))
        case let .text(string):
            onReceivedData?(string.data(using: .utf8))
        case let .error(error):
            if let error = error {
                onError?(error)
            }
        default:
            break
        }
    }
}

// MARK: - Contract

extension QuotesWebSocketManager: QuotesWebSocketContract {
    func connect() {
        socket.connect()
    }

    func disconnect() {
        socket.disconnect()
    }

    func subscribe(to quotes: [String]) {
        let message: [Any] = ["quotes", quotes]
        if let data = try? JSONSerialization.data(withJSONObject: message, options: []) {
            socket.write(data: data)
        }
    }
}
