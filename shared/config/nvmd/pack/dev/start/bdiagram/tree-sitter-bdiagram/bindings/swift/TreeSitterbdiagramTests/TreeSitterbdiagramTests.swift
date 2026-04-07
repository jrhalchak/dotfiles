import XCTest
import SwiftTreeSitter
import TreeSitterBdiagram

final class TreeSitterBdiagramTests: XCTestCase {
    func testCanLoadGrammar() throws {
        let parser = Parser()
        let language = Language(language: tree_sitter_bdiagram())
        XCTAssertNoThrow(try parser.setLanguage(language),
                         "Error loading Neorg Box Diagrams grammar")
    }
}
