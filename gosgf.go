package gosgf

import (
	"bufio"
	"fmt"
	"io"
	"log"
	"os"
)

type GameTree struct {
	Sequence  *Sequence
	GameTrees []GameTree
}

type Sequence struct {
	Nodes []*Node
}

type Node struct {
	Property *Property
}

type Property struct {
	Key   int
	Value int
}

func (s *Sequence) AddNode(n *Node) *Sequence {
	s.Nodes = append(s.Nodes, n)
	return s
}

func (g GameTree) String() string {
	a := ""
	for _, n := range g.Sequence.Nodes {
		a += fmt.Sprintln(n.Property.Key, n.Property.Value)
	}
	return a
}

func NewGameTreeFromFile(filepath string) (*GameTree, error) {
	f, err := os.Open(filepath)
	if err != nil {
		return nil, err
	}
	defer f.Close()
	r := bufio.NewReader(f)
	for {
		if c, _, err := r.ReadRune(); err != nil {
			if err == io.EOF {
				break
			} else {
				log.Fatal(err)
			}
		} else {
			switch c {
			case '(':
				log.Println("New GameTree")
			case ')':
				log.Println("EndGameTree")
			case ';':
				log.Println("NewNode")
			}
			//fmt.Printf("%q [%d]\n", string(c), sz)
		}
	}
	return nil, nil
}

func hello() {
	fmt.Println("Hello world")
}
