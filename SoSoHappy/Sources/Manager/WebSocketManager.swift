//
//  WebSocketManager.swift
//  SoSoHappy
//
//  Created by Sue on 10/8/23.
//

// https://github.com/wshcczc/WebSocketManager
// https://github.com/search?q=WebSocketManager+language%3ASwift+starscream&type=code

/*
 참고 프로젝트
 1. https://github.com/GetStream/stream-chat-swift/tree/00b1258e1fff6edfa4a2b035870057b1ada2ab35/Sources/StreamChat
 2. https://github.com/Criptext/iOS-Email-Client/tree/2e6547e0ea7eaea25f59b8382dd63be73f623231
 */

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
        // Query도 설정해줘야 하는건가요?
        
        // HEADER에 세팅해주는 값들도 다 숨겨줘야 하나요?
        request.setValue("Host", forHTTPHeaderField: "sosohappy.net:8892")
        request.setValue("Connection", forHTTPHeaderField: "Upgrade")
        request.setValue("Sec-WebSocket-Key", forHTTPHeaderField: "sosohappy.net:8892") // 여기에는 뭘 넣어줘야 하는건가요?
        request.setValue("Sec-WebSocket-Version", forHTTPHeaderField: "13") //
        request.setValue("Authorization", forHTTPHeaderField: "13") // accessToken
        request.setValue("Email", forHTTPHeaderField: "13") // email
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
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            print("Received text: \(string)")
        case .binary(let data):
            print("Received data: \(data.count)")
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
              print("websocket encountered an error: \(e.message)")
          } else if let e = error {
              print("websocket encountered an error: \(e.localizedDescription)")
          } else {
              print("websocket encountered an error")
          }
      }
    
}
