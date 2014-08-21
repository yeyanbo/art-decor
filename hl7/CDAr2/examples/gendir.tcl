global ctr
set ctr 0

proc ds {op dir} {
    global ctr
    
    set skipdirs [list coreschemas schemas xsl]
    foreach l [glob -nocomplain $dir/*] {
        if { [regexp -- {^\./} $l] } {
            set l [string range $l 2 end]
        }
        if { [file isdirectory $l] } {
            if { [lsearch $skipdirs $l] >= 0 } { continue }
            
            lappend op "            <li><b>$l</b>"
            lappend op "            <ul>"
            set op [ds $op $l]
            lappend op "            </ul></li>"
        } elseif { [file extension $l] == ".xml" } {
            regsub -all " " $l "%20" ll
            set depth [regsub -all {/} $ll "" ttt] 
            set lang  [rpl $l $depth]
            incr ctr
            
            if { [string length $lang] > 0 } { set lang "- language is $lang" }
            
            lappend op "            <li><a href=\"$ll\">$l</a> $lang</li>"
        }
    }
    return $op
}

proc rpl { f depth } {
    set kdList [list _CDA_Kerndossier_Patient1_JorisHalkema.xml _CDA_Kerndossier_Patient2_MartinBrouwer.xml]

    set fi [open $f r]
    fconfigure $fi -translation {binary binary}
    set c  [read $fi]
    close $fi
    
    set full "" ; set lang "" ; set pfx ""
    for {set i 0} {$i < $depth} {incr i} { append pfx "../" }
    
    regsub -all {<\?xml-stylesheet type="text/xsl" href="[^"]+"\?>\r?\n} $c "" c
    if { [lsearch $kdList [file tail $f]] >= 0 } {
        regsub -- {(<([^:]+:)?ClinicalDocument)} $c "<?xml-stylesheet type=\"text/xsl\" href=\"${pfx}xsl/cda-kerndossier.xsl\"?>\n\\1" c
    } else {
        regsub -- {(<([^:]+:)?ClinicalDocument)} $c "<?xml-stylesheet type=\"text/xsl\" href=\"${pfx}xsl/cda-singleton.xsl\"?>\n\\1" c
    }
    regexp -- {<languageCode[^>]+code="([^"]+)"} $c full lang
    
    puts stdout "$full $lang"

    set fo [open $f w+]
    fconfigure $fo -translation {binary binary}
    puts -nonewline $fo $c
    close $fo
    
    return $lang
}

set op {}
set op [ds $op .]

set opH {}
lappend opH "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
lappend opH "<!DOCTYPE html SYSTEM \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">"
lappend opH "<html xmlns=\"http://www.w3.org/1999/xhtml\">"
lappend opH "    <head><title>CDA XSL Test</title></head>"
lappend opH "    <body style=\"font-family: Verdana;font-size:10pt;\">"
lappend opH "        <h4>Click any of these $ctr files to view. A file that has its languageCode set will render in that language if available, or revert to the default language en-US</h4>"
lappend opH "        <p><a href=\"xsl/cda_l10n.xml\">View the list of translations</a>. Note: this file is big so loading takes a while.</p>"
lappend opH "        <p>To download: use <a href=\"https://public.me.com/ahenket/CDA\">https://public.me.com/ahenket/CDA</a>. Select the file or folder, and use the button with the down arrow at the top of the screen. Folders are compressed before download."
lappend opH "        <ul>"

set opF {}
lappend opF "        </ul>"
lappend opF "    </body>"
lappend opF "</html>"

set fo    [open index.html w+]
puts $fo  [join $opH \n]
puts $fo  [join $op \n]
puts $fo  [join $opF \n]
close $fo

puts "Processed $ctr files"
