//
//  ObjectiveCEnumType.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 18/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation

private let enumKey = "MGCXEnum"
private let enumDefaultText = "<#Description of enum #$0#>"

struct CXEnum : CXNameType
{
	var key: String { return enumKey }
	var defaultText: String
	{
		return enumDefaultText
	}
	var name: String
}