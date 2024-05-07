//
//  DLError.swift
//  Tradernet
//
//  Created by Alexander Karpenko on 04.05.2024.
//

import Foundation

enum DLError: Error {    
    case encodingFailed
    case connectionFailed(String)
    case disconnected
    case unexpectedResponse
    case noSavedQuotes
    case savingOperationFail
}
