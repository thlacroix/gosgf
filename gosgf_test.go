package gosgf

import "testing"

func TestHello(t *testing.T) {
	hello()
}

func TestStructures(t *testing.T) {
	g := GameTree{
		Sequence{
			[]Node{{"A"}},
		},
		nil,
	}
	name := g.Sequence.Nodes[0].Name
	if name != "A" {
		t.Fail()
	}
}

func TestNewGameTree(t *testing.T) {
	_, err := NewGameTreeFromFile("games/ff4_ex.sgf")
	if err != nil {
		t.Fail()
	}
}
