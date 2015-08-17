//
//  ObjectiveCNameAndInheritedType.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 18/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation
protocol ObjectiveCNameAndInheritedType : NameAndInheritedType, ObjectiveCDocumentType
{
	init(name: String, inheritedTypes: [String])
}

extension ObjectiveCNameAndInheritedType
{
	init(cursor: CXCursor, tokens: [MGCXToken], translationUnit tu: CXTranslationUnit)
	{
		var endOffset: UInt32 = 0
		
		clang_getSpellingLocation(clang_getRangeEnd(clang_getCursorExtent(cursor)), nil, nil , nil, &endOffset)
		
		clang_visitChildrenWithBlock(cursor) { child, _ in
			guard clang_getCursorKind(child).rawValue != CXCursor_ObjCProtocolRef.rawValue
				else
			{
				return CXChildVisit_Continue
			}
			clang_getSpellingLocation(clang_getRangeStart(clang_getCursorExtent(child)), nil, nil , nil, &endOffset)
			return CXChildVisit_Break
		}
		let name = String(clang_getCursorSpelling(cursor)) ?? ""
		var encounteredColon = false
		var encounteredOpenAngle = false
		var inherited = [String]()
		for t in tokens
		{
			var tokenStart: UInt32 = 0
			clang_getSpellingLocation(clang_getTokenLocation(tu, t.token), nil, nil, nil, &tokenStart)
			guard tokenStart < endOffset
				else
			{
				break
			}
			guard let tokenName = String(clang_getTokenSpelling(tu, t.token)) where encounteredColon || encounteredOpenAngle || clang_getTokenKind(t.token) == CXToken_Punctuation
				else
			{
				continue
			}
			if tokenName == ":"
			{
				encounteredColon = true
				continue
			}
			if tokenName == "<"
			{
				encounteredOpenAngle = true
				continue
			}
			if tokenName == ">"
			{
				encounteredOpenAngle = false
				continue
			}
			if encounteredColon
			{
				inherited.append(tokenName)
				encounteredColon = false
				continue
			}
			if encounteredOpenAngle && clang_getTokenKind(t.token) != CXToken_Punctuation
			{
				inherited.append(tokenName)
			}
		}
		self.init(name: name, inheritedTypes: inherited)
		print(name)
		print(inheritedTypes)
	}

}
	