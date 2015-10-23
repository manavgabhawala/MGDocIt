//
//  CXTypedefType.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 18/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation

private let typedefKey = "MGCXTypedef"
private let typedefDefaultText = "<#Description of typedef #$0#>"

struct CXTypedef : CXNameType
{
	var key: String { return typedefKey }
	var defaultText: String
	{
		return typedefDefaultText
	}
	var name: String
}