---
layout: post
title: "Inscrutable Swift/Xcode Errors"
description: Swift isn't fully baked yet
date: 2014-09-22T16:21:05+00:00
draft: false
tags: [xcode, swift, development]
---

Ugh, what a horrible day of coding. I've been playing around with a small Swift app that's using Core Data and displaying the contents in a Table View. 

There are plenty of tutorials on Swift + Core Data on the web but the majority were written before Apple released the 'final' version of the language with Beta 6 so any and all code samples you see online have to be audited as you use them. Today I discovered that you need to use that same auditing mentality when you're using Apple's boilerplate code as well.

Xcode will generate a lot of boilerplate code when you chose certain project templates when you begin a new project. It so happens that if you choose the Master-Detail Application template and choose "Use Core Data" you'll get a starting point for the very app I was wanting to build.

Since the purpose of this app was to learn all of the ins and outs of Core Data access using Swift I decided to use the boilerplate code as a reference but rewrite it all myself.

The problems started while overriding the controller:didChangeObject method. Using Xcode's autocomplete I wrote the following code:

{% splash %}
// MARK: FetchedResultsControllerDelegate
func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
    switch type {
    case .Insert:
        tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
    default:
        return
    }
}   
{% endsplash %}

I was getting a weird error for 

{% splash %}
tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)`:
{% endsplash %}

> Could not find member 'Fade'

What?

If I replaced `.Fade` with `nil` I then got:

> (UITableView, numberOfRowsInSection: Int) -> Int does not have a member named insertRowsAtIndexPaths

WHAT DOES THAT EVEN MEAN?

This is the code in the boilerplate I was working from:

{% splash %}
func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath) {
    switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        case .Update:
            self.configureCell(tableView.cellForRowAtIndexPath(indexPath)!, atIndexPath: indexPath)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
        default:
            return
    }
}
{% endsplash %}

Notice the difference? It took me a couple of hours of debugging to see it.

It's the method signature, in the auto generated code `newIndexPath` and `indexPath` are optionals and in the boilerplate they aren't.

If this helps out one other person I will be happy.

Bug report time.
