//
//  ObjectiveCCategoryType.swift
//  MGDocIt
//
//  Created by Manav Gabhawala on 18/08/15.
//  Copyright © 2015 Manav Gabhawala. All rights reserved.
//

import Foundation

private let categoryKey = "MGObjcCategory"
private let categoryDefaultText = "MARK: - <#$1>"

struct ObjectiveCCategory : ObjectiveCNameAndInheritedType
{
	var key: String { return categoryKey }
	var defaultText: String
	{
		return categoryDefaultText
	}
	
	var name: String
	var inheritedTypes = [String]()
}