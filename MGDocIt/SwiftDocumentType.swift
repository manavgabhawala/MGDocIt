//
//  SwiftDocumentType.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 15/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation

/// All Swift types must conform to this protocol in order to be documented.
protocol SwiftDocumentType : DocumentType, CustomStringConvertible
{
	init(dict: XPCDictionary, map: SyntaxMap, @noescape stringDelegate: (start: Int, length: Int) -> String)
}
extension SwiftDocumentType
{
	var description: String { return documentationWithIndentation("") }
}

/// Create a Swift type based on the kind of swift declaration being documented
///
/// - Parameter kind: This is a parameter of type `SwiftDeclarationKind?`. The kind of swift declaration being documented.
///
/// - Returns: The SwiftDocumentType type so that it can be initialized. Can be nil
@warn_unused_result func createSwiftType(kind: SwiftDeclarationKind?) -> SwiftDocumentType.Type?
{
	guard let kind = kind
	else
	{
		return nil
	}
	switch kind
	{
	case .FunctionFree,
		 .FunctionMethodClass, 		.FunctionMethodInstance, 	.FunctionMethodStatic,
		 .FunctionConstructor, 		.FunctionDestructor:
		return SwiftFunction.self
	case .Extension, .ExtensionEnum, .ExtensionProtocol, .ExtensionClass, .ExtensionStruct:
		return SwiftExtension.self
	case .Class:
		return SwiftClass.self
	case .Protocol:
		return SwiftProtocol.self
	case .Struct:
		return SwiftStruct.self
	case .Typealias:
		return SwiftTypealias.self
	case .VarClass, .VarStatic, .VarInstance:
		return SwiftVar.self
	case .Enum:
		return SwiftEnum.self
	case .Enumcase:
		return SwiftEnumElement.self
	default:
		return nil
	}
}