
import Foundation
import XCTest
import SwiftSyntax
@testable
import MacroEssentials

final class DevelopmentTests: XCTestCase {
    func testPropertyType() throws {
        XCTAssertEqual(PropertyType(of: ("let a = 2" as DeclSyntax).as(VariableDeclSyntax.self)!), .storedConstant)
        XCTAssertEqual(PropertyType(of: ("let a = 2 { didSet {} }" as DeclSyntax).as(VariableDeclSyntax.self)!), .storedConstant)
        XCTAssertEqual(PropertyType(of: ("var a = 2" as DeclSyntax).as(VariableDeclSyntax.self)!), .storedVariable)
        XCTAssertEqual(PropertyType(of: ("var a = 2 { didSet {} }" as DeclSyntax).as(VariableDeclSyntax.self)!), .storedVariable)
        XCTAssertEqual(PropertyType(of: ("var a = 2 { didSet {} willSet {} }" as DeclSyntax).as(VariableDeclSyntax.self)!), .storedVariable)
        
        XCTAssertEqual(PropertyType(of: ("var a { 2 }" as DeclSyntax).as(VariableDeclSyntax.self)!), .computed)
        XCTAssertEqual(PropertyType(of: ("var a { get { 2 } }" as DeclSyntax).as(VariableDeclSyntax.self)!), .computed)
    }
}

