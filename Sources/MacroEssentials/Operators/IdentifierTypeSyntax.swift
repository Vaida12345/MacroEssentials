//
//  IdentifierTypeSyntax.swift
//  MacroEssentials
//
//  Created by Vaida on 2024/3/6.
//

import Foundation
import Foundation
import SwiftSyntax


extension IdentifierTypeSyntax {
    
    public static func == (_ lhs: IdentifierTypeSyntax, _ rhs: String) -> Bool { lhs.name.text == rhs }

}


extension Optional<IdentifierTypeSyntax> {
    
    public static func == (_ lhs: IdentifierTypeSyntax?, _ rhs: String) -> Bool { lhs?.name.text == rhs }
    
}
