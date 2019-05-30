//
//  APIError.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 5/29/19.
//  Copyright © 2018 Framgia. All rights reserved.
//

struct APIExpiredTokenError: APIError {
    var errorDescription: String? {
        return NSLocalizedString("api.expiredTokenError",
                                 value: "Access token is expired",
                                 comment: "")
    }
}

struct APIResponseError: APIError {
    let statusCode: Int?
    let message: String
    
    var errorDescription: String? {
        return message
    }
}
