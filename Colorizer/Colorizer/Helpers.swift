//
//  Helpers.swift
//  Colorizer
//
//  Created by Julian Dunskus on 02.05.17.
//  Copyright © 2017 Julian Dunskus. All rights reserved.
//

import AppKit

func error(code: Int = 0, description: String? = nil, recoverySuggestion: String? = nil) -> NSError {
	var userInfo: [AnyHashable: Any] = [:]
	userInfo[NSLocalizedDescriptionKey] = description
	userInfo[NSLocalizedRecoverySuggestionErrorKey] = recoverySuggestion
	return NSError(domain: "com.juliand665.Colorizer", code: code, userInfo: userInfo)
}
