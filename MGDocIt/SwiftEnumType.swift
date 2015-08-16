//
//  SwiftEnumType.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 16/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation

private let enumKey = "MGSwiftEnumKey"
private let enumDefaultText = "/// <#Description of enum #$0 #>"

struct SwiftEnum : SwiftNameAndInheritedType
{
	var key : String { return enumKey }
	var defaultText: String { return enumDefaultText }
	var name: String
	var kind: SwiftDeclarationKind
	var inheritedTypes: [String]
}