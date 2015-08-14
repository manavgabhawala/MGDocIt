//
//  MGDocItExtension.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 14/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation

extension MGDocIt
{
	func handleStorageChange(textStorage: NSTextView)
	{
		guard let currentLine = textStorage.textResultOfCurrentLine()
		else
		{
			// No current line
			return
		}
		let trigger = MGDocItSetting.triggerString
		
		guard currentLine.string.characters.count >= trigger.characters.count
		else
		{
			return
		}
		
		let startIndex = advance(currentLine.string.endIndex, -trigger.characters.count)
		let typedString = currentLine.string.substringFromIndex(startIndex)
		assert(trigger.characters.count == typedString.characters.count)
		guard typedString == trigger
		else
		{
			// No trigger was entered.
			return
		}
		let cursorPos = textStorage.currentCursorLocation()
		let fileToParse = File(contents: textStorage.textStorage!.string)
		
		let response = Request.EditorOpen(fileToParse).send()
		
		print(response)
		
		let map = SyntaxMap(sourceKitResponse: response)
		
		print("Cursor: \(cursorPos)")
		print(map)
		
		
	}
}