""" Executed at the begining of a Python interactive REPL.
Pre-load some default libraries and save the python command history in a location following the XDG OPEN DIRECTORY specifications.
"""

# Import warnings first to filter deprecated packages
try: import warnings
except ModuleNotFoundError: pass
with warnings.catch_warnings():
    warnings.filterwarnings("ignore",category=DeprecationWarning)

    # Python Runtime Services
    try: import sys
    except ModuleNotFoundError: pass
    try: import sysconfig
    except ModuleNotFoundError: pass
    try: import builtins
    except ModuleNotFoundError: pass
    try: import dataclasses
    except ModuleNotFoundError: pass
    try: import contextlib
    except ModuleNotFoundError: pass
    try: import abc
    except ModuleNotFoundError: pass
    try: import atexit
    except ModuleNotFoundError: pass
    try: import traceback
    except ModuleNotFoundError: pass
    try: import __future__
    except ModuleNotFoundError: pass
    try: import gc
    except ModuleNotFoundError: pass
    try: import inspect
    except ModuleNotFoundError: pass
    try: import site
    except ModuleNotFoundError: pass

    # Text Processing Services
    try: import string
    except ModuleNotFoundError: pass
    try: import re
    except ModuleNotFoundError: pass
    try: import difflib
    except ModuleNotFoundError: pass
    try: import textwrap
    except ModuleNotFoundError: pass
    try: import unicodedata
    except ModuleNotFoundError: pass
    try: import stringprep
    except ModuleNotFoundError: pass
    try: import readline
    except ModuleNotFoundError: pass
    try: import rlcompleter
    except ModuleNotFoundError: pass

    # Binary Data Services
    try: import struct
    except ModuleNotFoundError: pass
    try: import codecs
    except ModuleNotFoundError: pass

    # Data Types
    try: import datetime
    except ModuleNotFoundError: pass
    try: import calendar
    except ModuleNotFoundError: pass
    try: import collections
    except ModuleNotFoundError: pass
    try: import heapq
    except ModuleNotFoundError: pass
    try: import bisect
    except ModuleNotFoundError: pass
    try: import array
    except ModuleNotFoundError: pass
    try: import weakref
    except ModuleNotFoundError: pass
    try: import types
    except ModuleNotFoundError: pass
    try: import copy
    except ModuleNotFoundError: pass
    try: import pprint
    except ModuleNotFoundError: pass
    try: import reprlib
    except ModuleNotFoundError: pass
    try: import enum
    except ModuleNotFoundError: pass

    # Numeric and Mathematical Module
    try: import numbers
    except ModuleNotFoundError: pass
    try: import math
    except ModuleNotFoundError: pass
    try: import cmath
    except ModuleNotFoundError: pass
    try: import decimal
    except ModuleNotFoundError: pass
    try: import fractions
    except ModuleNotFoundError: pass
    try: import random
    except ModuleNotFoundError: pass
    try: import statistics
    except ModuleNotFoundError: pass

    # Functional Programming Modules
    try: import itertools
    except ModuleNotFoundError: pass
    try: import functools
    except ModuleNotFoundError: pass
    try: import operator
    except ModuleNotFoundError: pass

    # File and Directory Access
    try: import pathlib
    except ModuleNotFoundError: pass
    try: import fileinput
    except ModuleNotFoundError: pass
    try: import stat
    except ModuleNotFoundError: pass
    try: import filecmp
    except ModuleNotFoundError: pass
    try: import tempfile
    except ModuleNotFoundError: pass
    try: import glob
    except ModuleNotFoundError: pass
    try: import fnmatch
    except ModuleNotFoundError: pass
    try: import linecache
    except ModuleNotFoundError: pass
    try: import shutil
    except ModuleNotFoundError: pass
    try: import macpath
    except ModuleNotFoundError: pass

    # Data Persistence
    try: import pickle
    except ModuleNotFoundError: pass
    try: import copyreg
    except ModuleNotFoundError: pass
    try: import shelve
    except ModuleNotFoundError: pass
    try: import dbm
    except ModuleNotFoundError: pass
    try: import sqlite3
    except ModuleNotFoundError: pass

    # Data Compression and Archiving
    try: import zlib
    except ModuleNotFoundError: pass
    try: import gzip
    except ModuleNotFoundError: pass
    try: import bz2
    except ModuleNotFoundError: pass
    try: import lzma
    except ModuleNotFoundError: pass
    try: import zipfile
    except ModuleNotFoundError: pass
    try: import tarfile
    except ModuleNotFoundError: pass

    # File Formats
    try: import csv
    except ModuleNotFoundError: pass
    try: import configparser
    except ModuleNotFoundError: pass
    try: import netrc
    except ModuleNotFoundError: pass
    try: import xdrlib
    except ModuleNotFoundError: pass
    try: import plistlib
    except ModuleNotFoundError: pass

    # Cryptographic Services
    try: import hashlib
    except ModuleNotFoundError: pass
    try: import hmac
    except ModuleNotFoundError: pass
    try: import secrets
    except ModuleNotFoundError: pass

    # Generic Operating System Services
    try: import os
    except ModuleNotFoundError: pass
    try: import io
    except ModuleNotFoundError: pass
    try: import time
    except ModuleNotFoundError: pass
    try: import argparse
    except ModuleNotFoundError: pass
    try: import getopt
    except ModuleNotFoundError: pass
    try: import logging
    except ModuleNotFoundError: pass
    try: import getpass
    except ModuleNotFoundError: pass
    try: import curses
    except ModuleNotFoundError: pass
    try: import platform
    except ModuleNotFoundError: pass
    try: import errno
    except ModuleNotFoundError: pass
    try: import ctypes
    except ModuleNotFoundError: pass

    # Concurrent Execution
    try: import threading
    except ModuleNotFoundError: pass
    try: import multiprocessing
    except ModuleNotFoundError: pass
    try: import concurrent
    except ModuleNotFoundError: pass
    try: import subprocess
    except ModuleNotFoundError: pass
    try: import sched
    except ModuleNotFoundError: pass
    try: import queue
    except ModuleNotFoundError: pass
    try: import _thread
    except ModuleNotFoundError: pass
    try: import _dummy_thread
    except ModuleNotFoundError: pass
    try: import dummy_threading
    except ModuleNotFoundError: pass

    # Context Variables
    try: import contextvars
    except ModuleNotFoundError: pass

    # Networking and Interprocess Communication
    try: import asyncio
    except ModuleNotFoundError: pass
    try: import socket
    except ModuleNotFoundError: pass
    try: import ssl
    except ModuleNotFoundError: pass
    try: import select
    except ModuleNotFoundError: pass
    try: import selectors
    except ModuleNotFoundError: pass
    try: import asyncore
    except ModuleNotFoundError: pass
    try: import asynchat
    except ModuleNotFoundError: pass
    try: import signal
    except ModuleNotFoundError: pass
    try: import mmap
    except ModuleNotFoundError: pass

    # Internet Data Handling
    try: import email
    except ModuleNotFoundError: pass
    try: import json
    except ModuleNotFoundError: pass
    try: import mailcap
    except ModuleNotFoundError: pass
    try: import mailbox
    except ModuleNotFoundError: pass
    try: import mimetypes
    except ModuleNotFoundError: pass
    try: import base64
    except ModuleNotFoundError: pass
    try: import binhex
    except ModuleNotFoundError: pass
    try: import binascii
    except ModuleNotFoundError: pass
    try: import quopri
    except ModuleNotFoundError: pass
    try: import uu
    except ModuleNotFoundError: pass

    # Structured Markup Processing Tools
    try: import html
    except ModuleNotFoundError: pass
    try: import xml
    except ModuleNotFoundError: pass

    # Internet Protocols and Support
    try: import webbrowser
    except ModuleNotFoundError: pass
    try: import cgi
    except ModuleNotFoundError: pass
    try: import cgitb
    except ModuleNotFoundError: pass
    try: import wsgiref
    except ModuleNotFoundError: pass
    try: import urllib
    except ModuleNotFoundError: pass
    try: import http
    except ModuleNotFoundError: pass
    try: import ftplib
    except ModuleNotFoundError: pass
    try: import poplib
    except ModuleNotFoundError: pass
    try: import imaplib
    except ModuleNotFoundError: pass
    try: import nntplib
    except ModuleNotFoundError: pass
    try: import smtplib
    except ModuleNotFoundError: pass
    try: import smtpd
    except ModuleNotFoundError: pass
    try: import telnetlib
    except ModuleNotFoundError: pass
    try: import uuid
    except ModuleNotFoundError: pass
    try: import socketserver
    except ModuleNotFoundError: pass
    try: import http
    except ModuleNotFoundError: pass
    try: import xmlrpc
    except ModuleNotFoundError: pass
    try: import ipaddress
    except ModuleNotFoundError: pass

    # Multimedia Services
    try: import audioop
    except ModuleNotFoundError: pass
    try: import aifc
    except ModuleNotFoundError: pass
    try: import sunau
    except ModuleNotFoundError: pass
    try: import wave
    except ModuleNotFoundError: pass
    try: import chunk
    except ModuleNotFoundError: pass
    try: import colorsys
    except ModuleNotFoundError: pass
    try: import imghdr
    except ModuleNotFoundError: pass
    try: import sndhdr
    except ModuleNotFoundError: pass
    try: import ossaudiodev
    except ModuleNotFoundError: pass

    # Internationalization
    try: import gettext
    except ModuleNotFoundError: pass
    try: import locale
    except ModuleNotFoundError: pass

    # Program Frameworks
    try: import turtle
    except ModuleNotFoundError: pass
    try: import cmd
    except ModuleNotFoundError: pass
    try: import shlex
    except ModuleNotFoundError: pass

    # Graphical User Interface
    try: import tkinter
    except ModuleNotFoundError: pass

    # Development Tools
    try: import typing
    except ModuleNotFoundError: pass
    try: import pydoc
    except ModuleNotFoundError: pass
    try: import doctest
    except ModuleNotFoundError: pass
    try: import unittest
    except ModuleNotFoundError: pass
    try: import test
    except ModuleNotFoundError: pass

    # Debugging and Profiling
    try: import bdb
    except ModuleNotFoundError: pass
    try: import faulthandler
    except ModuleNotFoundError: pass
    try: import pdb
    except ModuleNotFoundError: pass
    try: import profile
    except ModuleNotFoundError: pass
    try: import cProfile
    except ModuleNotFoundError: pass
    try: import pstats
    except ModuleNotFoundError: pass
    try: import timeit
    except ModuleNotFoundError: pass
    try: import trace
    except ModuleNotFoundError: pass
    try: import tracemalloc
    except ModuleNotFoundError: pass

    # Software Packaging and Distribution
    try: import distutils
    except ModuleNotFoundError: pass
    try: import ensurepip
    except ModuleNotFoundError: pass
    try: import venv
    except ModuleNotFoundError: pass
    try: import zipapp
    except ModuleNotFoundError: pass

    # Custome Python Interpreters
    try: import code
    except ModuleNotFoundError: pass
    try: import codeop
    except ModuleNotFoundError: pass

    # Importing Modules
    try: import zipimport
    except ModuleNotFoundError: pass
    try: import pkgutil
    except ModuleNotFoundError: pass
    try: import modulefinder
    except ModuleNotFoundError: pass
    try: import runpy
    except ModuleNotFoundError: pass
    try: import importlib
    except ModuleNotFoundError: pass

    # Python Language Services
    try: import parser
    except ModuleNotFoundError: pass
    try: import ast
    except ModuleNotFoundError: pass
    try: import symtable
    except ModuleNotFoundError: pass
    try: import symbol
    except ModuleNotFoundError: pass
    try: import token
    except ModuleNotFoundError: pass
    try: import keyword
    except ModuleNotFoundError: pass
    try: import tokenize
    except ModuleNotFoundError: pass
    try: import tabnanny
    except ModuleNotFoundError: pass
    try: import pyclbr
    except ModuleNotFoundError: pass
    try: import py_compile
    except ModuleNotFoundError: pass
    try: import compileall
    except ModuleNotFoundError: pass
    try: import dis
    except ModuleNotFoundError: pass
    try: import pickletools
    except ModuleNotFoundError: pass

    # Miscellaneous Services
    try: import formatter
    except ModuleNotFoundError: pass

    # MS Windows Specific Services
    try: import msilib
    except ModuleNotFoundError: pass
    try: import msvcrt
    except ModuleNotFoundError: pass
    try: import winreg
    except ModuleNotFoundError: pass
    try: import winsound
    except ModuleNotFoundError: pass

    # Unix Specific Services
    try: import posix
    except ModuleNotFoundError: pass
    try: import pwd
    except ModuleNotFoundError: pass
    try: import spwd
    except ModuleNotFoundError: pass
    try: import grp
    except ModuleNotFoundError: pass
    try: import crypt
    except ModuleNotFoundError: pass
    try: import termios
    except ModuleNotFoundError: pass
    try: import tty
    except ModuleNotFoundError: pass
    try: import pty
    except ModuleNotFoundError: pass
    try: import fcntl
    except ModuleNotFoundError: pass
    try: import pipes
    except ModuleNotFoundError: pass
    try: import resource
    except ModuleNotFoundError: pass
    try: import nis
    except ModuleNotFoundError: pass
    try: import syslog
    except ModuleNotFoundError: pass

    # Superseded Modules
    try: import optparse
    except ModuleNotFoundError: pass
    try: import imp
    except ModuleNotFoundError: pass

    # Platform Specific modules
    try: import ntpath
    except ModuleNotFoundError: pass
    try: import posixpath
    except ModuleNotFoundError: pass


try: import numpy as np
except ModuleNotFoundError: pass
try: import pandas as pd
except ModuleNotFoundError: pass
try: import matplotlib.pyplot as plt
except ModuleNotFoundError: pass
try: import seaborn as sns
except ModuleNotFoundError: pass
try: import tqdm.tqdm as tqdm
except ModuleNotFoundError: pass

# pytorch modules
try: import torch
except ModuleNotFoundError: pass
try: import torch.nn as nn
except ModuleNotFoundError: pass
try: import torch.optim as optim
except ModuleNotFoundError: pass
try: import torch.nn.functional as F
except ModuleNotFoundError: pass
try: import torchtext
except ModuleNotFoundError: pass
try: import torchvision
except ModuleNotFoundError: pass
try: import torchaudio
except ModuleNotFoundError: pass

try: import gym
except ModuleNotFoundError: pass


# Save python file history into XDG_DATA_HOME if defined
if 'PYTHONHISTFILE' in os.environ:
    history = os.path.expanduser(os.environ['PYTHONHISTFILE'])
elif 'XDG_DATA_HOME' in os.environ:
    history = os.path.join(os.path.expanduser(os.environ['XDG_DATA_HOME']),
                           'python', 'python_history')
else:
    history = os.path.join(os.path.expanduser('~'),
                           '.python_history')

history = os.path.abspath(history)
_dir, _ = os.path.split(history)
os.makedirs(_dir, exist_ok=True)


if __name__ == '__main__':
    pass
