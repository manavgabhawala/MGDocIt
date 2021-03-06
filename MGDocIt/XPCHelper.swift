/// <#Description of enum SwiftDocKey #>//
//  XPCHelper.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 14/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation
import XPC

/// Protocol to group Swift/Objective-C types that can be represented as XPC types.
public protocol XPCRepresentable : Any {}
extension Array : XPCRepresentable {}
extension Dictionary: XPCRepresentable {}
extension String: XPCRepresentable {}
extension NSDate: XPCRepresentable {}
extension NSData: XPCRepresentable {}
extension UInt64: XPCRepresentable {}
extension Int64: XPCRepresentable {}
extension Double: XPCRepresentable {}
extension Bool: XPCRepresentable {}
extension NSFileHandle: XPCRepresentable {}
extension CFBooleanRef: XPCRepresentable {}
extension NSUUID: XPCRepresentable {}

/// Possible XPC types
public enum XPCType {
	case Array, Dictionary, String, Date, Data, UInt64, Int64, Double, Bool, FileHandle, UUID
}

/// Map xpc_type_t (COpaquePointer's) to their appropriate XPCType enum value.
let typeMap: [xpc_type_t: XPCType] = [
	// FIXME: Use xpc_type_t constants as keys once http://openradar.me/19776929 has been fixed.
	xpc_get_type(xpc_array_create(nil, 0)): .Array,
	xpc_get_type(xpc_dictionary_create(nil, nil, 0)): .Dictionary,
	xpc_get_type(xpc_string_create("")): .String,
	xpc_get_type(xpc_date_create(0)): .Date,
	xpc_get_type(xpc_data_create(nil, 0)): .Data,
	xpc_get_type(xpc_uint64_create(0)): .UInt64,
	xpc_get_type(xpc_int64_create(0)): .Int64,
	xpc_get_type(xpc_double_create(0)): .Double,
	xpc_get_type(xpc_bool_create(true)): .Bool,
	xpc_get_type(xpc_fd_create(0)): .FileHandle,
	xpc_get_type(xpc_uuid_create([UInt8](count: 16, repeatedValue: 0))): .UUID
]

/// Type alias to simplify referring to an Array of XPCRepresentable objects.
public typealias XPCArray = [XPCRepresentable]
/// Type alias to simplify referring to a Dictionary of XPCRepresentable objects with String keys.
public typealias XPCDictionary = [String: XPCRepresentable]

// MARK: General

/**
Converts an XPCRepresentable object to its xpc_object_t value.
- parameter: object XPCRepresentable object to convert.
- returns: Converted XPC object.
*/
public func toXPCGeneral(object: XPCRepresentable) -> xpc_object_t?
{
	switch object {
	case let object as XPCArray:
		return toXPC(object)
	case let object as XPCDictionary:
		return toXPC(object)
	case let object as String:
		return toXPC(object)
	case let object as NSDate:
		return toXPC(object)
	case let object as NSData:
		return toXPC(object)
	case let object as UInt64:
		return toXPC(object)
	case let object as Int64:
		return toXPC(object)
	case let object as Double:
		return toXPC(object)
	case let object as Bool:
		return toXPC(object)
	case let object as NSFileHandle:
		return toXPC(object)
	case let object as NSUUID:
		return toXPC(object)
	default:
		// Should never happen because we've checked all XPCRepresentable types
		fatalError("Unexpected XPC type \(object.dynamicType)")
	}
}

/**
Converts an xpc_object_t to its Swift value (XPCRepresentable).
- parameter: xpcObject xpc_object_t object to to convert.
- returns: Converted XPCRepresentable object.
*/
public func fromXPCGeneral(xpcObject: xpc_object_t) -> XPCRepresentable?
{
	let type = xpc_get_type(xpcObject)
	switch typeMap[type]! {
	case .Array:
		return fromXPC(xpcObject) as XPCArray
	case .Dictionary:
		return fromXPC(xpcObject) as XPCDictionary
	case .String:
		return fromXPC(xpcObject) as String!
	case .Date:
		return fromXPC(xpcObject) as NSDate!
	case .Data:
		return fromXPC(xpcObject) as NSData!
	case .UInt64:
		return fromXPC(xpcObject) as UInt64!
	case .Int64:
		return fromXPC(xpcObject) as Int64!
	case .Double:
		return fromXPC(xpcObject) as Double!
	case .Bool:
		return fromXPC(xpcObject) as Bool!
	case .FileHandle:
		return fromXPC(xpcObject) as NSFileHandle!
	case .UUID:
		return fromXPC(xpcObject) as NSUUID!
	}
}

// MARK: Array

/**
Converts an Array of XPCRepresentable objects to its xpc_object_t value.
- parameter: array Array of XPCRepresentable objects to convert.
- returns: Converted XPC array.
*/
public func toXPC(array: XPCArray) -> xpc_object_t
{
	let xpcArray = xpc_array_create(nil, 0)
	for value in array {
		if let xpcValue = toXPCGeneral(value) {
			xpc_array_append_value(xpcArray, xpcValue)
		}
	}
	return xpcArray
}

/**
Converts an xpc_object_t array to an Array of XPCRepresentable objects.
- parameter: xpcObject XPC array to to convert.
- returns: Converted Array of XPCRepresentable objects.
*/
public func fromXPC(xpcObject: xpc_object_t) -> XPCArray
{
	var array = XPCArray()
	xpc_array_apply(xpcObject) { index, value in
		if let value = fromXPCGeneral(value) {
			array.insert(value, atIndex: Int(index))
		}
		return true
	}
	return array
}

// MARK: Dictionary

/**
Converts a Dictionary of XPCRepresentable objects to its xpc_object_t value.
- parameter: dictionary Dictionary of XPCRepresentable objects to convert.
- returns: Converted XPC dictionary.
*/
public func toXPC(dictionary: XPCDictionary) -> xpc_object_t
{
	let xpcDictionary = xpc_dictionary_create(nil, nil, 0)
	for (key, value) in dictionary {
		xpc_dictionary_set_value(xpcDictionary, key, toXPCGeneral(value))
	}
	return xpcDictionary
}

/**
Converts an xpc_object_t dictionary to a Dictionary of XPCRepresentable objects.
- parameter: xpcObject XPC dictionary to to convert.
- returns: Converted Dictionary of XPCRepresentable objects.
*/
public func fromXPC(xpcObject: xpc_object_t) -> XPCDictionary {
	var dict = XPCDictionary()
	xpc_dictionary_apply(xpcObject) { key, value in
		if let key = String(UTF8String: key), let value = fromXPCGeneral(value) {
			dict[key] = value
		}
		return true
	}
	return dict
}

// MARK: String

/**
Converts a String to an xpc_object_t string.
- parameter: string String to convert.
- returns: Converted XPC string.
*/
public func toXPC(string: String) -> xpc_object_t? {
	return xpc_string_create(string)
}

/**
Converts an xpc_object_t string to a String.
- parameter: xpcObject XPC string to to convert.
- returns: Converted String.
*/
public func fromXPC(xpcObject: xpc_object_t) -> String? {
	return String(UTF8String: xpc_string_get_string_ptr(xpcObject))
}

// MARK: Date

private let xpcDateInterval: NSTimeInterval = 1000000000

/**
Converts an NSDate to an xpc_object_t date.
- parameter: date NSDate to convert.
- returns: Converted XPC date.
*/
public func toXPC(date: NSDate) -> xpc_object_t? {
	return xpc_date_create(Int64(date.timeIntervalSince1970 * xpcDateInterval))
}

/**
Converts an xpc_object_t date to an NSDate.
- parameter: xpcObject XPC date to to convert.
- returns: Converted NSDate.
*/
public func fromXPC(xpcObject: xpc_object_t) -> NSDate? {
	let nanosecondsInterval = xpc_date_get_value(xpcObject)
	return NSDate(timeIntervalSince1970: NSTimeInterval(nanosecondsInterval) / xpcDateInterval)
}

// MARK: Data

/**
Converts an NSData to an xpc_object_t data.
- parameter: data Data to convert.
- returns: Converted XPC data.
*/
public func toXPC(data: NSData) -> xpc_object_t? {
	return xpc_data_create(data.bytes, data.length)
}

/**
Converts an xpc_object_t data to an NSData.
- parameter: xpcObject XPC data to to convert.
- returns: Converted NSData.
*/
public func fromXPC(xpcObject: xpc_object_t) -> NSData? {
	return NSData(bytes: xpc_data_get_bytes_ptr(xpcObject), length: Int(xpc_data_get_length(xpcObject)))
}

// MARK: UInt64

/**
Converts a UInt64 to an xpc_object_t uint64.
- parameter: number UInt64 to convert.
- returns: Converted XPC uint64.
*/
public func toXPC(number: UInt64) -> xpc_object_t? {
	return xpc_uint64_create(number)
}

/**
Converts an xpc_object_t uint64 to a UInt64.
- parameter: xpcObject XPC uint64 to to convert.
- returns: Converted UInt64.
*/
public func fromXPC(xpcObject: xpc_object_t) -> UInt64? {
	return xpc_uint64_get_value(xpcObject)
}

// MARK: Int64

/**
Converts an Int64 to an xpc_object_t int64.
- parameter: number Int64 to convert.
- returns: Converted XPC int64.
*/
public func toXPC(number: Int64) -> xpc_object_t? {
	return xpc_int64_create(number)
}

/**
Converts an xpc_object_t int64 to a Int64.
- parameter: xpcObject XPC int64 to to convert.
- returns: Converted Int64.
*/
public func fromXPC(xpcObject: xpc_object_t) -> Int64? {
	return xpc_int64_get_value(xpcObject)
}

// MARK: Double

/**
Converts a Double to an xpc_object_t double.
- parameter: number Double to convert.
- returns: Converted XPC double.
*/
public func toXPC(number: Double) -> xpc_object_t? {
	return xpc_double_create(number)
}

/**
Converts an xpc_object_t double to a Double.
- parameter: xpcObject XPC double to to convert.
- returns: Converted Double.
*/
public func fromXPC(xpcObject: xpc_object_t) -> Double? {
	return xpc_double_get_value(xpcObject)
}

// MARK: Bool

/**
Converts a Bool to an xpc_object_t bool.
- parameter: bool Bool to convert.
- returns: Converted XPC bool.
*/
public func toXPC(bool: Bool) -> xpc_object_t? {
	return xpc_bool_create(bool)
}

/**
Converts an xpc_object_t bool to a Bool.
- parameter: xpcObject XPC bool to to convert.
- returns: Converted Bool.
*/
public func fromXPC(xpcObject: xpc_object_t) -> Bool? {
	return xpc_bool_get_value(xpcObject)
}

// MARK: FileHandle

/**
Converts an NSFileHandle to an equivalent xpc_object_t file handle.
- parameter: fileHandle NSFileHandle to convert.
- returns: Converted XPC file handle. Equivalent but not necessarily identical to the input.
*/
public func toXPC(fileHandle: NSFileHandle) -> xpc_object_t? {
	return xpc_fd_create(fileHandle.fileDescriptor)
}

/**
Converts an xpc_object_t file handle to an equivalent NSFileHandle.
- parameter: xpcObject XPC file handle to to convert.
- returns: Converted NSFileHandle. Equivalent but not necessarily identical to the input.
*/
public func fromXPC(xpcObject: xpc_object_t) -> NSFileHandle? {
	return NSFileHandle(fileDescriptor: xpc_fd_dup(xpcObject), closeOnDealloc: true)
}

/**
Converts an NSUUID to an equivalent xpc_object_t uuid.
- parameter: uuid NSUUID to convert.
- returns: Converted XPC uuid. Equivalent but not necessarily identical to the input.
*/
public func toXPC(uuid: NSUUID) -> xpc_object_t? {
	var bytes = [UInt8](count: 16, repeatedValue: 0)
	uuid.getUUIDBytes(&bytes)
	return xpc_uuid_create(bytes)
}

/**
Converts an xpc_object_t uuid to an equivalent NSUUID.
- parameter: xpcObject XPC uuid to to convert.
- returns: Converted NSUUID. Equivalent but not necessarily identical to the input.
*/
public func fromXPC(xpcObject: xpc_object_t) -> NSUUID? {
	return NSUUID(UUIDBytes: xpc_uuid_get_bytes(xpcObject))
}

extension Array
{
	
	/**
	Filters an array so that the last contiguous group of elements that match the filter
	
	- parameter filter: The filter closure
	
	- returns: Returns an array containing the last contiguous group of elements matching the filter.
	*/
	public func filterLastContiguous(@noescape includeElement: (Element) -> Bool) -> [Element]
	{
		var newArr = [Element]()
		newArr.reserveCapacity(self.count / 2)
		var trimmed = false
		for elem in self
		{
			guard includeElement(elem)
			else
			{
				guard !trimmed
				else
				{
					break
				}
				trimmed = true
				continue
			}
			newArr.append(elem)
		}
		return newArr
	}
	
	
	/// Returns the index of the first element whose `convertToInt` is ≥ compareTo parameter.
	/// - Precondition: The array is sorted according to the element being converted to an Int being used and the array has an element which is ≥ to the ordering condition.
	public func binarySearch(@noescape convertToInt: (Element) -> Int, compareTo elem: Int) -> Index?
	{
		guard count > 0
		else
		{
			return nil
		}
		guard convertToInt(last!) >= elem
		else
		{
			return nil
		}
		guard count > 1 && convertToInt(first!) < elem
		else
		{
			return 0
		}
		var start = 0
		var end = count
		while (end - start) > 1
		{
			let mid = (end + start) / 2
			let val = convertToInt(self[mid])
			if val > elem
			{
				let previous = convertToInt(self[mid - 1])
				if previous < elem
				{
					return mid
				}
				end -= (mid - start)
			}
			else if val < elem
			{
				start += (mid - start)
			}
			else
			{
				return mid
			}
		}
		return end
	}
}
extension RawRepresentable
{
	public init?(raw: Self.RawValue?)
	{
		guard let raw = raw
		else
		{
			return nil
		}
		self.init(rawValue: raw)
	}
}
extension RangeReplaceableCollectionType
{
	mutating func append(newElements: Self)
	{
		for elem in newElements
		{
			self.append(elem)
		}
	}
}

func findAllSubstructures(dict: XPCDictionary?, withCursorPosition cursor: Int) -> XPCDictionary?
{
	guard let dict = dict
	else
	{
		return nil
	}
	guard let substructures = SwiftDocKey.getSubstructure(dict) where substructures.count > 0
	else
	{
		return nil
	}
	guard let structureIndex = substructures.binarySearch({ Int(SwiftDocKey.getOffset($0 as! XPCDictionary)!) }, compareTo: cursor)
	else
	{
		return findAllSubstructures(substructures.last as? XPCDictionary, withCursorPosition: cursor)
	}
	// If there are previous structures check that they end before cursor.
	if structureIndex >= 1
	{
		let previousDict = substructures[structureIndex - 1] as! XPCDictionary
		guard Int(SwiftDocKey.getOffset(previousDict)! + SwiftDocKey.getLength(previousDict)!) < cursor
		else
		{
			// We are still inside the last structure so that's the one we will consider.
			return findAllSubstructures(previousDict, withCursorPosition: cursor)
		}
	}
	let nextDictionary = substructures[structureIndex] as! XPCDictionary
	// If the cursor is before the next top level structure return that one.
	return SwiftDocKey.getKind(nextDictionary) == nil ? nil : nextDictionary
}

extension String
{
	init?(_ cxStr: CXString)
	{
		guard let str = String.fromCString(clang_getCString(cxStr))
		else
		{
			return nil
		}
		self.init(str)
	}
	mutating func removeRange(range: Range<Index>)
	{
		self.replaceRange(range, with: "")
	}
	mutating func removeRange(start: Index, end: Index)
	{
		self.replaceRange(Range<Index>(start: start, end: end), with: "")
	}
	func stringByRemovingRange(range: Range<Index>) -> String
	{
		var str = self
		str.removeRange(range)
		return str
	}
	func stringByRemovingRange(start: Index, end: Index) -> String
	{
		var str = self
		str.removeRange(start, end: end)
		return str
	}
	func lineContainingRange(range: Range<Index>) -> (String, Range<Index>)
	{
		let frontRange = Range<Index>(start: startIndex, end: range.startIndex)
		
		let newStartIndex = rangeOfCharacterFromSet(NSCharacterSet.newlineCharacterSet(), options: NSStringCompareOptions.BackwardsSearch, range: frontRange)?.startIndex ?? startIndex
		
		let backRange = Range<Index>(start: range.endIndex, end: endIndex)
		let newEndIndex = rangeOfCharacterFromSet(NSCharacterSet.newlineCharacterSet(), options: [], range: backRange)?.endIndex ?? endIndex
		
		let range = Range<Index>(start: newStartIndex, end: newEndIndex)
		return (substringWithRange(range), range)
	}
	mutating func trimWhitespaceOnLeft()
	{
		var newStr = self
		var newStart = startIndex
		for char in newStr.unicodeScalars
		{
			guard NSCharacterSet.whitespaceCharacterSet().longCharacterIsMember(char.value)
			else
			{
				break
			}
			newStart = newStart.successor()
		}
		removeRange(startIndex, end: newStart)
	}
}

