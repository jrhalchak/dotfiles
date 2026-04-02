package tree_sitter_bdiagram_test

import (
	"testing"

	tree_sitter "github.com/tree-sitter/go-tree-sitter"
	tree_sitter_bdiagram "www.github.com/jrhalchak/bdiagram/bindings/go"
)

func TestCanLoadGrammar(t *testing.T) {
	language := tree_sitter.NewLanguage(tree_sitter_bdiagram.Language())
	if language == nil {
		t.Errorf("Error loading Neorg Box Diagrams grammar")
	}
}
