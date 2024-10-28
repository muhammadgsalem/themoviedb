//
//  BusinessError.swift
//  BusinessLayer
//
//  Created by Jimmy on 04/09/2024.
//

import Foundation
import DataRepository

public enum BusinessError: Error {
    case repositoryError(RepositoryError)
    case invalidData
    case unknown(Error)
}
