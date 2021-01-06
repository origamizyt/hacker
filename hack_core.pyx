# cython: language_level=3

import sys, os
from libc.stdlib cimport exit, malloc
from libc.stdio cimport FILE, fseek, fopen, fclose, ftell, rewind, fread, SEEK_END, stdin, EOF, getchar, fgetc, printf
from libc.string cimport strcmp
cimport cython

def hack():
    cdef str fn
    cdef char* c
    c = getstdin(0xFF)
    fn = sys.argv[0][:-3]
    cdef FILE* fp
    cdef char* fc
    cdef FILE* fo
    cdef char* oc
    os.chdir('..\\..\\data\\' + fn)
    for f in os.listdir():
        if not f.endswith('.in'): continue
        fp = open_text_file(f.encode())
        fc = read_text_file(fp, 0xFF)
        close_file(fp)
        if strcmp(fc, c) == 0:
            fo = open_text_file(f.encode()[:-3] + b'.out')
            oc = read_text_file(fo, 0xFF)
            close_file(fo)
            print(oc.decode())
            break

def hack_pandas():
    cdef char* c
    cdef str fn
    cdef FILE* fp
    fn = sys.argv[0][:-3]
    fp = open_binary_file(fn.encode() + b'.xls')
    c = read_binary_file(fp, 0xFFFF)
    close_file(fp)
    cdef char* fc
    cdef FILE* fo
    cdef char* oc
    os.chdir('..\\..\\data\\' + fn)
    for f in os.listdir():
        if not f.endswith('.xls'): continue
        fp = open_binary_file(f.encode())
        fc = read_binary_file(fp, 0xFFFF)
        close_file(fp)
        if strcmp(fc, c) == 0:
            fo = open_text_file(f.encode()[:-4] + b'.out')
            oc = read_binary_file(fo, 0xFF)
            close_file(fo)
            print(oc.decode())
            break

cdef FILE* open_text_file(char* fn):
    cdef FILE* fp
    fp = fopen(fn, "r")
    return fp

cdef FILE* open_binary_file(char* fn):
    cdef FILE* fp
    fp = fopen(fn, "rb")
    return fp

cdef void close_file(FILE* fp):
    fclose(fp)

cdef char* read_text_file(FILE* pf, int size):
    cdef char* text
    cdef int c, i
    text = <char*>malloc(size+1)
    i = 0
    while True:
        c = fgetc(pf)
        if c == EOF: break
        if c == b'\r': continue
        text[i]=c
        i += 1
    text[i]=0
    return text

cdef char* read_binary_file(FILE* pf, int size):
    cdef char* text
    cdef int c, i
    text = <char*>malloc(size+1)
    i = 0
    while True:
        c = fgetc(pf)
        if c == EOF: break
        text[i]=c
        i += 1
    text[i]=0
    return text

cdef char* getstdin(int size):
    cdef char* s
    cdef int c,i
    s = <char*>malloc(size+1)
    i=0
    while True:
        c = getchar()
        if c == EOF: break
        if c == b'\r': continue
        s[i]=c
        i += 1
    s[i]=0
    return s