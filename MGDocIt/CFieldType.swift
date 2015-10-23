//
//  CFieldType.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 18/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation

private let fieldKey = "MGCField"
private let fieldDefaultText = "<#Description of field #$0#>"

struct CField : CXNameType
{
	var key: String { return fieldKey }
	var defaultText: String
	{
		return fieldDefaultText
	}
	var name: String
}