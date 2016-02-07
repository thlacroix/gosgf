package main

import (
	"bufio"
	"bytes"
	"fmt"
	"io"
	"log"
	"os"
)

// example (;1[2];3[4])(;5[6];7[8](;9[10];11[12]))
type Collection struct {
	GameTrees []*GameTree
}

type GameTree struct {
	Sequence  *Sequence
	GameTrees []*GameTree
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

func (c *Collection) AddGameTree(g *GameTree) *Collection {
	c.GameTrees = append(c.GameTrees, g)
	return c
}

func (c Collection) String() string {
	var b bytes.Buffer
	for _, g := range c.GameTrees {
		b.WriteString(g.String())
	}
	return b.String()
}

func (g GameTree) String() string {
	var b bytes.Buffer
	b.WriteString(fmt.Sprint("(", g.Sequence))
	for _, gt := range g.GameTrees {
		b.WriteString(gt.String())
	}
	b.WriteString(")")
	return b.String()
}

func (s Sequence) String() string {
	var b bytes.Buffer
	for _, n := range s.Nodes {
		b.WriteString(n.String())
	}
	return b.String()
}

func (n Node) String() string {
	return fmt.Sprint(";", n.Property.Key, "[", n.Property.Value, "]")
}

func (s *Sequence) AddNode(n *Node) *Sequence {
	s.Nodes = append(s.Nodes, n)
	return s
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
