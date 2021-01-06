from distutils.core import setup, Extension

setup(
    ext_modules=[
        Extension('hack_core', ['hack_core.c'])
    ]
)
