#!/usr/bin/tclsh8.5

#
# Turn the XML-formatted documentation into Dokuwiki syntax.
#

package require tdom



# pre-initialize the parser
array set state { depth 6 cur "" dw-wrap 0 needsname 0 }


# the parsing callbacks
proc parse xml {
	set ::S {}
	set p [expat -elementstartcommand el \
					-characterdatacommand  ch \
					-elementendcommand  ee ]
	if [catch {$p parse $xml} res] {
		puts "Error: $res"
	}
}

#---- Callbacks for start, end, character data

proc el { type attrs } {
	global state

	set state(cur) $type

	if { $type eq "section" } {

		puts "[string repeat = $state(depth)] [dict get $attrs title] [string repeat = $state(depth)]"
		puts ""
		incr state(depth) -1

	} elseif { $type eq "desc" } {

		set stg [string trim $attrs]
		if { $stg != "" } {
			puts $stg
			puts ""
		}

	} elseif { $type eq "function" } {

		# do nothing here ..

	} elseif { $type eq "proto" } {

		# entering a prototype, we need to try to get the name
		set state(needsname) 1

	} else {

		puts "$type = $attrs"

	}

}

proc ee { type } {
	global state

	if { $type eq "section" } {
		incr state(depth)
	} elseif { $type eq "proto" } {
		puts "</xterm>"
		puts ""
	}

	set state(cur) ""

}


proc ch { stg } {
	global state

	set stg [string trim $stg]

	if { $state(cur) eq "proto" } {

		# we're in a prototype block, but we need to get the function/procedure name before continuing
		if { $state(needsname) } {

			# get the function name out of the prototype
			if { [regexp {^(.+?)( \*\*| //| \(|$)} $stg - name] } {
				puts "[string repeat = $state(depth)] ${name} [string repeat = $state(depth)]"
				puts ""
			}

			# now, start the prototype markup
			puts "<xterm>"

			# and reset the "needs name" flag
			set state(needsname) 0

		}

		# and wrap the prototype in the "don't parse anything" markup
		if { $state(dw-wrap) } {
			set stg "%%$stg%%"
		}

	}


	# if it's a non-empty element, print it out, and follow by a newline if it's not a prototype
	if { $stg != "" } {
		puts $stg
		if { $state(cur) ne "proto" } {
			puts ""
		}
	}

}




# print instructions for use
proc print_help {} {
   puts "Use [info script] thus:"
   puts "[info script] ?-dw? input.xml"
   puts ""
   puts "The -dw flag will produce the output which is safer to dokuwiki"
   puts "but is less human-friendly."
   puts ""
}


# read the input file
if { [llength $argv] ni { 1 2 } } {
   print_help
} else {

   # do we have an argument?
   if { [llength $argv] == 2 } {
      set opt [lindex $argv 0]

      switch -- $opt {
 	 "-dw" {
	    set state(dw-wrap) 1
	 }
	 default {
	    puts "Unrecognized option $opt!"
	    puts ""
	    print_help
	    exit
	 }
      }

   }

   set file [lindex $argv end]

	# read in the file
	set fh [open $file]
	set data [read $fh [file size $file]]
	close $fh

	parse $data

}
