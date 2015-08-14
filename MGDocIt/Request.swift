//
//  Request.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 14/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation

/// SourceKit UID to String map.
private var uidStringMap = [UInt64: String]()

/**
Cache SourceKit requests for strings from UIDs

- parameter uid: UID received from sourcekitd* responses

- returns: Cached UID string if available, other
*/
internal func stringForSourceKitUID(uid: UInt64) -> String?
{
	if uid < 4300000000
	{
		// UID's are always higher than 4.3M
		return nil
	}
	else if let string = uidStringMap[uid]
	{
		return string
	}
	else
	{
		if let uidString = String(UTF8String: sourcekitd_uid_get_string_ptr(uid))
		{
			uidStringMap[uid] = uidString
			return uidString
		}
	}
	return nil
}

/// Represents a SourceKit request.
public enum Request
{
	/// An `editor.open` request for the given File.
	case EditorOpen(File)
	/// A `cursor.info` request for an offset in the given file, using the `arguments` given.
	case CursorInfo(file: String, offset: Int64, arguments: [String])
	/// A custom request by passing in the xpc_object_t directly.
	case CustomRequest(xpc_object_t)
	
	/// xpc_object_t version of the Request to be sent to SourceKit.
	private var xpcValue: xpc_object_t
	{
		switch self {
		case .EditorOpen(let file):
			let openRequestUID = sourcekitd_uid_get_from_cstr("source.request.editor.open")
			if let path = file.path {
				return toXPC([
					"key.request": openRequestUID,
					"key.name": path,
					"key.sourcefile": path
					])
			} else {
				return toXPC([
					"key.request": openRequestUID,
					"key.name": String(file.contents.hash),
					"key.sourcetext": file.contents
					])
			}
		case .CursorInfo(let file, let offset, let arguments):
			return toXPC([
				"key.request": sourcekitd_uid_get_from_cstr("source.request.cursorinfo"),
				"key.name": file,
				"key.sourcefile": file,
				"key.offset": offset,
				"key.compilerargs": (arguments.map { $0 as XPCRepresentable } as XPCArray)
				])
		case .CustomRequest(let request):
			return request
		}
	}
	
	/**
	Sends the request to SourceKit and return the response as an XPCDictionary.
	
	- returns: SourceKit output as an XPC dictionary.
	*/
	public func send() -> XPCDictionary
	{
		guard let response = sourcekitd_send_request_sync(xpcValue)
		else
		{
			fatalError("SourceKit response nil for request \(self)")
		}
		return replaceUIDsWithSourceKitStrings(fromXPC(response))
	}

}


/**
Get c string representation of a uid
*/
@asmname("sourcekitd_uid_get_string_ptr") internal func sourcekitd_uid_get_string_ptr(_: UInt64) -> UnsafePointer<CChar>

/**
Send a synchronous request to SourceKit. Response is returned as an xpc_object_t. Typically an XPC dictionary.
*/
@asmname("sourcekitd_send_request_sync") internal func sourcekitd_send_request_sync(_: xpc_object_t?) -> xpc_object_t?

/**
Get uid from its c string representation.
*/
@asmname("sourcekitd_uid_get_from_cstr") internal func sourcekitd_uid_get_from_cstr(_: UnsafePointer<CChar>) -> UInt64