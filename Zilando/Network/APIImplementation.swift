//
//  APIImplementation.swift
//  Zilando
//
//  Created by Le, Triet on 30.12.2020
//

import Foundation

extension ZilandoAPI {
    var path: String { "" }
    var method: RequestMethod { .get }
    var headers: ReaquestHeaders? { nil }
    var parameters: RequestParameters? { nil }
}
