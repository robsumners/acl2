; Java Library
;
; Copyright (C) 2019 Kestrel Institute (http://www.kestrel.edu)
;
; License: A 3-clause BSD license. See the LICENSE file distributed with ACL2.
;
; Author: Alessandro Coglio (coglio@kestrel.edu)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package "JAVA")

(include-book "types")

(include-book "kestrel/std/system/function-name-listp" :dir :system)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defxdoc+ atj-java-primitive-arrays
  :parents (atj-implementation)
  :short "Representation of Java primitive arrays and operations on them,
          for ATJ."
  :long
  (xdoc::topstring
   (xdoc::p
    "In order to have ATJ generate Java code
     that manipulates Java primitive arrays,
     we use an approach similar to "
    (xdoc::seetopic "atj-java-primitives" "the one for Java primitive values")
    ". We use ACL2 functions that correspond to
     the Java primitive arrays and operations on them:
     when ATJ encounters these specific ACL2 functions,
     it translates them to corresponding Java constructs
     that operate on Java primitive arrays;
     this happens only when @(':deep') is @('nil') and @(':guards') is @('t').")
   (xdoc::p
    "The discussion "
    (xdoc::seetopic "atj-java-primitives" "here")
    " about derivations targeting
     the ACL2 functions that represent Java primitive values
     applies to Java primitive arrays as well.")
   (xdoc::p
    "As discussed "
    (xdoc::seetopic "atj-java-primitive-array-model" "here")
    ", currently the ACL2 functions that represent Java primitive arrays
     are part of ATJ, but (perhaps some generalization of them) could be
     part of the "
    (xdoc::seetopic "language" "language formalization")
    " at some point."))
  :order-subtopics t
  :default-parent t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defval *atj-java-primarray-reads*
  :short "List of the (the names of) the ACL2 functions that model
          the reading of components from Java primitive arrays."
  :long
  (xdoc::topstring
   (xdoc::p
    "The consists of the readers for all the Java primitive array types
     except @('float[]') and @('double[]'),
     which are currently not supported by ATJ."))
  '(boolean-array-read
    char-array-read
    byte-array-read
    short-array-read
    int-array-read
    long-array-read))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defval *atj-java-primarray-lengths*
  :short "List of the (the names of) the ACL2 functions that model
          the obtaining of lengths of Java primitive arrays."
  :long
  (xdoc::topstring
   (xdoc::p
    "The consists of the length functions for all the Java primitive array types
     except @('float[]') and @('double[]'),
     which are currently not supported by ATJ."))
  '(boolean-array-length
    char-array-length
    byte-array-length
    short-array-length
    int-array-length
    long-array-length))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defval *atj-java-primarray-fns*
  :short "List of (the names of) the ACL2 functions that model
          Java primitive array operations."
  :long
  (xdoc::topstring
   (xdoc::p
    "This just consists of the read and length functions for now.
     More will be added in the future."))
  (append *atj-java-primarray-reads*
          *atj-java-primarray-lengths*)
  ///
  (assert-event (function-name-listp *atj-java-primarray-fns* (w state)))
  (assert-event (no-duplicatesp-eq *atj-java-primarray-fns*)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defsection atj-types-for-java-primitive-arrays
  :short "ATJ types for the Java primitive array operations."

  ;; read operations:

  (def-atj-main-function-type boolean-array-read (:jboolean[] :jint) :jboolean)

  (def-atj-main-function-type char-array-read (:jchar[] :jint) :jchar)

  (def-atj-main-function-type byte-array-read (:jbyte[] :jint) :jbyte)

  (def-atj-main-function-type short-array-read (:jshort[] :jint) :jshort)

  (def-atj-main-function-type int-array-read (:jint[] :jint) :jint)

  (def-atj-main-function-type long-array-read (:jlong[] :jint) :jlong)

  ;; length operations:

  (def-atj-main-function-type boolean-array-length (:jboolean[]) :jint)

  (def-atj-main-function-type char-array-length (:jchar[]) :jint)

  (def-atj-main-function-type byte-array-length (:jbyte[]) :jint)

  (def-atj-main-function-type short-array-length (:jshort[]) :jint)

  (def-atj-main-function-type int-array-length (:jint[]) :jint)

  (def-atj-main-function-type long-array-length (:jlong[]) :jint))
