# cython: language_level=3

import sys
from libc.stdlib cimport exit, malloc
from libc.stdio cimport FILE, fseek, fopen, fclose, ftell, rewind, fread, SEEK_END, stdin, EOF, getchar, fgetc, printf
from libc.string cimport strcmp, strcpy, strcat, strlen, strncpy
from libc.io cimport _finddata_t, _findfirst, _findnext, _findclose
cimport cython

def hack():
    cdef str fn
    cdef char c[0x40]
    get_stdin(c)
    fn = sys.argv[0][:-3]
    cdef char b[0x20]
    strcpy(b, b'..\\..\\data\\')
    strcat(b, fn.encode())
    strcat(b, b"\\")
    cdef char re[0x20]
    strcpy(re, b)
    strcat(re, b'*.in')
    cdef char f[0x20]
    cdef char s[0x20]
    cdef _finddata_t d
    cdef long long h = _findfirst(re, &d)
    strcpy(f, b)
    strcat(f, d.name)
    if check_text_file(f, c):
        slice_string(f, 3, s)
        strcat(s, b'.out')
        print_file(s)
    else:
        while _findnext(h, &d) == 0:
            strcpy(f, b)
            strcat(f, d.name)
            if check_text_file(f, c):
                slice_string(f, 3, s)
                strcat(s, b'.out')
                print_file(s)
                break

def hack_pandas():
    cdef char c[0xFFFF]
    cdef str fn
    cdef char xfn[0x20]
    cdef FILE* fopen
    fn = sys.argv[0][:-3]
    strcpy(xfn, fn.encode())
    strcat(xfn, b'.xls')
    fp = open_binary_file(xfn)
    read_binary_file(fp, c)
    close_file(fp)
    cdef char b[0x20]
    strcpy(b, b'..\\..\\data\\')
    strcat(b, fn.encode())
    strcat(b, b"\\")
    cdef char re[0x20]
    strcpy(re, b)
    strcat(re, b'*.xls')
    cdef char f[0x20]
    cdef char s[0x20]
    cdef _finddata_t d
    cdef long long h = _findfirst(re, &d)
    strcpy(f, b)
    strcat(f, d.name)
    if check_binary_file(f, c):
        slice_string(f, 4, s)
        strcat(s, b'.out')
        print_file(s)
    else:
        while _findnext(h, &d) == 0:
            strcpy(f, b)
            strcat(f, d.name)
            if check_text_file(f, c):
                slice_string(f, 4, s)
                strcat(s, b'.out')
                print_file(s)
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

cdef int read_text_file(FILE* pf, char* text):
    cdef int c, i
    i = 0
    while True:
        c = fgetc(pf)
        if c == EOF: break
        if c == b'\r': continue
        text[i]=c
        i += 1
    text[i]=0
    return i

cdef int read_binary_file(FILE* pf, char* text):
    cdef int c, i
    i = 0
    while True:
        c = fgetc(pf)
        if c == EOF: break
        text[i]=c
        i += 1
    text[i]=0
    return i

cdef int get_stdin(char* s):
    cdef int c,i
    i=0
    while True:
        c = getchar()
        if c == EOF: break
        if c == b'\r': continue
        s[i]=c
        i += 1
    s[i]=0
    return i

cdef int check_text_file(char* fn, char* expect):
    cdef FILE* fp = open_text_file(fn)
    cdef char fc[0x20]
    read_text_file(fp, fc)
    close_file(fp)
    return strcmp(fc, expect) == 0

cdef int check_binary_file(char* fn, char* expect):
    cdef FILE* fp = open_binary_file(fn)
    cdef char fc[0x400]
    read_binary_file(fp, fc)
    close_file(fp)
    return strcmp(fc, expect) == 0

cdef void print_file(char* fn):
    cdef FILE* fp = open_text_file(fn)
    cdef char fc[0x400]
    read_text_file(fp, fc)
    close_file(fp)
    print(fc.decode())

cdef void slice_string(char* s, size_t off, char* dst):
    cdef size_t l = strlen(s) - off
    strncpy(dst, s, l)
    dst[l] = 0