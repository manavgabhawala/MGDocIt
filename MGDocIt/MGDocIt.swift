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
	/// Call this function when the text's storage has changed. This function handles accepting a trigger and then determines which sub handler to invoke based on the language
	///
	/// - Parameter file: This is a parameter of type `NSURL`. The file that is currently open in the editor. This is used to determine the sub handler to call for the language.
	/// - Parameter textStorage: This is a parameter of type `NSTextView`. The TextView whose storage was changed.
	///
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
		let str = textStorageStr.stringByRemovingRange(textStorageStr.startIndex.advancedBy(cursorPos), end: textStorageStr.startIndex.advancedBy(cursorPos + triggerLength))
		
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
	
	/// A sub handler that handles changes for swift source code changes. It communicates with SourceKit to get the AST.
	///
	/// - Parameter textStorage: This is a parameter of type `NSTextView`. The storage who was changed. This parameter is used to pass to the `pasteHeaderDocFor:` function.
	/// - Parameter str: This is a parameter of type `String`. The string which is swift source code that should be parsed.
	/// - Parameter cursorPos: This is a parameter of type `Int`. The current position of the cursor offset for the removal of the newly inserted trigger.
	///
	///
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
			let startInd = str.startIndex.advancedBy(nextToken.offset)
			let nextWord = str.substringWithRange(Range<String.Index>(start: startInd, end: startInd.advancedBy(nextToken.length)))
			// Since import statements don't show up in the AST.
			guard nextWord != "import"
			else
			{
				return
			}
			
			guard let type = createSwiftType(SwiftDocKey.getKind(structure))
			else
			{
				return
			}
			
			let doc = type.init(dict: structure, map: map, stringDelegate: {
				let startLoc = str.startIndex.advancedBy($0 - 1)
				let range = Range<String.Index>(start: startLoc, end: startLoc.advancedBy($1))
				let str = str.substringWithRange(range)
				return str
			})
			let indentString = self.calculateIndentString(fromString: str, withOffset: Int(SwiftDocKey.getOffset(structure)!))
			
			self.pasteHeaderDocFor(doc, intoTextStorage: textStorage, withIndentation: indentString)
		})
	}
	
	/// A sub handler that handles changes for any non-swift source code changes like C, C++ and ObjC. It communicates with clang and the llvm to get the AST.
	///
	/// - Parameter textStorage: This is a parameter of type `NSTextView`. The storage who was changed. This parameter is used to pass to the `pasteHeaderDocFor:` function.
	/// - Parameter str: This is a parameter of type `String`. The string which is C, C++ or ObjC source code that should be parsed.
	/// - Parameter cursorPos: This is a parameter of type `Int`. The current position of the cursor offset for the removal of the newly inserted trigger.
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
			let unit = clang_parseTranslationUnit(clangIndex, (directory.URLByAppendingPathComponent(fileName).path! as NSString).UTF8String, opts, Int32(opts.count), nil, 0, CXTranslationUnit_None.rawValue)
			
			var selectedCursor : CXCursor?
			
			var topCursor = clang_getTranslationUnitCursor(unit)

			clang_visitChildrenWithBlock(topCursor) { cursor, parent in
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
				print(String(clang_getCursorSpelling(cursor)))
				guard end > cursorPos
				else
				{
					return CXChildVisit_Continue
				}
				
				guard start >= cursorPos
				else
				{
					topCursor = cursor
					let range = Range<String.Index>(start: str.startIndex.advancedBy(start - 1), end: str.startIndex.advancedBy(end))
					print(str.substringWithRange(range))
					print(String(clang_getCursorSpelling(cursor)))
					return CXChildVisit_Recurse
				}
				selectedCursor = cursor
				return CXChildVisit_Break
			}
			guard var selected = selectedCursor
			else
			{
				print("No selected cursor")
				return
			}
			print(String(clang_getCursorSpelling(selected)))
			let language = clang_getCursorLanguage(selected)
			if language.rawValue != CXLanguage_ObjC.rawValue && language.rawValue != CXLanguage_Invalid.rawValue
			{
				let opt = CXLanguage_C.rawValue == language.rawValue ? "c" : "c++"
				let newOpt = ["-x", opt].map { ($0 as NSString).UTF8String }
				let unit = clang_parseTranslationUnit(clangIndex, (directory.URLByAppendingPathComponent(fileName).path! as NSString).UTF8String, newOpt, Int32(newOpt.count), nil, 0, CXTranslationUnit_None.rawValue)
				let oldSelected = selected
				selected = clang_getCursor(unit, clang_getCursorLocation(selected))
				if clang_getCursorKind(selected).rawValue == CXCursor_UnexposedDecl.rawValue
				{
					selected = oldSelected
				}
			}
			var isCommented = false
			let kind = clang_getCursorKind(selected)
			
			clang_visitChildrenWithBlock(selected, { (child, _) -> CXChildVisitResult in
				guard clang_getCursorKind(child).rawValue == kind.rawValue
				else
				{
					return CXChildVisit_Recurse
				}
				guard clang_Comment_getKind(clang_Cursor_getParsedComment(selected)).rawValue == CXComment_Null.rawValue
					else
				{
					isCommented = true
					return CXChildVisit_Break
				}
				return CXChildVisit_Recurse
			})
			
			let comment = clang_Cursor_getParsedComment(selected)
			
			if clang_Comment_getKind(comment).rawValue != CXComment_Null.rawValue
			{
				isCommented = true
			}
			guard !isCommented
			else
			{
				return
			}
			print(String(clang_getCursorSpelling(selected)))
			// By only using the type we are saving on creating the tokens spuriously.
			guard let type = createCXType(kind)
			else
			{
				return
			}
			let tu = clang_Cursor_getTranslationUnit(selected)
			let tokens = self.tokenizeTranslationUnit(tu, withRange: clang_getCursorExtent(selected))
			var cursorOff : UInt32 = 0
			clang_getSpellingLocation(clang_getCursorLocation(selected), nil, nil, nil, &cursorOff)
			
			let doc = type.init(cursor: selected, tokens: tokens, translationUnit: tu)
			let indentString = self.calculateIndentString(fromString: str, withOffset: Int(cursorOff))
			
			self.pasteHeaderDocFor(doc, intoTextStorage: textStorage, withIndentation: indentString)
		})
	}
	
	/// This function handles calculating an indent string for any source code.
	///
	/// - Parameter str: This is a parameter of type `String`. The string from which we need to calculate the indentation. This is the entire source code representation.
	/// - Parameter offset: This is a parameter of type `Int`. The offset is the structure which is being documented's absolute offset in the file.
	///
	/// - Returns: The indent string. This string will either be empty or full of ` ` and `\t` characters. No characters not in the `NSCharacterSet.whitespaceCharacterSet()` will be included.
	@warn_unused_result func calculateIndentString(fromString str: String, withOffset offset: Int) -> String
	{
		let structOffset = str.startIndex.advancedBy(offset)
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
		return fullIndentString.substringWithRange(Range<String.Index>(start: fullIndentString.startIndex, end: endIndex))
	}
	
	/// Paste's the header documentation into the text storage with the indentation and handles everything from deleting the trigger string, getting the header doc and pasting it in, resetting the pasteboard and then tabbing into the first tokenized field if one exists.
	///
	/// - Parameter document: This is a parameter of type `DocumentType`. The document type using which the documentation string can be calculated.
	/// - Parameter textStorage: This is a parameter of type `NSTextView`. The text view into which to paste the string and then tab into the first tokenizable field.
	/// - Parameter indentString: This is a parameter of type `String`. The indentation that should be applied to every line before pasting it in. This is calcualated by the document by using the `documentationWithIndentation:` method.
	func pasteHeaderDocFor(document: DocumentType, intoTextStorage textStorage: NSTextView, withIndentation indentString: String)
	{
		dispatch_sync(dispatch_get_main_queue(), {
			let pasteboard = NSPasteboard.generalPasteboard()
			let oldData = pasteboard.stringForType(NSPasteboardTypeString)
			
			pasteboard.declareTypes([NSPasteboardTypeString], owner: nil)
			
			let docString = document.documentationWithIndentation(indentString)
			
			pasteboard.setString(docString, forType: NSPasteboardTypeString)
			
			KeyboardSimulator.defaultSimulator().beginKeyboardEvents()
			self.eventMonitor = NSEvent.addLocalMonitorForEventsMatchingMask(NSEventMask.KeyUpMask, handler: { (event) -> NSEvent? in
				if event.type == .KeyUp && event.keyCode == UInt16(kVK_Delete)
				{
					NSEvent.removeMonitor(self.eventMonitor!)
					self.eventMonitor = nil
					let oldCursor = textStorage.currentCursorLocation()
					self.performPasteAction()
					pasteboard.setString(oldData ?? "", forType: NSPasteboardTypeString)
					if docString.rangeOfString("<#") != nil
					{
						textStorage.selectedRange = NSRange(location: oldCursor, length: 0)
						KeyboardSimulator.defaultSimulator().sendKeyCode(kVK_Tab)
					}
					KeyboardSimulator.defaultSimulator().endKeyboardEvents()
				}
				return event
			})
			KeyboardSimulator.defaultSimulator().sendKeyCode(kVK_Delete, withModifierCommand: true, alt: false, shift: false, control: false)
		})
	}
}