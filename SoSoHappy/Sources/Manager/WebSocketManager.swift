//
//  WebSocketManager.swift
//  SoSoHappy
//
//  Created by Sue on 10/8/23.
//

import Starscream
import Foundation

final class WebSocketManager: NSObject {
    static let shared = WebSocketManager() // 일단은 Singleton으로 만들어줬는데 좀 더 고민해보긴 해야 함
    private var socket: WebSocket?
    var isConnected: Bool = false
    
    private override init() {
        super.init()
    }
    
    private func connect() {
        let urlString = Bundle.main.baseURL + Bundle.main.connectNoticePath
        var request = URLRequest(url: URL(string: urlString)!)
        socket = WebSocket(request: request)
        socket?.delegate = self
        socket?.connect()
    }
    
    func disconnect() {
        socket?.disconnect()
    }
}

extension WebSocketManager: WebSocketDelegate {
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            isConnected = true
        case .disconnected(let reason, let code):
            isConnected = false
        case .text(let string):
            break
        case .binary(let data):
            break
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnected = false
        case .error(let error):
            isConnected = false
            handleError(error)
        case .peerClosed:
            break
        }
    }
    
    func handleError(_ error: Error?) {
          if let e = error as? WSError {
          } else if let e = error {
          } else {
          }
      }
    
}
