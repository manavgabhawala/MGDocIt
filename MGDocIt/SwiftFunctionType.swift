//
//  SwiftFunctionType.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 15/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation

/// Kinds of functions
enum FunctionKind
{
	case Global
	case StaticClass
	case Instance
	case ConstructDestruct
}

struct SwiftFunction : SwiftDocumentType, Documentable
{
	var key: String
	{
		switch kind
		{
		case .Global:
			return "MGSwiftFunctionGlobal"
		case .StaticClass:
			return "MGSwiftFunctionStaticClass"
		case .Instance:
			return "MGSwiftFunctionInstance"
		case .ConstructDestruct:
			return "MGSwiftConstructorDestructor"
		}
	}
	var defaultText: String
	{
		return "<#Description of function #$0#>\n- Parameter #$1: This is a parameter of type `#$2`. <#Parameter #$1 description#>\nif#$4\n- Throws: <#Description#>\nend#$4if#$3\n- Returns: <#Description#>\nend#$3"
	}
	
	var returns: Bool
	var throwsError: Bool
	var parameters = [(String, type: String)]()
	var name: String
	var kind: FunctionKind
	
	init(dict: XPCDictionary, map: SyntaxMap, @noescape stringDelegate: (start: Int, length: Int) -> String)
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
				guard let kind = SwiftDocKey.getKind(sub) where kind == .VarParameter, let type = SwiftDocKey.getTypeName(sub)
				else
				{
					continue
				}
				parameters.append((SwiftDocKey.getName(sub) ?? "_", type))
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
		
		if let nameOffset = SwiftDocKey.getNameOffset(dict), let nameLength = SwiftDocKey.getNameLength(dict)
		{
			let end = SwiftDocKey.getBodyOffset(dict) ?? (SwiftDocKey.getOffset(dict)! + SwiftDocKey.getLength(dict)!)
			let startOffset = Int(nameOffset + nameLength)
			let endOffset = Int(end)
			for token in map.tokens where token.offset >= startOffset
			{
				guard token.offset < endOffset
				else
				{
					break
				}
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
	
	var availableTokens: [String: (String, DocumentableType)]
	{
		return ["#$0" : ("Name", .String),
				"#$1" : ("Parameter", .Array),
				"#$2" : ("ParameterType", .Array),
				"#$3" : ("Returns", .Bool),
				"#$4" : ("Throws", .Bool)]
	}
	
	func stringForToken(token: String) -> String?
	{
		guard token == "#$0"
		else
		{
			return nil
		}
		return name
	}
	
	func arrayForToken(token: String) -> [String]?
	{
		if token == "#$1"
		{
			return parameters.map { $0.0 }
		}
		else if token == "#$2"
		{
			return parameters.map { $0.type }
		}
		return nil
	}
	func boolForToken(token: String) -> Bool?
	{
		if token == "#$3"
		{
			return returns
		}
		else if token == "#$4"
		{
			return throwsError
		}
		return nil
	}
}