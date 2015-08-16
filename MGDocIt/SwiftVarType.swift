//
//  SwiftVarType.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 16/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation


private let varKey = "MGSwiftVarKey"
private let varDefaultText = "<#Description of variable #$0#>"

struct SwiftVar : SwiftNameOnlyType
{
	var key : String { return varKey }
	var defaultText: String { return varDefaultText }
	var name: String
	var kind: SwiftDeclarationKind
}