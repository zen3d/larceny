;;; To use (a corrected version of) the SRFI 132 reference implementation,
;;; comment out the following library definition.


(define-library (srfi 132 use-r6rs-sorting))

(define-library (srfi 132 sorting)

  (export list-sorted?               vector-sorted?
          list-sort                  vector-sort
          list-stable-sort           vector-stable-sort
          list-sort!                 vector-sort!
          list-stable-sort!          vector-stable-sort!
          list-merge                 vector-merge
          list-merge!                vector-merge!
          list-delete-neighbor-dups  vector-delete-neighbor-dups
          list-delete-neighbor-dups! vector-delete-neighbor-dups!
          vector-find-median         vector-find-median!   ; not part of ref impl
          vector-select!                                   ; not part of ref impl
          )

  (import (except (scheme base) vector-copy vector-copy!)
          (rename (only (scheme base) vector-copy vector-copy!)
                  (vector-copy  r7rs-vector-copy)
                  (vector-copy! r7rs-vector-copy!))
          (scheme cxr)
          (only (rnrs base) assert)
          (rename (rnrs sorting)
                  (list-sort    r6rs-list-sort)
                  (vector-sort  r6rs-vector-sort)
                  (vector-sort! r6rs-vector-sort!))
          (only (srfi 27) random-integer))

  ;; If the (srfi 132 use-r6rs-sorting) library is defined above,
  ;; we'll use the (rnrs sorting) library for all sorting and trim
  ;; Olin's reference implementation to remove unnecessary code.
  ;; The merge.scm file, for example, extracts the list-merge,
  ;; list-merge!, vector-merge, and vector-merge! procedures from
  ;; Olin's lmsort.scm and vmsort.scm files.

  (cond-expand

   ((library (srfi 132 use-r6rs-sorting))
    (include "132/merge.scm")
    (include "132/delndups.scm")     ; list-delete-neighbor-dups etc
    (include "132/sortp.scm")        ; list-sorted?, vector-sorted?
    (include "132/vector-util.scm")
    (include "132/sortfaster.scm"))

   (else
    (include "132/delndups.scm")     ; list-delete-neighbor-dups etc
    (include "132/lmsort.scm")       ; list-merge, list-merge!
    (include "132/sortp.scm")        ; list-sorted?, vector-sorted?
    (include "132/vector-util.scm")
    (include "132/vhsort.scm")
    (include "132/visort.scm")
    (include "132/vmsort.scm")       ; vector-merge, vector-merge!
    (include "132/vqsort2.scm")
    (include "132/vqsort3.scm")
    (include "132/sort.scm")))

  ;; Added for Larceny.

  (include "132/select.scm")

  )

(define-library (srfi 132)

  (export list-sorted?               vector-sorted?
          list-sort                  vector-sort
          list-stable-sort           vector-stable-sort
          list-sort!                 vector-sort!
          list-stable-sort!          vector-stable-sort!
          list-merge                 vector-merge
          list-merge!                vector-merge!
          list-delete-neighbor-dups  vector-delete-neighbor-dups
          list-delete-neighbor-dups! vector-delete-neighbor-dups!
          vector-find-median         vector-find-median!   ; not part of ref impl
          vector-select!                                   ; not part of ref impl
          )

  (import (srfi 132 sorting)))
