//
//  SwiftFunctionType.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 15/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation

enum SwiftFunctionKind
{
	case Global
	case StaticClass
	case Instance
	case ConstructDestruct
}

class SwiftFunction : SwiftDocumentType
{
	var documentation: String
	{
		// FIXME: Use preferences
		return "/// Function \(name) of kind \(kind). Params: \(parameters) <#test#>. Returns: \(returns). Throws: \(throwsError)"
	}
	
	var returns: Bool
	var throwsError: Bool
	var parameters = [String]()
	var name: String
	var kind: SwiftFunctionKind
	
	required init(dict: XPCDictionary, map: SyntaxMap, @noescape stringDelegate: (start: Int, length: Int) -> String)
	{
		guard let kind = SwiftDocKey.getKind(dict)
		else
		{
			fatalError("No function kind found.")
		}
		assert(kind.rawValue.rangeOfString("source.lang.swift.decl.function") != nil, "Non function type passed to SwiftFunction initializer.")
		switch kind
		{
		case .FunctionDestructor, .FunctionConstructor:
			self.kind = .ConstructDestruct
		case .FunctionMethodStatic, .FunctionMethodClass:
			self.kind = .StaticClass
		case .FunctionFree:
			self.kind = .Global
		case .FunctionMethodInstance:
			self.kind = .Instance
		default:
			fatalError("Unknown function kind \(kind)")
		}
		
		throwsError = false
		returns = false
		
		if let attributes = SwiftDocKey.getAttributes(dict)
		{
			for attribute in attributes
			{
				guard let attr = SwiftDocKey.getAttribute(attribute as? XPCDictionary)
				else
				{
					print("Unknown attribute found: \(attribute)")
					continue
				}
				if attr == .Rethrows
				{
					throwsError = true
				}
			}
		}
		if let subs = SwiftDocKey.getSubstructure(dict)
		{
			for sub in subs
			{
				guard let sub = sub as? XPCDictionary
				else
				{
					continue
				}
				guard let kind = SwiftDocKey.getKind(sub) where kind == .VarParameter
				else
				{
					continue
				}
				parameters.append(SwiftDocKey.getName(sub) ?? "")
			}
		}
		if let name = SwiftDocKey.getName(dict)
		{
			self.name = name
		}
		else
		{
			self.name = ""
		}
		
		if let nameOffset = SwiftDocKey.getNameOffset(dict), let nameLength = SwiftDocKey.getNameLength(dict), let end = SwiftDocKey.getBodyOffset(dict)
		{
			let startOffset = Int(nameOffset + nameLength)
			let endOffset = Int(end)
			for token in map.tokens where (token.offset >= startOffset && token.offset < endOffset)
			{
				if token.type == SyntaxKind.Typeidentifier
				{
					let str = stringDelegate(start: token.offset, length: token.length).lowercaseString
					guard str != "void" && str != "()"
					else
					{
						continue
					}
					returns = true
				}
				if token.type == SyntaxKind.Keyword && stringDelegate(start: token.offset, length: token.length) == "throws"
				{
					throwsError = true
				}
			}
		}
	}
	
}