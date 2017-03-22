//
//  LNZWeakContainer.swift
//  LNZWeakCollection
//
//  Created by Giuseppe Lanza on 22/03/17.
//  Copyright © 2017 Giuseppe Lanza. All rights reserved.
//

import Foundation

public struct LNZWeakContainer<T: AnyObject> {
    public weak var weakReference: T?
}
