//
//  ObjectiveCInterfaceType.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 17/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation

struct ObjectiveCInterface
{
	init(cursor: CXCursor, tokens: [MGCXToken], translationUnit: CXTranslationUnit)
	{
		var endOffset: UInt32 = 0
		
		clang_getSpellingLocation(clang_getRangeEnd(clang_getCursorExtent(cursor)), nil, nil , nil, &endOffset)
			
		clang_visitChildrenWithBlock(cursor) { child, _ in
			clang_getSpellingLocation(clang_getRangeStart(clang_getCursorExtent(child)), nil, nil , nil, &endOffset)
			return CXChildVisit_Break
		}
		for t in tokens
		{
			var tokenStart: UInt32 = 0
			clang_getSpellingLocation(clang_getTokenLocation(translationUnit, t.token), nil, nil, nil, &tokenStart)
			guard tokenStart < endOffset
			else
			{
				break
			}
		}
		
	}
}