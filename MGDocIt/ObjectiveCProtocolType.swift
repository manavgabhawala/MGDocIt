//
//  ObjectiveCProtocolType.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 18/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation

private let protocolKey = "MGObjcProtocol"
private let protocolDefaultText = "<#Description of protocol #$0#>"

struct ObjectiveCProtocol : ObjectiveCNameAndInheritedType
{
	var key: String { return protocolKey }
	var defaultText: String
	{
		return protocolDefaultText
	}
	
	var name: String
	var inheritedTypes = [String]()
}