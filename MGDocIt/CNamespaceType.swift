//
//  CNamespaceType.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 18/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation


private let namespaceKey = "MGCNamespace"
private let namespaceDefaultText = "<#Description of namespace #$0#>"

struct CNamespace : CXNameType
{
	var key: String { return namespaceKey }
	var defaultText: String
	{
		return namespaceDefaultText
	}
	var name: String
}