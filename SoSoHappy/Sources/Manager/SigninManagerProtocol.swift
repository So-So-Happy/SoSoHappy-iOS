//
//  SigninManagerProtocol.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/20.
//

import RxSwift

protocol SigninManagerProtocol {
    func signin() -> Observable<SigninRequest>

    func resign() -> Observable<Void>

    func logout() -> Observable<Void>
}
