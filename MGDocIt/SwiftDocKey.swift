//
//  SwiftDocKey.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 14/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation

/// SourceKit response dictionary keys.
internal enum SwiftDocKey: String
{
	// MARK: SourceKit Keys
	
	/// Annotated declaration (String).
	case AnnotatedDeclaration = "key.annotated_decl"
	/// An array of attributes inside a structure. (XPCArray)
	case Attributes = "key.attributes"
	/// A single attribute of a structure
	case Attribute = "key.attribute"
	/// Body length (Int64).
	case BodyLength           = "key.bodylength"
	/// Body offset (Int64).
	case BodyOffset           = "key.bodyoffset"
	/// Diagnostic stage (String).
	case DiagnosticStage      = "key.diagnostic_stage"
	/// File path (String).
	case FilePath             = "key.filepath"
	/// Full XML docs (String).
	case FullXMLDocs          = "key.doc.full_as_xml"
	/// InheritedTypes (XPCArray)
	case InheritedTypes       = "key.inheritedtypes"
	/// Kind (String).
	case Kind                 = "key.kind"
	/// Length (Int64).
	case Length               = "key.length"
	/// Name (String).
	case Name                 = "key.name"
	/// Name length (Int64).
	case NameLength           = "key.namelength"
	/// Name offset (Int64).
	case NameOffset           = "key.nameoffset"
	/// Offset (Int64).
	case Offset               = "key.offset"
	/// Substructure (XPCArray).
	case Substructure         = "key.substructure"
	/// Syntax map (NSData).
	case SyntaxMap            = "key.syntaxmap"
	/// Type name (String).
	case TypeName             = "key.typename"
	
	// MARK: Custom Keys
	
	/// Column where the token's declaration begins (Int64).
	case DocColumn            = "key.doc.column"
	/// Documentation comment (String).
	case DocumentationComment = "key.doc.comment"
	/// Declaration of documented token (String).
	case DocDeclaration       = "key.doc.declaration"
	/// Discussion documentation of documented token (XPCArray).
	case DocDiscussion        = "key.doc.discussion"
	/// File where the documented token is located (String).
	case DocFile              = "key.doc.file"
	/// Line where the token's declaration begins (Int64).
	case DocLine              = "key.doc.line"
	/// Name of documented token (String).
	case DocName              = "key.doc.name"
	/// Parameters of documented token (XPCArray).
	case DocParameters        = "key.doc.parameters"
	/// Parsed declaration (String).
	case DocResultDiscussion  = "key.doc.result_discussion"
	/// Parsed scope start (Int64).
	case DocType              = "key.doc.type"
	/// Parsed scope start end (Int64).
	case DocUSR               = "key.doc.usr"
	/// Result discussion documentation of documented token (XPCArray).
	case ParsedDeclaration    = "key.parsed_declaration"
	/// Type of documented token (String).
	case ParsedScopeEnd       = "key.parsed_scope.end"
	/// USR of documented token (String).
	case ParsedScopeStart     = "key.parsed_scope.start"
	
	
	// MARK: Typed SwiftDocKey Getters
	
	/**
	Returns the typed value of a dictionary key.
	
	- parameter key:        SwiftDoctKey to get from the dictionary.
	- parameter dictionary: Dictionary to get value from.
	
	- returns: Typed value of a dictionary key.
	*/
	private static func get<T: XPCRepresentable>(key: SwiftDocKey, _ dictionary: XPCDictionary) -> T? {
		return dictionary[key.rawValue] as? T
	}
	
	/**
	Get kind string from dictionary.
	
	- parameter dictionary: Dictionary to get value from.
	
	- returns: Kind string if successful.
	*/
	internal static func getKind(dictionary: XPCDictionary) -> SwiftDeclarationKind? {
		return SwiftDeclarationKind(raw: get(.Kind, dictionary))
	}
	
	internal static func getAttributes(dictionary: XPCDictionary) -> XPCArray?
	{
		return get(.Attributes, dictionary)
	}
	
	internal static func getAttribute(dictionary: XPCDictionary?) -> SwiftDeclarationKind?
	{
		guard let dict = dictionary
		else
		{
			return nil
		}
		return SwiftDeclarationKind(raw: get(.Attribute, dict))
	}
	
	/**
	Get syntax map data from dictionary.
	
	- parameter dictionary: Dictionary to get value from.
	
	- returns: Syntax map data if successful.
	*/
	internal static func getSyntaxMap(dictionary: XPCDictionary) -> NSData? {
		return get(.SyntaxMap, dictionary)
	}
	
	/**
	Get offset int from dictionary.
	
	- parameter dictionary: Dictionary to get value from.
	
	- returns: Offset int if successful.
	*/
	internal static func getOffset(dictionary: XPCDictionary) -> Int64? {
		return get(.Offset, dictionary)
	}
	
	/**
	Get length int from dictionary.
	
	- parameter dictionary: Dictionary to get value from.
	
	- returns: Length int if successful.
	*/
	internal static func getLength(dictionary: XPCDictionary) -> Int64? {
		return get(.Length, dictionary)
	}
	
	/**
	Get type name string from dictionary.
	
	- parameter dictionary: Dictionary to get value from.
	
	- returns: Type name string if successful.
	*/
	internal static func getTypeName(dictionary: XPCDictionary) -> String? {
		return get(.TypeName, dictionary)
	}
	
	/**
	Get annotated declaration string from dictionary.
	
	- parameter dictionary: Dictionary to get value from.
	
	- returns: Annotated declaration string if successful.
	*/
	internal static func getAnnotatedDeclaration(dictionary: XPCDictionary) -> String? {
		return get(.AnnotatedDeclaration, dictionary)
	}
	
	/**
	Get substructure array from dictionary.
	
	- parameter dictionary: Dictionary to get value from.
	
	- returns: Substructure array if successful.
	*/
	internal static func getSubstructure(dictionary: XPCDictionary) -> XPCArray? {
		return get(.Substructure, dictionary)
	}
	
	/**
	Get name offset int from dictionary.
	
	- parameter dictionary: Dictionary to get value from.
	
	- returns: Name offset int if successful.
	*/
	internal static func getNameOffset(dictionary: XPCDictionary) -> Int64? {
		return get(.NameOffset, dictionary)
	}
	
	/**
	Get length int from dictionary.
	
	- parameter dictionary: Dictionary to get value from.
	
	- returns: Length int if successful.
	*/
	internal static func getNameLength(dictionary: XPCDictionary) -> Int64? {
		return get(.NameLength, dictionary)
	}
	
	internal static func getName(dictionary: XPCDictionary) -> String?
	{
		return get(.Name, dictionary)
	}
	
	internal static func getInheritedTypes(dictionary: XPCDictionary) -> [String]?
	{
		guard let inherited = dictionary[InheritedTypes.rawValue] as? XPCArray
		else
		{
			return nil
		}
		return inherited.map { SwiftDocKey.getName($0 as! XPCDictionary)! }
	}
	
	/**
	Get body offset int from dictionary.
	
	- parameter dictionary: Dictionary to get value from.
	
	- returns: Body offset int if successful.
	*/
	internal static func getBodyOffset(dictionary: XPCDictionary) -> Int64? {
		return get(.BodyOffset, dictionary)
	}
	
	/**
	Get body length int from dictionary.
	
	- parameter dictionary: Dictionary to get value from.
	
	- returns: Body length int if successful.
	*/
	internal static func getBodyLength(dictionary: XPCDictionary) -> Int64? {
		return get(.BodyLength, dictionary)
	}
	
	/**
	Get file path string from dictionary.
	
	- parameter dictionary: Dictionary to get value from.
	
	- returns: File path string if successful.
	*/
	internal static func getFilePath(dictionary: XPCDictionary) -> String? {
		return get(.FilePath, dictionary)
	}
	
	/**
	Get full xml docs string from dictionary.
	
	- parameter dictionary: Dictionary to get value from.
	
	- returns: Full xml docs string if successful.
	*/
	internal static func getFullXMLDocs(dictionary: XPCDictionary) -> String? {
		return get(.FullXMLDocs, dictionary)
	}
}
