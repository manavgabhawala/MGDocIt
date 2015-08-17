//
//  ObjectiveCInterfaceType.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 17/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation

private let interfaceKey = "MGObjcInterface"
private let interfaceDefaultText = "<#Description of class #$0#>"

struct ObjectiveCInterface : ObjectiveCNameAndInheritedType
{
	var key: String { return interfaceKey }
	var defaultText: String
	{
		return interfaceDefaultText
	}
	
	var name: String
	var inheritedTypes = [String]()
}