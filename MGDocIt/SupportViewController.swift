//
//  SupportViewController.swift
//  Controller
//
//  Created by Manav Gabhawala on 6/10/15.
//  Copyright (c) 2015 Manav Gabhawala. All rights reserved.
//

import Cocoa

class SupportViewController: NSViewController
{

    override func viewDidLoad()
	{
        super.viewDidLoad()
        // Do view setup here.
    }
	
	@IBAction func githubPressed(sender: NSButton)
	{
		NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://github.com/ManavGabhawala/MGDocIt")!)
	}
	@IBAction func emailPressed(sender: NSButton)
	{
		NSWorkspace.sharedWorkspace().openURL(NSURL(string: "mailto:manav1907@gmail.com")!)
	}
	@IBAction func twitterPressed(sender: NSButton)
	{
		NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://twitter.com/ManavGabhawala")!)
	}
	@IBAction func websitePressed(sender: NSButton)
	{
		NSWorkspace.sharedWorkspace().openURL(NSURL(string: "http://manavgabhawala.me")!)
	}
}