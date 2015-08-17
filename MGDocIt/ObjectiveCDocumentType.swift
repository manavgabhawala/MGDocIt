//
//  ObjectiveCDocumentType.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 17/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation

protocol ObjectiveCDocumentType : DocumentType, CustomStringConvertible
{
	init(cursor: CXCursor, tokens: [MGCXToken], translationUnit: CXTranslationUnit)
}


@warn_unused_result func createObjectiveCType(cursor: CXCursor, kind: CXCursorKind, tokens: [MGCXToken], translationUnit tu: CXTranslationUnit) -> ObjectiveCDocumentType?
{
	switch kind
	{
	case CXCursor_ObjCInterfaceDecl:
		let objcInterface = ObjectiveCInterface(cursor: cursor, tokens: tokens, translationUnit: tu)
		print(objcInterface)
		return nil
	default:
		return nil
	}
}

func ~=(lhs: CXCursorKind, rhs: CXCursorKind) -> Bool
{
	return lhs.rawValue ~= rhs.rawValue
}