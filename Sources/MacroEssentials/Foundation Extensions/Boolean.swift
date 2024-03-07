//
//  Boolean.swift
//  MacroEssentials
//
//  Created by Vaida on 2024/3/7.
//


import Foundation


internal extension Bool {
    
    static func => (_ lhs: Bool, _ rhs: Bool) -> Bool {
        !lhs || rhs
    }
    
}

infix operator =>
