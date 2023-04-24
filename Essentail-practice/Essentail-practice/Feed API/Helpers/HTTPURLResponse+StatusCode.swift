//
//  HTTPURLResponse+StatusCode.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2023/4/24.
//

import Foundation

extension HTTPURLResponse {
    
    private static var OK_200: Int { return 200 }

    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
