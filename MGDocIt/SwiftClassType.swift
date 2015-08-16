//
//  SwiftClassType.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 16/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation

private let classKey = "MGSwiftClassKey"
private let classDefaultText = "/// <#Description of class #$0 #>"

struct SwiftClass : SwiftNameAndInheritedType
{
	var key : String { return classKey }
	var defaultText: String { return classDefaultText }
	var name: String
	var kind: SwiftDeclarationKind
	var inheritedTypes: [String]
}