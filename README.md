# LNZWeakCollection
Delegate pattern is a common used pattern to exchange messages and values between objects. 

We all know which are the pitfalls of this pattern: 
* The delegating object must have a weak reference to avoid retain cycles.
* The delegating object must be sure that the delegate is conforming the delegate protocol, or crashes are possible due to unrecognized selector.

If the demanded behavior is to have more object listening for callbacks, and you have in mind to use the delegate pattern to handle more than one delegate, probably you will endup doing something like this: 

```Swift
class MyProxy: NSObject, UITableViewDelegate {
    weak var delegate1: UITableViewDelegate?
    weak var delegate2: UITableViewDelegate?

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate1?.tableView?(tableView, didSelectRowAt: indexPath)
        delegate2?.tableView?(tableView, didSelectRowAt: indexPath)
    }
}
```

This of course will work. But it is not flexible at all. You can have just 2 delegates, and clearly if you want more you have to add delegate3 var, remember to update all your methods and so on.

What's the solution to this issue? We want to be more flexible so that we can avoid a lot of monkey work. We cannot use arrays because they will retain the object ending in a retain cycle, and also we can't really use NSHashTable and NSMapTable because their zeroing behavior is not always what you would expect. [NSMapTable](http://cocoamine.net/blog/2013/12/13/nsmaptable-and-zeroing-weak-references/) in particular retains the object until the data structure needs a resize. What this means is unclear but the takeaway is that if you want the weak reference to be released they are unreliable.

LNZWeakCollection comes with a collection of weak references (WeakCollection) and a dictionary with weak keys or weak values (WeakDictionary).

Using WeakCollection it will be possible to do something like this

```Swift
public class TableViewDelegateProxy: NSObject, UITableViewDelegate {
    var delegates = WeakCollection<UITableViewDelegate>()
	
    public func addDelegate(object: UITableViewDelegate) {
        delegates.add(object: object)
    }
	
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegates.execute { (delegate) in
            delegate.tableView?(tableView, didSelectRowAt: indexPath)
        }
    }
}
```

Weak collection conforms Sequence protocol so you can iterate through objects:

```Swift
    var delegates = WeakCollection<UITableViewDelegate>()

    for (i, delegate) in delegates.enumerated() {
        delegate.tableView?(tableView, didSelectRowAt: indexPath)
    }
    
    for delegate in delegates {
        delegate.tableView?(tableView, didSelectRowAt: indexPath)
    }
```

To install it you can either drag and drop the swift files in the project, or via cocoapod

```
    pod 'LNZWeakCollection'
```
