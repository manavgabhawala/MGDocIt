//
//  ObjectiveCNameType.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 18/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation

protocol ObjectiveCNameType : NameType, ObjectiveCDocumentType
{
	init(name: String)
}
extension ObjectiveCNameType
{
	init(cursor: CXCursor, tokens: [MGCXToken], translationUnit tu: CXTranslationUnit)
	{
		self.init(name: String(clang_getCursorSpelling(cursor)) ?? "")
	}
}