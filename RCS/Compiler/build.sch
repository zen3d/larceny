; -*- Scheme -*-
;
; Load the heap with the Scheme 313 compiler

(display "Building development system...") (newline) (newline)

; Version 3isms
; (set! *optimize-level* 1)
; (display "Chez Scheme v3.0 patch...") (newline)
; (load "../Chez/sparcasm.patch")

(display "Chez Scheme/MacScheme compatibility package...") (newline)
(load "../Chez/compat.ss")
(display "Make utility...") (newline)
(load "make.sch")
(display "Compiler proper...") (newline)
(load "sets.sch")
(load "pass1.imp.sch")
(load "pass1.aux.sch")
(load "pass1.sch")
(load "pass2.aux.sch")
(load "pass2.sch")
; (load "pass3.sch")
(load "pass4.imp.sch")
(load "pass4.aux.sch")
(load "pass4p1.sch")
(load "pass4p2.sch")
(display "generic assembler...") (newline)
(parameterize ((optimize-level 2))
  (load "assembler.sch"))
(display "sparc header files...") (newline)
(load "../Sparc/registers.sch.h")
(load "../Sparc/offsets.sch.h")
(load "../Sparc/layouts.sch.h")
(load "../Sparc/millicode.sch.h")
(display "sparc assembler and code generator...") (newline)
(load "../Lib/exceptions.sch")
(parameterize ((optimize-level 2))
  (load "../Sparc/asm.sparc.sch"))
(load "../Sparc/gen-msi.sch")
(load "../Sparc/gen-primops.sch")
(display "sparc disassembler...") (newline)
(load "../Sparc/disasm.sparc.sch")
(display "bootstrap heap dumper...") (newline)
(parameterize ((optimize-level 3))
  (load "dumpheap.sch"))
(display "Compiler driver...") (newline)
(load "compile313.sch")
;; The next two do magic things for the top level compilation.
(load "expand313.sch")
(load "/home/systems/lth/lib/rewrite.sch")
;; Utilities
(load "printlap.sch")
(load "utils.sch")
(display "Make script for library...") (newline)
(load "../Lib/makefile.sch")
(set! listify? #f)
(display "Listing is off") (newline)
(newline)
