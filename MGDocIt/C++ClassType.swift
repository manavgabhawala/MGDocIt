//
//  C++ClassType.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 18/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation

private let cppClassKey = "MGCPPClass"
private let cppClassDefaultText = "<#Description of class #$0#>"


struct CPPClass: ObjectiveCNameAndInheritedType
{
	var key: String { return cppClassKey }
	var defaultText: String
	{
		return cppClassDefaultText
	}
	
	var name: String
	var inheritedTypes : [String]
	
	init(name: String, inheritedTypes: [String])
	{
		self.name = name
		self.inheritedTypes = inheritedTypes
	}
	init(cursor: CXCursor, tokens: [MGCXToken], translationUnit tu: CXTranslationUnit)
	{
		name = String(clang_getCursorDisplayName(cursor)) ?? ""
		var colonReached = false
		inheritedTypes = [String]()
		for t in tokens
		{
			guard colonReached || clang_getTokenKind(t.token) == CXToken_Punctuation, let tok = String(clang_getTokenSpelling(tu, t.token))
			else
			{
				continue
			}
			if tok == ":"
			{
				colonReached = true
				continue
			}
			if tok == "{"
			{
				break
			}
			guard colonReached && clang_getTokenKind(t.token) != CXToken_Punctuation
			else
			{
				continue
			}
			inheritedTypes.append(tok)
		}
		print(name)
		print(inheritedTypes)

	}
}