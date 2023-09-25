//
//  ErrorResponse.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/21.
//

struct ErrorResponse: Decodable {
  
  let resultCode: String
  let message: String
  
  enum CodingKeys: String, CodingKey {
    case resultCode
    case message
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    resultCode = try values.decodeIfPresent(String.self, forKey: .resultCode) ?? ""
    message = try values.decodeIfPresent(String.self, forKey: .message) ?? ""
  }
}

