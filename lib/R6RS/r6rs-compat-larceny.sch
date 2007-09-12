;;;===============================================================================
;;;
;;; Larceny compatibility file (tested on Larceny version 0.94)
;;;
;;; Uncomment appropriate LOAD comand in macros-core.scm
;;;
;;;===============================================================================

; Most of this was written by Will Clinger by copying
; code written by Lars Hansen, Felix Klock, et cetera.

;; A numeric string that uniquely identifies this run in the universe

(define (ex:unique-token) (ex:unique-token3)) ; see below

;; The letrec black hole and corresponding setter.

(define ex:undefined 'undefined)
(define ex:undefined-set! 'set!)

;; Single-character symbol prefixes.
;; No builtins may start with one of these.
;; If they do, select different values here.

(define ex:guid-prefix "&")
(define ex:free-prefix "~")

;; These are only partial implementations for specific use cases needed.
;; Full implementations should be provided by host implementation.

(define (for-all proc l . ls)
  (or (null? l)
      (and (apply proc (car l) (map car ls))
           (apply for-all proc (cdr l) (map cdr ls)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; There are three separate implementations of ex:unique-token,
; because each has problems.  For now, pick your poison.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; FIXME:  This might not work with Windows, and probably
; doesn't work with Common Larceny.

(define (ex:unique-token1)

  ; Returns the number of seconds since Jan 1, 1970 00:00:00 GMT.
  ; If the argument is non-#f then it should be a bytevector of length  
  ; at least 4, in which to store the time.  See time(2).

  (define unix:time
    (let ((_time (foreign-procedure "time" '(boxed) 'int)))
      (lambda (arg)
        (if (and arg
                 (not (and (bytevector? arg)
                           (>= (bytevector-length arg) 4))))
            (error "Invalid parameter to unix:time"))
        (_time arg))))

  (number->string (unix:time #f)))

; FIXME:  This works with all varieties of Larceny, but isn't
; as likely to be globally unique.

(define (ex:unique-token2)
  (number->string (memstats-elapsed-time (memstats))))

; FIXME:  This works with all varieties of Larceny, but
; writes a file in the current directory.

(define (ex:unique-token3)
  (let ((p (open-output-file "temp")))
    (write #f p)
    (close-output-port p))
  (let ((time (file-modification-time "temp")))
    (number->string
     (+ (vector-ref time 5)
        (* (vector-ref time 4) 60)
        (* (vector-ref time 3) 3600)
        (* (vector-ref time 2) 86400)
        ; assumes 31 d/m - just need unique number
        (* (vector-ref time 1) 2678400)
        (* (- (vector-ref time 0) 2000) 32140800)))))
