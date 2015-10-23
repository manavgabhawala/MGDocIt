//
//  CXFunctionType.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 18/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation


struct CXFunction: CXDocumentType, Documentable
{
	var kind: FunctionKind
	var name: String
	var parameters = [(String, type: String)]()
	var returns: Bool = false
	
	init(cursor: CXCursor, tokens: [MGCXToken], translationUnit tu: CXTranslationUnit)
	{
		switch clang_getCursorKind(cursor)
		{
		case CXCursor_ObjCClassMethodDecl, CXCursor_ConversionFunction:
			self.kind = .StaticClass
		case CXCursor_ObjCInstanceMethodDecl:
			self.kind = .Instance
		case CXCursor_FunctionDecl:
			self.kind = .Global
		case CXCursor_Constructor, CXCursor_Destructor:
			self.kind = .ConstructDestruct
		default:
			self.kind = .Global
		}
		self.name = String(clang_getCursorSpelling(cursor)) ?? ""
		
		let returnKind = clang_getCursorResultType(cursor).kind.rawValue
		if returnKind != CXType_Void.rawValue
		{
			returns = true
		}
		if returnKind == CXType_ObjCId.rawValue && self.name.rangeOfString("init") != nil && self.kind == .Instance
		{
			returns = false
		}
		if self.kind == .ConstructDestruct
		{
			returns = false
		}
		let argumentCount = UInt32(clang_Cursor_getNumArguments(cursor))
		parameters.reserveCapacity(Int(argumentCount))
		for i in 0..<argumentCount
		{
			let curs = clang_Cursor_getArgument(cursor, i)
			var offset : UInt32 = 0
			
			clang_getSpellingLocation(clang_getCursorLocation(curs), nil, nil, nil, &offset)
			let type = clang_getCursorType(curs)
			print(String(clang_getCursorDisplayName(clang_getTypeDeclaration(type))))
			var kind = String(clang_getTypeSpelling(type)) ?? ""
			if type.kind.rawValue == CXType_ObjCId.rawValue
			{
				for (i, t) in tokens.enumerate()
				{
					var tOff : UInt32 = 0
					clang_getSpellingLocation(clang_getTokenLocation(tu, t.token), nil, nil, nil, &tOff)
					guard tOff == offset
						else
					{
						continue
					}
					var count = i - 1
					while count >= 0 && clang_getTokenKind(tokens[count].token).rawValue != CXToken_Identifier.rawValue
					{
						--count
					}
					kind = String(clang_getTokenSpelling(tu, tokens[count].token)) ?? kind
					break
				}
			}
			
			guard let name = String(clang_getCursorSpelling(curs))
			else
			{
				continue
			}
			
			parameters.append((name, type: kind))
		}
		
	}
	
	var key: String
	{
		switch kind
		{
		case .Global:
			return "MGCXFunctionGlobal"
		case .StaticClass:
			return "MGCXFunctionStaticClass"
		case .Instance:
			return "MGCXFunctionInstance"
		case .ConstructDestruct:
			return "MGCXConstructorDestructor"
		}
	}
	
	var defaultText: String
	{
		return "<#Description of function #$0#>\n@param #$1: This is a parameter of type <code>#$2</code>. <#Parameter #$1 description#>\nif#$3\n@returns: <#Description#>\nend#$3"
	}
	
	var availableTokens: [String: (String, DocumentableType)]
	{
		return ["#$0" : ("Name", .String),
			"#$1" : ("Parameter", .Array),
			"#$2" : ("ParameterType", .Array),
			"#$3" : ("Returns", .Bool)]
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
		guard token == "#$3"
		else
		{
			return nil
		}
		return returns
	}
}