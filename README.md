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

What's the solution to this issue? We want to be more flexible so that we can avoid a lot of monkey work. We cannot use arrays because they will retain the object ending in a retain cycle, and also we can't use NSHashTable because they don't work with generics, so we cannot be sure of what Jimmy (Clueless new developer that just approach for the first time to the project) will put inside that NSHashTable...

LNZWeakCollection is the answer. A Sequence of weak references to objects that is type safe, accepts protocols as specializer and cleanups itself when a weak becomes nil.

With this class it will be possible to do something like this

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

