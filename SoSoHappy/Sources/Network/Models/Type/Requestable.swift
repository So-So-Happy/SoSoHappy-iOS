//
//  Requestable.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/20.
//

import Foundation

protocol Requestable {
  var params: [String: Any] { get }
}

