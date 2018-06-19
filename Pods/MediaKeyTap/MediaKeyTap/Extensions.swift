//
//  Extensions.swift
//  Castle
//
//  Created by Nicholas Hurden on 22/02/2016.
//  Copyright © 2016 Nicholas Hurden. All rights reserved.
//

import Foundation

precedencegroup FunctorPrecedence {
    associativity: left
    higherThan: DefaultPrecedence
}

infix operator <^> : FunctorPrecedence

func <^><T, U>(f: (T) -> U, ap: T?) -> U? {
    return ap.map(f)
}
