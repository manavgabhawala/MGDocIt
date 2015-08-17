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
	init(cursor: CXCursor, tokens: [MGCXToken], translationUnit tu: CXTranslationUnit)
}
extension ObjectiveCDocumentType
{
	var description: String { return documentationWithIndentation("") }
}

@warn_unused_result func createObjectiveCType(kind: CXCursorKind) -> ObjectiveCDocumentType.Type?
{
	switch kind
	{
	case CXCursor_ObjCInterfaceDecl:
		return ObjectiveCInterface.self
	case CXCursor_ObjCCategoryDecl:
		return nil
	default:
		return nil
	}
}

func ~=(lhs: CXCursorKind, rhs: CXCursorKind) -> Bool
{
	return lhs.rawValue ~= rhs.rawValue
}