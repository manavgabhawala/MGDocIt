//
//  Documentable.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 16/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation

enum DocumentableType
{
	case String
	case Bool
	case Array
}

protocol Documentable
{
	var key: String { get }
	var defaultText: String { get }
	var availableTypes: [String: (String, DocumentableType)] { get }
	func stringForToken(token: String) -> String?
	func arrayForToken(token: String) -> [String]?
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
		for tokenIndex in 0..<availableTypes.count
		{
			let tokenStr = "#$\(tokenIndex)"
			let token = availableTypes[tokenStr]!
			switch token.1
			{
			case .String:
				guard let replaceRange = docText.rangeOfString(tokenStr), let replaceWith = stringForToken(tokenStr)
					else
				{
					continue
				}
				docText.replaceRange(replaceRange, with: replaceWith)
			case .Bool:
				
				let startStr = "if\(tokenStr)"
				let elseStr = "else\(tokenStr)"
				let endStr = "end\(tokenStr)"
				
				guard let boolValue = boolForToken(tokenStr), let startRange = docText.rangeOfString(startStr), let endRange = docText.rangeOfString(endStr)
					else
				{
					continue
				}
				
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
			case .Array:
				guard let arrayValue = arrayForToken(tokenStr), let tokenRange = docText.rangeOfString(tokenStr)
					else
				{
					continue
				}
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
					if arrayValue.count > 0
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
						textToReplaceWith += "\n\n"
					}
					docText.replaceRange(lineRange, with: textToReplaceWith)
				}
				else
				{
					let newString = arrayValue.reduce("", combine: { "\($0)\n\(line.stringByReplacingOccurrencesOfString(tokenStr, withString: $1))" })
					let textToReplaceWith = newString.isEmpty ? newString : newString + "\n"
					docText.replaceRange(lineRange, with: textToReplaceWith)
				}
			}
		}
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

