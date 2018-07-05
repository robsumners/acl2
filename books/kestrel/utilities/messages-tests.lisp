; Messages -- Tests
;
; Copyright (C) 2018 Kestrel Institute (http://www.kestrel.edu)
;
; License: A 3-clause BSD license. See the LICENSE file distributed with ACL2.
;
; Author: Alessandro Coglio (coglio@kestrel.edu)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package "ACL2")

(include-book "messages")
(include-book "testing")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(assert! (maybe-msgp nil))

(assert! (maybe-msgp "abc"))

(assert! (maybe-msgp (msg "xy")))

(assert! (maybe-msgp (msg "~x0 and ~x1" #\a '(1 2 3))))

(assert! (not (maybe-msgp 33)))

(assert! (not (maybe-msgp '(#\c "a"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(assert! (msg-listp nil))

(assert! (msg-listp '("abc" "xy")))

(assert! (msg-listp (list "qqq" (msg "~x0 and ~x1" #\a '(1 2 3)))))

(assert! (not (msg-listp 7/4)))

(assert! (not (msg-listp '("ABU" :no))))
