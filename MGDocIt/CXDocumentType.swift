//
//  CXDocumentType.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 17/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation

protocol CXDocumentType : DocumentType, CustomStringConvertible
{
	init(cursor: CXCursor, tokens: [MGCXToken], translationUnit tu: CXTranslationUnit)
}
extension CXDocumentType
{
	var description: String { return documentationWithIndentation("") }
}

@warn_unused_result func createCXType(kind: CXCursorKind) -> CXDocumentType.Type?
{
	print(String(clang_getCursorKindSpelling(kind)))
	switch kind
	{
	case CXCursor_ObjCClassMethodDecl, CXCursor_ObjCInstanceMethodDecl, CXCursor_FunctionDecl, CXCursor_CXXMethod, CXCursor_Constructor, CXCursor_Destructor, CXCursor_ConversionFunction:
		return CXFunction.self
	case CXCursor_ObjCInterfaceDecl:
		return ObjectiveCInterface.self
	case CXCursor_ObjCCategoryDecl:
		return ObjectiveCCategory.self
	case CXCursor_ObjCProtocolDecl:
		return ObjectiveCProtocol.self
	case CXCursor_ObjCPropertyDecl, CXCursor_ObjCIvarDecl, CXCursor_VarDecl:
		return ObjectiveCVar.self
	case CXCursor_FieldDecl:
		return CField.self
	case CXCursor_StructDecl:
		return CXStruct.self
	case CXCursor_UnionDecl:
		return CXUnion.self
	case CXCursor_EnumDecl:
		return CXEnum.self
	case CXCursor_EnumConstantDecl:
		return CXEnumElement.self
	case CXCursor_TypedefDecl:
		return CXTypedef.self
	case CXCursor_Namespace:
		return CNamespace.self
	case CXCursor_ClassDecl:
		return CPPClass.self
	default:
		return nil
	}
}

func ~=(lhs: CXCursorKind, rhs: CXCursorKind) -> Bool
{
	return lhs.rawValue ~= rhs.rawValue
}