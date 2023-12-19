//
//  Ex+Observable.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/09/11.
//

import Foundation
import RxSwift

extension Observable where Element == Data {
    func map<T: Decodable>(_ type: T.Type) -> Observable<T> {
        flatMap { element -> Observable<T> in
            .create { observer in
                let decoder = JSONDecoder()
                do {
                    let model = try decoder.decode(T.self, from: element)
                    observer.onNext(model)
                } catch {
                    observer.onError(NSError())
                }
                return Disposables.create()
            }
        }
    }
}
