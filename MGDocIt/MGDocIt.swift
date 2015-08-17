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
	func handleStorageChange(file: NSURL, textStorage: NSTextView)
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
		let fullCurrentLine = currentLine.string
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
		let cursorPos = textStorage.currentCursorLocation() - triggerLength
		
		let textStorageStr = textStorage.textStorage!.string
		let str = textStorageStr.stringByRemovingRange(advance(textStorageStr.startIndex, cursorPos), end: advance(textStorageStr.startIndex, cursorPos + triggerLength))
		// TODO: Add playground support
		if file.pathExtension == "swift"
		{
			handleSwiftStorageChange(textStorage, parsedString: str, cursorPosition: cursorPos)
		}
		else
		{
			handleNonSwiftStorageChange(textStorage, parsedString: str, cursorPosition: cursorPos)
		}
		
	}
	
	func handleSwiftStorageChange(textStorage: NSTextView, parsedString str: String, cursorPosition cursorPos: Int)
	{
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
			guard self.lock.tryLock()
			else
			{
				return
			}
			defer
			{ self.lock.unlock() }
			
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
			
			guard let type = createSwiftType(structure, map: map, stringDelegate: {
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
			
			self.pasteHeaderDocFor(type, intoTextStorage: textStorage, withIndentation: indentString)
		})
	}
	
	func handleNonSwiftStorageChange(textStorage: NSTextView, parsedString str: String, cursorPosition cursorPos: Int)
	{
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
			guard self.lock.tryLock()
			else
			{
				return
			}
			defer
			{
				self.lock.unlock()
			}

			let clangIndex = clang_createIndex(0, 1)
			let opts = ["-x", "objective-c"].map { ($0 as NSString).UTF8String }
			let directory = NSURL(fileURLWithPath: NSTemporaryDirectory())
			let manager = NSFileManager()
			var fileName = NSUUID().UUIDString
			while manager.fileExistsAtPath(directory.URLByAppendingPathComponent(fileName).path!)
			{
				fileName = NSUUID().UUIDString
			}
			do
			{
				try str.writeToURL(directory.URLByAppendingPathComponent(fileName), atomically: true, encoding: NSUTF8StringEncoding)
			}
			catch
			{
				return
			}
			defer
			{
				do
				{
					try manager.removeItemAtURL(directory.URLByAppendingPathComponent(fileName))
				}
				catch
				{ }
			}
			let unit = clang_parseTranslationUnit(clangIndex, (directory.URLByAppendingPathComponent(fileName).path! as NSString).UTF8String, opts, Int32(opts.count), nil, 0, CXTranslationUnit_SkipFunctionBodies.rawValue)
			
//			let unit = clang_createTranslationUnitFromSourceFile(clangIndex, (file.path! as NSString).UTF8String, Int32(opts.count), opts, 0, nil)
			
			var selectedCursor : CXCursor?
			var topCursor = clang_getTranslationUnitCursor(unit)

			clang_visitChildrenWithBlock(topCursor) { cursor, parent in
				print(String(clang_getCursorSpelling(cursor)))
				guard Bool(Int(clang_Location_isFromMainFile(clang_getCursorLocation(cursor))))
				else
				{
					return CXChildVisit_Continue
				}
				guard Bool(Int(clang_equalCursors(parent, topCursor)))
				else
				{
					return CXChildVisit_Break
				}
				var startOffset : UInt32 = 0
				var endOffset: UInt32 = 0
				
				let extents = clang_getCursorExtent(cursor)
				
				clang_getSpellingLocation(clang_getRangeStart(extents), nil, nil, nil, &startOffset)
				clang_getSpellingLocation(clang_getRangeEnd(extents), nil, nil, nil, &endOffset)
				
				let start = Int(startOffset)
				let end = Int(endOffset)
				
				guard end >= cursorPos
				else
				{
					return CXChildVisit_Continue
				}
				guard start >= cursorPos
					else
				{
					topCursor = cursor
					return CXChildVisit_Recurse
				}
				selectedCursor = cursor
				return CXChildVisit_Break
			}
			guard let selected = selectedCursor
			else
			{
				print("No selected cursor")
				return
			}
			let kind = clang_getCursorKind(selected)
			guard kind.rawValue > CXCursor_FirstDecl.rawValue && kind.rawValue <= CXCursor_LastDecl.rawValue
			else
			{
				return
			}
			let tu = clang_Cursor_getTranslationUnit(selected)
			let tokens = self.tokenizeTranslationUnit(tu, withRange: clang_getCursorExtent(selected))
			guard let obj = createObjectiveCType(selected, kind: kind, tokens: tokens, translationUnit: tu)
			else
			{
				return
			}
		})
	}
	
	func pasteHeaderDocFor(type: DocumentType, intoTextStorage textStorage: NSTextView, withIndentation indentString: String)
	{
		dispatch_sync(dispatch_get_main_queue(), {
			let pasteboard = NSPasteboard.generalPasteboard()
			let oldData = pasteboard.stringForType(NSPasteboardTypeString)
			
			pasteboard.declareTypes([NSPasteboardTypeString], owner: nil)
			
			let docString = type.documentationWithIndentation(indentString)
			
			pasteboard.setString(docString, forType: NSPasteboardTypeString)
			
			KeyboardSimulator.defaultSimulator().beginKeyboardEvents()
			self.eventMonitor = NSEvent.addLocalMonitorForEventsMatchingMask(NSEventMask.KeyUpMask, handler: { (event) -> NSEvent? in
				if event.type == .KeyUp && event.keyCode == UInt16(kVK_Delete)
				{
					NSEvent.removeMonitor(self.eventMonitor!)
					self.eventMonitor = nil
					self.performPasteAction()
					pasteboard.setString(oldData ?? "", forType: NSPasteboardTypeString)
					let cursor = textStorage.currentCursorLocation()
					if docString.rangeOfString("<#") != nil
					{
						textStorage.selectedRange = NSRange(location: max(0, Int(cursor - docString.characters.count)), length: 0)
						KeyboardSimulator.defaultSimulator().sendKeyCode(kVK_Tab)
					}
					KeyboardSimulator.defaultSimulator().endKeyboardEvents()
					return event
				}
				else
				{
					return event
				}
			})
			KeyboardSimulator.defaultSimulator().sendKeyCode(kVK_Delete, withModifierCommand: true, alt: false, shift: false, control: false)
		})
	}
}