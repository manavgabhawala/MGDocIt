//
//  SwiftStructType.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 16/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation

private let structKey = "MGSwiftStructKey"
private let structDefaultText = "/// <#Description of struct #$0 #>"

struct SwiftStruct : SwiftNameAndInheritedType
{
	var key : String { return structKey }
	var defaultText: String { return structDefaultText }
	var name: String
	var kind: SwiftDeclarationKind
	var inheritedTypes: [String]
}