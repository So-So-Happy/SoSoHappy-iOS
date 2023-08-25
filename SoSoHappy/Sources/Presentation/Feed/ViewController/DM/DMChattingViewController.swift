//
//  DMChattingViewController.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit
import MessageKit

/*
 리팩토링 필요
 */

struct Sender: SenderType {
    var senderId: String
    var displayName: String
}

struct Message: MessageType {
    var sender: MessageKit.SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKit.MessageKind
}

final class DMChattingViewController: MessagesViewController {
    let currentUser = Sender(senderId: "self", displayName: "나")
    let otherUser = Sender(senderId: "other", displayName: "소해피")
    var messages = [Message]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "소해피"
        messagesCollectionView.backgroundColor = UIColor(named: "backgroundColor")
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        messages.append(Message(sender: currentUser, messageId: "1", sentDate: Date(), kind: .text("안녕")))
        
        messages.append(Message(sender: otherUser, messageId: "2", sentDate: Date().addingTimeInterval(-70000), kind: .text("안녕~ 뭐하구 지내?")))

        messages.append( Message(sender: currentUser, messageId: "3", sentDate: Date().addingTimeInterval(-56400), kind: .text("그냥 공부하고 운동하구")))

        messages.append(Message(sender: otherUser, messageId: "4", sentDate: Date().addingTimeInterval(-46000), kind: .text("아아 그렇구나")))
        messagesCollectionView.reloadData()
        
        print("messages.count: \(messages.count)")
    }
}

extension DMChattingViewController: MessagesDataSource {
    var currentSender: MessageKit.SenderType {
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
}

extension DMChattingViewController: MessagesLayoutDelegate {
    
}

extension DMChattingViewController: MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .orange : .white
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
            let cornerDirection: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
            return .bubbleTail(cornerDirection, .curved)
        }
}


#if DEBUG
import SwiftUI
struct DMChattingViewControllerRepresentable: UIViewControllerRepresentable {
    
    func updateUIViewController(_ uiView: UIViewController,context: Context) {
        // leave this empty
    }
    @available(iOS 13.0.0, *)
    func makeUIViewController(context: Context) -> UIViewController{
        DMChattingViewController()
    }
}
@available(iOS 13.0, *)
struct DMChattingViewControllerRepresentable_PreviewProvider: PreviewProvider {
    static var previews: some View {
        Group {
            DMChattingViewControllerRepresentable()
                .ignoresSafeArea()
                .previewDisplayName(/*@START_MENU_TOKEN@*/"Preview"/*@END_MENU_TOKEN@*/)
                .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
        }
        
    }
} #endif

