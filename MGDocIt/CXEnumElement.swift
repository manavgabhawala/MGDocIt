//
//  CXEnumElement.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 18/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation


private let enumElementKey = "MGCXEnumElement"
private let enumElementDefaultText = "<#Description of element #$0#>"

struct CXEnumElement : CXNameType
{
	var key: String { return enumElementKey }
	var defaultText: String
	{
		return enumElementDefaultText
	}
	var name: String
}