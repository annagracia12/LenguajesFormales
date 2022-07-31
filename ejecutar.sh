#!/bin/bash

flex practica1.l

cc lex.yy.c -lfl

./a.out $1
