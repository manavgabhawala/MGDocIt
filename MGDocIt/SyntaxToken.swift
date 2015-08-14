//
//  SyntaxToken.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 14/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation

/// Represents a single Swift syntax token.
public struct SyntaxToken {
	/// Token type. See SyntaxKind.
	public let type: SyntaxKind
	/// Token offset.
	public let offset: Int
	/// Token length.
	public let length: Int
	
	/// Dictionary representation of SyntaxToken. Useful for NSJSONSerialization.
	public var dictionaryValue: [String: AnyObject] {
		return ["type": type.rawValue, "offset": offset, "length": length]
	}
	
	/**
	Create a SyntaxToken by directly passing in its property values.
	
	- parameter type:   Token type. See SyntaxKind.
	- parameter offset: Token offset.
	- parameter length: Token length.
	*/
	public init(type: String, offset: Int, length: Int) {
		self.type = SyntaxKind(rawValue: type) ?? .Unknown
		self.offset = offset
		self.length = length
		assert(self.type != .Unknown)
	}
}

// MARK: Equatable

extension SyntaxToken: Equatable {}

/**
Returns true if `lhs` SyntaxToken is equal to `rhs` SyntaxToken.

- parameter lhs: SyntaxToken to compare to `rhs`.
- parameter rhs: SyntaxToken to compare to `lhs`.

- returns: True if `lhs` SyntaxToken is equal to `rhs` SyntaxToken.
*/
public func ==(lhs: SyntaxToken, rhs: SyntaxToken) -> Bool {
	return (lhs.type == rhs.type) && (lhs.offset == rhs.offset) && (lhs.length == rhs.length)
}

// MARK: CustomStringConvertible

extension SyntaxToken: CustomStringConvertible {
	/// A textual JSON representation of `SyntaxToken`.
	public var description: String { return "\(dictionaryValue)" }
}
