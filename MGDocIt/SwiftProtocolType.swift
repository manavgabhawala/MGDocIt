//
//  SwiftProtocolType.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 16/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation

private let protocolKey = "MGSwiftProtocolKey"
private let protocolDefaultText = "<#Description of protocol #$0 #>"

struct SwiftProtocol : SwiftNameAndInheritedType
{
	var key : String { return protocolKey }
	var defaultText: String { return protocolDefaultText }
	var name: String
	var kind: SwiftDeclarationKind
	var inheritedTypes: [String]
}