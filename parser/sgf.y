// Copyright 2013 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

// This is an example of a goyacc program.
// To build it:
// go tool yacc -p "expr" expr.y (produces y.go)
// go build -o expr y.go
// expr
// > <type an expression>

%{

package main

import (
	"bufio"
	"bytes"
	"fmt"
	"io"
	"log"
	"strconv"
	"os"
	"unicode/utf8"

	"github.com/thlacroix/gosgf"
)

%}

%union {
	GameTree *gosgf.GameTree
	Sequence *gosgf.Sequence
	Node *gosgf.Node
	Property *gosgf.Property
	num int
}

%type	<GameTree> GameTree
%type <Node> Node
%type <Sequence> Sequence
%type <Property> Property
%type <num> PropIndent PropValue

%token ';' '(' ')'

%token	<num>	NUM

%%

GameTree:
	'(' Sequence ')'
	{
		$$ = &gosgf.GameTree{Sequence: $2}
		fmt.Println($$)
	}

Sequence:
	Node
	{
		$$ = &gosgf.Sequence{Nodes: []*gosgf.Node{$1}}
	}
| Sequence Node
	{
		$$ = $1.AddNode($2)
	}

Node:
	';' Property
	{
		$$ = &gosgf.Node{$2}
	}

Property:
	PropIndent PropValue
	{
		$$ = &gosgf.Property{$1, $2}
	}

PropIndent:
	 NUM

PropValue:
	'[' NUM ']'
	{
		$$ = $2
	}


%%

// The parser expects the lexer to return 0 on EOF.  Give it a name
// for clarity.
const eof = 0

// The parser uses the type <prefix>Lex as a lexer.  It must provide
// the methods Lex(*<prefix>SymType) int and Error(string).
type exprLex struct {
	line []byte
	peek rune
}

// The parser calls this method to get each new token.  This
// implementation returns operators and NUM.
func (x *exprLex) Lex(yylval *sgfSymType) int {
	for {
		c := x.next()
		switch c {
		case eof:
			return eof
		case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9':
			return x.num(c, yylval)
		case ';', '(', ')', '[', ']':
			return int(c)
		case ' ', '\t', '\n', '\r':
		default:
			log.Printf("unrecognized character %q", c)
		}
	}
}

// Lex a number.
func (x *exprLex) num(c rune, yylval *sgfSymType) int {
	add := func(b *bytes.Buffer, c rune) {
		if _, err := b.WriteRune(c); err != nil {
			log.Fatalf("WriteRune: %s", err)
		}
	}
	var b bytes.Buffer
	add(&b, c)
	L: for {
		c = x.next()
		switch c {
		case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.', 'e', 'E':
			add(&b, c)
		default:
			break L
		}
	}
	if c != eof {
		x.peek = c
	}

	v, err := strconv.Atoi(b.String())
	if err != nil {
		log.Printf("bad number %q", b.String())
		return eof
	}
	yylval.num = v
	return NUM
}

// Return the next rune for the lexer.
func (x *exprLex) next() rune {
	if x.peek != eof {
		r := x.peek
		x.peek = eof
		return r
	}
	if len(x.line) == 0 {
		return eof
	}
	c, size := utf8.DecodeRune(x.line)
	x.line = x.line[size:]
	if c == utf8.RuneError && size == 1 {
		log.Print("invalid utf8")
		return x.next()
	}
	return c
}

// The parser calls this method on a parse error.
func (x *exprLex) Error(s string) {
	log.Printf("parse error: %s", s)
}

func main() {
	in := bufio.NewReader(os.Stdin)
	for {
		if _, err := os.Stdout.WriteString("> "); err != nil {
			log.Fatalf("WriteString: %s", err)
		}
		line, err := in.ReadBytes('\n')
		if err == io.EOF {
			return
		}
		if err != nil {
			log.Fatalf("ReadBytes: %s", err)
		}

		sgfParse(&exprLex{line: line})
	}
}
