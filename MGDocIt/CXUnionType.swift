//
//  CXUnionType.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 18/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation


private let unionKey = "MGCXUnion"
private let unionDefaultText = "<#Description of union #$0#>"

struct CXUnion : CXNameType
{
	var key: String { return unionKey }
	var defaultText: String
	{
		return unionDefaultText
	}
	var name: String
}