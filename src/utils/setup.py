#!/usr/bin/python  
   
# Run as:    
#    python setup.py build_ext --inplace    
     
import sys    
sys.path.insert(0, "..")    
     
from distutils.core import setup    
from distutils.extension import Extension    
from Cython.Build import cythonize    
from Cython.Distutils import build_ext  
import numpy     
# ext_module = cythonize("TestOMP.pyx")    
ext_module = Extension(  
                        "cpu_nms",  
            ["cpu_nms.pyx"],  include_dirs=[numpy.get_include()]
            #extra_compile_args=["/openmp"],  
            #extra_link_args=["/openmp"],  
            )  
     
setup(  
    cmdclass = {'build_ext': build_ext},  
        ext_modules = [ext_module],   
)

