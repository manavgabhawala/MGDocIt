//
//  MGDocItExtension.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 14/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation
import Carbon.HIToolbox

extension MGDocIt
{
	func handleStorageChange(textStorage: NSTextView)
	{
		if mainMonitor == nil
		{
			mainMonitor = NSEvent.addLocalMonitorForEventsMatchingMask(NSEventMask.KeyDownMask, handler: { (event) -> NSEvent? in
				let trigger = MGDocItSetting.triggerString
				let triggerChar = trigger.substringFromIndex(trigger.endIndex.predecessor()).utf8.first!.value
				if event.type == .KeyDown && self.keyCodeForChar(Int8(triggerChar)) == event.keyCode
				{
					self.lastCharTyped = true
				}
				else
				{
					self.lastCharTyped = false
				}
				return event
			})
		}
		guard lastCharTyped
		else
		{
			return
		}
		guard let currentLine = textStorage.textResultOfCurrentLine()
		else
		{
			// No current line
			return
		}
		currentLine.string.trimWhitespaceOnLeft()
		let trigger = MGDocItSetting.triggerString
		let triggerLength = trigger.characters.count
		guard currentLine.string.characters.count >= triggerLength
		else
		{
			return
		}
		
		guard currentLine.string == trigger
		else
		{
			// No trigger was entered.
			return
		}
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
			guard self.lock.tryLock()
			else
			{
				return
			}
			defer
			{ self.lock.unlock() }
			
			let cursorPos = textStorage.currentCursorLocation() - triggerLength
			
			let textStorageStr = textStorage.textStorage!.string
			let str = textStorageStr.stringByRemovingRange(advance(textStorageStr.startIndex, cursorPos), end: advance(textStorageStr.startIndex, cursorPos + triggerLength))
			
			let fileToParse = File(contents: str)
			
			let response = Request.EditorOpen(fileToParse).send()
			guard let structure = findAllSubstructures(response, withCursorPosition: cursorPos)
			else
			{
				// Ignore non documentable kinds.
				return
			}
			if let attributes = SwiftDocKey.getAttributes(structure)
			{
				for attribute in attributes
				{
					guard let attr = SwiftDocKey.getAttribute(attribute as? XPCDictionary)
					else
					{
						print("Unknown attribute found: \(attribute)")
						continue
					}
					guard attr != SwiftDeclarationKind.HeaderDocs
					else
					{
						return
					}
				}
			}
			
			let map = SyntaxMap(sourceKitResponse: response)
			guard let nextTokenIndex = map.tokens.binarySearch({ $0.offset }, compareTo: cursorPos)
			else
			{
				return
			}
			let nextToken = map.tokens[nextTokenIndex]
			guard nextToken.type != .DocComment && nextToken.type != .DocCommentField
			else
			{
				return
			}
			if nextTokenIndex > 1
			{
				let previousTokenType = map.tokens[nextTokenIndex - 1].type
				guard previousTokenType != .DocComment && previousTokenType != .DocCommentField
				else
				{
					return
				}
			}
			let startInd = advance(str.startIndex, nextToken.offset)
			let nextWord = str.substringWithRange(Range<String.Index>(start: startInd, end: advance(startInd, nextToken.length)))
			// Since import statements don't show up in the AST.
			guard nextWord != "import"
			else
			{
				return
			}
			
			guard let type = createType(structure, map: map, stringDelegate: {
				let startLoc = advance(str.startIndex, $0)
				let range = Range<String.Index>(start: startLoc, end: advance(startLoc, $1))
				return str.substringWithRange(range)
			})
			else
			{
				return
			}
			
			let structOffset = advance(str.startIndex, Int(SwiftDocKey.getOffset(structure)!))
			let indentPoint = str.rangeOfCharacterFromSet(NSCharacterSet.newlineCharacterSet(), options: NSStringCompareOptions.BackwardsSearch, range: Range<String.Index>(start: str.startIndex, end: structOffset))
			let fullIndentString = str.substringWithRange(Range<String.Index>(start: indentPoint?.endIndex ?? structOffset, end: structOffset))
			var endIndex = fullIndentString.startIndex
			for char in fullIndentString.unicodeScalars
			{
				guard NSCharacterSet.whitespaceCharacterSet().longCharacterIsMember(char.value)
				else
				{
					break
				}
				endIndex = endIndex.successor()
			}
			let indentString = fullIndentString.substringWithRange(Range<String.Index>(start: fullIndentString.startIndex, end: endIndex))
			
			dispatch_sync(dispatch_get_main_queue(), {
				let pasteboard = NSPasteboard.generalPasteboard()
				let oldData = pasteboard.stringForType(NSPasteboardTypeString)
				
				pasteboard.declareTypes([NSPasteboardTypeString], owner: nil)
				
				let docString = type.documentationWithIndentation(indentString)
				
				pasteboard.setString(docString, forType: NSPasteboardTypeString)
				
				KeyboardSimulator.defaultSimulator().beginKeyboardEvents()
				KeyboardSimulator.defaultSimulator().sendKeyCode(kVK_Delete, withModifierCommand: true, alt: false, shift: false, control: false)
				
				
				self.eventMonitor = NSEvent.addLocalMonitorForEventsMatchingMask(NSEventMask.KeyDownMask, handler: { (event) -> NSEvent? in
					if event.type == .KeyDown && event.keyCode == UInt16(kVK_F19)
					{
						NSEvent.removeMonitor(self.eventMonitor!)
						self.eventMonitor = nil
						
						pasteboard.setString(oldData ?? "", forType: NSPasteboardTypeString)
						let cursor = textStorage.currentCursorLocation()
						if docString.rangeOfString("<#") != nil
						{
							textStorage.selectedRange = NSRange(location: max(0, Int(cursor - docString.characters.count)), length: 0)
							KeyboardSimulator.defaultSimulator().sendKeyCode(kVK_Tab)
						}
						KeyboardSimulator.defaultSimulator().endKeyboardEvents()
						
						return nil
					}
					else
					{
						return event
					}
				})
				
				// FIXME: Use paste from preferences instead.
				let kKeyVCode = MGDocItSetting.useDvorakLayout ? kVK_ANSI_Period : kVK_ANSI_V
				
				KeyboardSimulator.defaultSimulator().sendKeyCode(kKeyVCode, withModifierCommand: true, alt: false, shift: false, control: false)
				KeyboardSimulator.defaultSimulator().sendKeyCode(kVK_F19)
			})
		})
	}
}