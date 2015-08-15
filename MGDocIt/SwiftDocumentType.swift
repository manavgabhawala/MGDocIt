//
//  SwiftDocumentType.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 15/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation

protocol SwiftDocumentType : CustomStringConvertible
{
	var documentation: String { get }
	init(dict: XPCDictionary, map: SyntaxMap, @noescape stringDelegate: (start: Int, length: Int) -> String)
}
extension SwiftDocumentType
{
	var description: String { return documentation }
}

@warn_unused_result func createType(dictionary: XPCDictionary, map: SyntaxMap, @noescape stringDelegate: (start: Int, length: Int) -> String) -> SwiftDocumentType?
{
	guard let kind = SwiftDocKey.getKind(dictionary)
	else
	{
		return nil
	}
	switch kind
	{
	case .FunctionFree,
		 .FunctionMethodClass, 		.FunctionMethodInstance, 	.FunctionMethodStatic,
		 .FunctionConstructor, 		.FunctionDestructor:
		return SwiftFunction(dict: dictionary, map: map, stringDelegate: stringDelegate)
	case .Extension, .ExtensionEnum, .ExtensionProtocol, .ExtensionClass, .ExtensionStruct:
		return SwiftExtension(dict: dictionary, map: map, stringDelegate: stringDelegate)
	case .Class:
		return SwiftClass(dict: dictionary, map: map, stringDelegate: stringDelegate)
	case .Protocol:
		return SwiftProtocol(dict: dictionary, map: map, stringDelegate: stringDelegate)
	case .Struct:
		return SwiftStruct(dict: dictionary, map: map, stringDelegate: stringDelegate)
	case .Typealias:
		return SwiftTypealias(dict: dictionary, map: map, stringDelegate: stringDelegate)
	case .VarClass, .VarStatic, .VarInstance:
		return SwiftVar(dict: dictionary, map: map, stringDelegate: stringDelegate)
	case .Enum:
		return SwiftEnum(dict: dictionary, map: map, stringDelegate: stringDelegate)
	case .Enumcase:
		return SwiftEnumElement(dict: dictionary, map: map, stringDelegate: stringDelegate)
	default:
		return nil
	}
}