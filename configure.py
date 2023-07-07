#!/usr/bin/python

# plugin names, relative to `scripting/`
plugins = [
	'sf2_hint_on_look_public.sp',
]

# files to copy to builddir, relative to root
# plugin names from previous list will be copied automatically
copy_files = [
	'translations/sf2_hint.phrases.txt'
]

# additional directories for sourcepawn include lookup
# `scripting/include` is explicitly included
include_dirs = [
	'third_party/vendored'
]

# required version of spcomp (presumably pinned to SM version)
spcomp_min_version = (1, 11)

########################
# build.ninja script generation below.

import contextlib
import misc.ninja_syntax as ninja_syntax
import misc.spcomp_util
import os
import sys
import argparse
import platform
import shlex
import shutil
import subprocess

parser = argparse.ArgumentParser('Configures the project.')
parser.add_argument('--spcomp-dir',
		help = 'Directory with the SourcePawn compiler.  Will check PATH if not specified.')

args = parser.parse_args()

print("""Checking for SourcePawn compiler...""")
spcomp = shutil.which('spcomp', path = args.spcomp_dir)
if 'x86_64' in platform.machine():
	# Use 64-bit spcomp if architecture supports it
	spcomp = shutil.which('spcomp64', path = args.spcomp_dir) or spcomp
if not spcomp:
	raise FileNotFoundError('Could not find SourcePawn compiler.')

available_version = misc.spcomp_util.extract_version(spcomp)
version_string = '.'.join(map(str, available_version))
print('Found SourcePawn compiler version', version_string, 'at', os.path.abspath(spcomp))

if spcomp_min_version > available_version:
	raise ValueError("Failed to meet required compiler version "
			+ '.'.join(map(str, spcomp_min_version)))

# properly handle quoting within params
if platform.system() == "Windows":
	arg_list = subprocess.list2cmdline
else:
	arg_list = shlex.join

with contextlib.closing(ninja_syntax.Writer(open('build.ninja', 'wt'))) as build:
	build.comment('This file is used to build SourceMod plugins with ninja.')
	build.comment('The file is automatically generated by configure.py')
	build.newline()
	
	vars = {
		'configure_args': arg_list(sys.argv[1:]),
		'root': '.',
		'builddir': 'build',
		'spcomp': spcomp,
		'spcflags': [ '-i${root}/scripting/include', '-h', '-v0' ]
	}
	
	vars['spcflags'] += ('-i{}'.format(d) for d in include_dirs)
	
	for key, value in vars.items():
		build.variable(key, value)
	build.newline()
	
	build.comment("""Regenerate build files if build script changes.""")
	build.rule('configure',
			command = sys.executable + ' ${root}/configure.py ${configure_args}',
			description = 'Reconfiguring build', generator = 1)
	
	build.build('build.ninja', 'configure',
			implicit = [ '${root}/configure.py', '${root}/misc/ninja_syntax.py' ])
	build.newline()
	
	build.rule('spcomp', deps = 'msvc',
			command = '"${spcomp}" ${in} ${spcflags} -o ${out}',
			description = 'Compiling ${out}')
	build.newline()
	
	# Platform-specific copy instructions
	if platform.system() == "Windows":
		build.rule('copy', command = 'cmd /c copy ${in} ${out} > NUL',
				description = 'Copying ${out}')
	elif platform.system() == "Linux":
		build.rule('copy', command = 'cp ${in} ${out}', description = 'Copying ${out}')
	build.newline()
	
	build.comment("""Compile plugins specified in `plugins` list""")
	for plugin in plugins:
		smx_plugin = os.path.splitext(plugin)[0] + '.smx'
		
		sp_file = os.path.normpath(os.path.join('$root', 'scripting', plugin))
		
		smx_file = os.path.normpath(os.path.join('$builddir', 'plugins', smx_plugin))
		build.build(smx_file, 'spcomp', sp_file)
	build.newline()
	
	build.comment("""Copy plugin sources to build output""")
	for plugin in plugins:
		sp_file = os.path.normpath(os.path.join('$root', 'scripting', plugin))
		
		dist_sp = os.path.normpath(os.path.join('$builddir', 'scripting', plugin))
		build.build(dist_sp, 'copy', sp_file)
	build.newline()
	
	build.comment("""Copy other files from source tree""")
	for filepath in copy_files:
		build.build(os.path.normpath(os.path.join('$builddir', filepath)), 'copy',
				os.path.normpath(os.path.join('$root', filepath)))
