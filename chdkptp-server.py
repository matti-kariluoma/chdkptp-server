#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import unicode_literals, print_function

"""
Wraps one or more instances of chdkptp and provides a communication 
channel (here, a tcp socket) to communicate with each chdkptp instance.
"""
__author__ = 'Matti Kariluoma <matti@kariluo.ma>'
__copyright__ = 'Copyright 2013, Matti Kariluoma'
__license__ = 'GPL'
__version__ = '0.1.0'
			
if __name__ == "__main__":
	from optparse import OptionParser
	import ConfigParser

	parser = OptionParser()
	parser.add_option('-c', '--config',
			dest='config_filename',
			default='chdkptp-server.ini',
			help='use the specified config file',
			metavar='FILE'
		)
	options, args = parser.parse_args()

	config = ConfigParser.ConfigParser()
	config.read(options.config_filename)
	host = config.get('server', 'host')
	port = config.get('server', 'port')
	print((host, port))
	exit(0)
