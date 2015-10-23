//
//  Documentable.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 16/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation

/// The types that are documentable. These are the only kinds of tokens that the `Documentable` protocol can parse and render properly.
enum DocumentableType
{
	case String
	case Bool
	case Array
}

/// A protocol which types conform to, to be able to be documented.
protocol DocumentType
{
	/// The documentation for a particular type.
	///
	/// - Parameter indentation: This is a parameter of type `String`. The indentation to use while creating the documentation
	/// - Returns: The complete documentation string.
	func documentationWithIndentation(indentation: String) -> String
}

/// A protocol which if types conform to can handle parsing, replacing tokens and using custom user defined text.
protocol Documentable: DocumentType
{
	/// The key for the type which is used in conjunction with NSUserDefaults to set a custom string.
	var key: String { get }
	/// The default text to use if no user defined type is available.
	var defaultText: String { get }
	/// A dictionary of tokens that can be used in conjunction with this type. Each value of the dictionary is a tuple with a user displayable name and the type that the key returns.
	var availableTokens: [String: (String, DocumentableType)] { get }
	
	/// When an availableToken returns DocumentableType.String, this function will be invoked with that token to get the dynamic value represented for that token for the doc.
	///
	/// - Parameter token: This is a parameter of type `String`. The token passed through available tokens.
	///
	/// - Returns: A string represented by the token. Nil if the token doesn't represent a String
	func stringForToken(token: String) -> String?
	
	/// When an availableToken returns DocumentableType.Array, this function will be invoked with that token to get the dynamic value represented for that token for the doc.
	///
	/// - Parameter token: This is a parameter of type `String`. The token passed through available tokens.
	///
	/// - Returns: An array of strings represented by the token. Nil if the token doesn't represent an array
	func arrayForToken(token: String) -> [String]?
	
	/// When an availableToken returns DocumentableType.Bool, this function will be invoked with that token to get the dynamic value represented for that token for the doc.
	///
	/// - Parameter token: This is a parameter of type `String`. The token passed through available tokens.
	///
	/// - Returns: A boolean represented by the token. Nil if the token doesn't represent a Bool
	func boolForToken(token: String) -> Bool?
}
extension Documentable
{
	func documentationWithIndentation(indentation: String) -> String
	{
		let begin : String
		let beginningDoc = MGDocItSetting.beginningDoc
		if beginningDoc.isEmpty
		{
			begin = ""
		}
		else
		{
			begin = indentation + beginningDoc + "\n"
		}
		
		let end : String
		let endingDoc = MGDocItSetting.endingDoc
		if endingDoc.isEmpty
		{
			end = ""
		}
		else
		{
			end = "\n" + indentation + endingDoc
		}
		
		var docText = MGDocItSetting.getCustomDocumentationForKey(key, defaultText: defaultText)
		for tokenIndex in 0..<availableTokens.count
		{
			let tokenStr = "#$\(tokenIndex)"
			let token = availableTokens[tokenStr]!
			switch token.1
			{
			case .String:
				while let replaceRange = docText.rangeOfString(tokenStr), let replaceWith = stringForToken(tokenStr)
				{
					docText.replaceRange(replaceRange, with: replaceWith)
				}
				continue
			case .Bool:
				
				let startStr = "if\(tokenStr)"
				let elseStr = "else\(tokenStr)"
				let endStr = "end\(tokenStr)"
				while let boolValue = boolForToken(tokenStr), let startRange = docText.rangeOfString(startStr), let endRange = docText.rangeOfString(endStr)
				{
					if let half = docText.rangeOfString(elseStr)
					{
						if boolValue
						{
							docText.removeRange(half.startIndex, end: endRange.endIndex)
							docText.removeRange(startRange)
						}
						else
						{
							docText.removeRange(endRange)
							docText.removeRange(startRange.startIndex, end: half.endIndex)
						}
					}
					else
					{
						if boolValue
						{
							docText.removeRange(endRange)
							docText.removeRange(startRange)
						}
						else
						{
							docText.removeRange(startRange.startIndex, end: endRange.endIndex)
						}
					}

				}
				continue
				
			case .Array:
				while let arrayValue = arrayForToken(tokenStr), let tokenRange = docText.rangeOfString(tokenStr)
				{
					if let singleTokenRange = docText.rangeOfString("<\(tokenStr)>")
					{
						// Specially wrapped in < > then expand in place
						if arrayValue.count == 0
						{
							docText.replaceRange(singleTokenRange, with: "<#Description#>")
						}
						else
						{
							let str = arrayValue.reduce("", combine: { "\($0)\($1), " })
							let replaceTok = str.substringToIndex(advance(str.endIndex, -2))
							docText.replaceRange(singleTokenRange, with: "\(replaceTok)")
						}
						continue
					}
					let (line, lineRange) = docText.lineContainingRange(tokenRange)
					if tokenStr == "#$1" && line.rangeOfString("#$2") != nil, let typeArrayValue = arrayForToken("#$2")
					{
						let lineTemplate = line.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
						// Special function case
						assert(arrayValue.count == typeArrayValue.count)
						var textToReplaceWith = ""
						if arrayValue.count > 0 && !docText.isEmpty
						{
							textToReplaceWith += "\n"
						}
						for (i, elem) in arrayValue.enumerate()
						{
							textToReplaceWith += "\n"
							textToReplaceWith += lineTemplate.stringByReplacingOccurrencesOfString(tokenStr, withString: elem).stringByReplacingOccurrencesOfString("#$2", withString: typeArrayValue[i])
						}
						if !textToReplaceWith.isEmpty
						{
							textToReplaceWith += "\n"
						}
						docText.replaceRange(lineRange, with: textToReplaceWith)
					}
					else
					{
						let initial = docText.isEmpty ? "" : "\n"
						let newString = arrayValue.reduce(initial, combine: { "\($0)\(line.stringByReplacingOccurrencesOfString(tokenStr, withString: $1))\n" })
						docText.replaceRange(lineRange, with: newString)
					}
				}
				continue
			}
		}
		docText = docText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
		let prefix : String
		if docText.rangeOfString("// ") == nil
		{
			prefix = indentation + MGDocItSetting.linePrefix
		}
		else
		{
			prefix = indentation
		}
		return begin + prefix + docText.stringByReplacingOccurrencesOfString("\n", withString: "\n\(prefix)") + end
	}
}

