//
//  SwiftExtensionType.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 16/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation

private let extensionKey = "MGSwiftExtensionKey"
private let extensionDefaultText = "// MARK: - <#$1>"

struct SwiftExtension : SwiftNameAndInheritedType
{
	var key : String { return extensionKey }
	var defaultText: String { return extensionDefaultText }
	var name: String
	var kind: SwiftDeclarationKind
	var inheritedTypes: [String]
}