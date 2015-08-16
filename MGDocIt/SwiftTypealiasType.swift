//
//  SwiftTypealiasType.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 16/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation

private let typealiasKey = "MGSwiftTypealiasKey"
private let typealiasDefaultText = "<#Description of typealias #$0 #>"

struct SwiftTypealias : SwiftNameOnlyType
{
	var key : String { return typealiasKey }
	var defaultText: String { return typealiasDefaultText }
	var name: String
	var kind: SwiftDeclarationKind
}