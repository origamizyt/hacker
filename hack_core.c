#include <Python.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <io.h>

FILE* open_text_file(char* fn){
    FILE* fp;
    fp = fopen(fn, "r");
    return fp;
}

FILE* open_binary_file(char* fn){
    FILE* fp;
    fp = fopen(fn, "r");
    return fp;
}

void close_file(FILE* fp){
    fclose(fp);
}

int read_text_file(FILE* fp, char* text){
    int c, i = 0;
    while (1) {
        c = fgetc(fp);
        if (c == EOF) break;
        if (c == '\r') continue;
        text[i]=c;
        i++;
    }
    text[i]=0;
    return i;
}

int read_binary_file(FILE* fp, char* text){
    int c, i = 0;
    while (1) {
        c = fgetc(fp);
        if (c == EOF) break;
        text[i]=c;
        i++;
    }
    text[i]=0;
    return i;
}

int get_stdin(char* s){
    int c, i=0;
    while (1){
        c = getchar();
        if (c == EOF) break;
        if (c == '\r') continue;
        s[i]=c;
        i++;
    }
    s[i]=0;
    return i;
}

int check_text_file(char* fn, char* expect){
    FILE* fp = open_text_file(fn);
    char fc[0x20];
    read_text_file(fp, fc);
    close_file(fp);
    return strcmp(fc, expect) == 0;
}

int check_binary_file(char* fn, char* expect){
    FILE* fp = open_binary_file(fn);
    char fc[0xFFFF];
    read_text_file(fp, fc);
    close_file(fp);
    return strcmp(fc, expect) == 0;
}

void print_file(char* fn, char* out) {
    FILE* fp = open_text_file(fn);
    read_text_file(fp, out);
    close_file(fp);
}

void slice_string(char* s, size_t off, char* dst){
    size_t l = strlen(s) - off;
    strncpy(dst, s, l);
    dst[l] = 0;
}

void get_script(char* s){
    PyObject* sys = PyImport_ImportModule("sys");
    PyObject* argv = PyObject_GetAttrString(sys, "argv");
    PyObject* index_0 = Py_BuildValue("i", 0);
    PyObject* arg1 = PyObject_GetItem(argv, index_0);
    char* fn = NULL;
    PyArg_Parse(arg1, "s", &fn);
    slice_string(fn, 3, s);
}

int hack_script(char* fn, char* c, char* out){
    char b[0x20];
    strcpy(b, "..\\..\\data\\");
    strcat(b, fn);
    strcat(b, "\\");
    char re[0x20];
    strcpy(re, b);
    strcat(re, "*.in");
    char f[0x20];
    char s[0x20];
    struct _finddata_t d;
    long long h = _findfirst(re, &d);
    strcpy(f, b);
    strcat(f, d.name);
    if (check_text_file(f, c)){
        slice_string(f, 3, s);
        strcat(s, ".out");
        print_file(s, out);
        return 1;
    }
    else
        while (_findnext(h, &d) == 0){
            strcpy(f, b);
            strcat(f, d.name);
            if (check_text_file(f, c)){
                slice_string(f, 3, s);
                strcat(s, ".out");
                print_file(s, out);
                return 1;
            }
        }
    return 0;
}

int hack_pandas_script(char* fn, char* out){
    char c[0xFFFF];
    char xfn[0x20];
    strcpy(xfn, fn);
    strcat(xfn, ".xls");
    FILE* fp = open_binary_file(xfn);
    read_binary_file(fp, c);
    close_file(fp);
    char b[0x20];
    strcpy(b, "..\\..\\data\\");
    strcat(b, fn);
    strcat(b, "\\");
    char re[0x20];
    strcpy(re, b);
    strcat(re, "*.xls");
    char f[0x20];
    char s[0x20];
    struct _finddata_t d;
    long long h = _findfirst(re, &d);
    strcpy(f, b);
    strcat(f, d.name);
    if (check_binary_file(f, c)){
        slice_string(f, 4, s);
        strcat(s, ".out");
        print_file(s, out);
        return 1;
    }
    else
        while (_findnext(h, &d) == 0){
            strcpy(f, b);
            strcat(f, d.name);
            if (check_text_file(f, c)){
                slice_string(f, 4, s);
                strcat(s, ".out");
                print_file(s, out);
                return 1;
            }
        }
    return 0;
}

void hack(){
    char fn[0x20];
    get_script(fn);
    char c[0x40];
    get_stdin(c);
    char out[0x40];
    int r = hack_script(fn, c, out);
    if (r) printf("%s\n", out);
}

void hack_pandas(){
    char fn[0x20];
    get_script(fn);
    char out[0x40];
    int r = hack_pandas_script(fn, out);
    if (r) printf("%s\n", out);
}

static PyObject* wrap_hack(PyObject* self, PyObject* args){
    hack();
    return Py_None;
}

static PyObject* wrap_hack_pandas(PyObject* self, PyObject* args){
    hack_pandas();
    return Py_None;
}

static PyObject* wrap_hack_script(PyObject* self, PyObject* args){
    char* fn;
    char* c;
    if (!PyArg_ParseTuple(args, "ss", &fn, &c)){
        PyErr_SetNone(PyExc_TypeError);
        return NULL;
    }
    char out[0x40];
    int r = hack_script(fn, c, out);
    if (r)
        return Py_BuildValue("iz", r, out);
    else
        return Py_BuildValue("iz", r, NULL);
}

static PyObject* wrap_hack_pandas_script(PyObject* self, PyObject* args){
    char* fn;
    if (!PyArg_ParseTuple(args, "s", &fn)){
        PyErr_SetNone(PyExc_TypeError);
        return NULL;
    }
    char out[0x40];
    int r = hack_pandas_script(fn, out);
    if (r)
        return Py_BuildValue("iz", r, out);
    else
        return Py_BuildValue("iz", r, NULL);
}

static PyMethodDef hackmethods[] = {
    {"hack", wrap_hack, METH_NOARGS, ""},
    {"hack_pandas", wrap_hack_pandas, METH_NOARGS, ""},
    {"hack_script", wrap_hack_script, METH_VARARGS, ""},
    {"hack_pandas_script", wrap_hack_pandas_script, METH_VARARGS, ""},
    {NULL, NULL, 0, NULL}
};

static struct PyModuleDef hackmodule = {
	PyModuleDef_HEAD_INIT,
	"hack_core",
	NULL,
	-1,
	hackmethods
};

PyMODINIT_FUNC PyInit_hack_core(void){
    return PyModule_Create(&hackmodule);
}