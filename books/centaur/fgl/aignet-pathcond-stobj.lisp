; GL - A Symbolic Simulation Framework for ACL2
; Copyright (C) 2008-2013 Centaur Technology
;
; Contact:
;   Centaur Technology Formal Verification Group
;   7600-C N. Capital of Texas Highway, Suite 300, Austin, TX 78731, USA.
;   http://www.centtech.com/
;
; License: (An MIT/X11-style license)
;
;   Permission is hereby granted, free of charge, to any person obtaining a
;   copy of this software and associated documentation files (the "Software"),
;   to deal in the Software without restriction, including without limitation
;   the rights to use, copy, modify, merge, publish, distribute, sublicense,
;   and/or sell copies of the Software, and to permit persons to whom the
;   Software is furnished to do so, subject to the following conditions:
;
;   The above copyright notice and this permission notice shall be included in
;   all copies or substantial portions of the Software.
;
;   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
;   FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
;   DEALINGS IN THE SOFTWARE.
;
; Original author: Sol Swords <sswords@centtech.com>
 
(in-package "AIGNET")

(include-book "centaur/aignet/mark-impls" :dir :system)
(include-book "centaur/misc/intstack" :dir :system)
(include-book "centaur/fty/baselists" :dir :system)
(local (include-book "theory"))
(local (std::add-default-post-define-hook :fix))



(fty::defalist nbalist :pred nbalistp :key-type natp :val-type bitp :true-listp t :unique-keys t)


(local (defthm cdr-hons-assoc-equal-when-nbalistp
         (implies (nbalistp x)
                  (and (iff (cdr (hons-assoc-equal n x))
                            (hons-assoc-equal n x))
                       (iff (bitp (cdr (hons-assoc-equal n x)))
                            (hons-assoc-equal n x))))))


(defstobj nbalist-stobj$c
  (nbalist-bits$c :type bitarr)
  (nbalist-stack$c :type acl2::intstack))

(define nbalist-stobj-nbalist$c-logic ((stack acl2::intstack$ap)
                                        (bits bit-listp))
  :returns (nbalist)
  (if (atom stack)
      nil
    (cons (cons (nfix (car stack)) (bfix (nth (car stack) bits)))
          (nbalist-stobj-nbalist$c-logic (cdr stack) bits)))
  ///
  (defret lookup-in-nbalist-stobj-nbalist$c-logic
    (equal (hons-assoc-equal key nbalist)
           (and (natp key)
                (member key (acl2::nat-list-fix stack))
                (cons key (bfix (nth key bits))))))

  (defret nbalistp-of-nbalist-stobj-nbalist$c-logic
    (implies (no-duplicatesp-equal (acl2::nat-list-fix stack))
             (nbalistp nbalist)))
  
  (defret len-of-<fn>
    (equal (len nbalist)
           (len stack)))

  (local (defthm nth-of-bit-list-fix
           (bit-equiv (nth n (bit-list-fix x))
                      (nth n x))
           :hints(("Goal" :in-theory (enable nth)))))

  (defthm nbalist-stobj-nbalist$c-logic-of-update-non-member
    (implies (not (member-equal (nfix n) (acl2::nat-list-fix stack)))
             (equal (nbalist-stobj-nbalist$c-logic stack (update-nth n val bits))
                    (nbalist-stobj-nbalist$c-logic stack bits))))

  (defthm nbalist-stobj-nbalist$c-logic-of-resize-bits
    (implies (<= (len bits) (nfix n))
             (equal (nbalist-stobj-nbalist$c-logic stack (resize-list bits n 0))
                    (nbalist-stobj-nbalist$c-logic stack bits))))

  (defthm nbalist-stobj-nbalist$c-logic-of-nat-list-fix
    (equal (nbalist-stobj-nbalist$c-logic (acl2::nat-list-fix stack) bits)
           (nbalist-stobj-nbalist$c-logic stack bits))
    :hints(("Goal" :in-theory (enable acl2::nat-list-fix))))

  (defthm nth-of-nbalist-stobj-nbalist$c-logic
    (equal (nth n (nbalist-stobj-nbalist$c-logic stack bits))
           (and (< (nfix n) (len stack))
                (cons (nfix (nth n stack))
                      (bfix (nth (nth n stack) bits)))))
    :hints(("Goal" :in-theory (enable nth)))))


(define nbalist-stobj-nbalist$c-aux ((n natp)
                                      acl2::intstack
                                      bitarr)
  :measure (nfix (- (acl2::intstack-count acl2::intstack) (nfix n)))
  :guard (<= n (acl2::intstack-count acl2::intstack))
  :returns (nbalist (equal nbalist
                           (nbalist-stobj-nbalist$c-logic (nthcdr n acl2::intstack) bitarr))
                    :hints(("Goal" :induct t)
                           (and stable-under-simplificationp
                                '(:expand ((nbalist-stobj-nbalist$c-logic (nthcdr n acl2::intstack) bitarr))))))
  :prepwork ((local (defthm nthcdr-of-nil
                      (equal (nthcdr n nil) nil)))
             (local (defthm consp-of-nthcdr
                      (iff (consp (nthcdr n x))
                           (< (nfix n) (len x)))
                      :hints(("Goal" :in-theory (enable nthcdr)))))
             (local (defthm car-of-nthcdr
                      (equal (car (nthcdr n x))
                             (nth n x))
                      :hints(("Goal" :in-theory (enable nthcdr nth)))))
             (local (defthm cdr-of-nthcdr
                      (equal (cdr (nthcdr n x))
                             (nthcdr n (cdr x)))
                      :hints(("Goal" :in-theory (enable nthcdr))))))
  (if (mbe :logic (zp (nfix (- (acl2::intstack-count acl2::intstack) (nfix n))))
           :exec (eql n (acl2::intstack-count acl2::intstack)))
      nil
    (b* ((elt (acl2::intstack-nth n acl2::intstack))
         (bit (mbe :logic (get-bit elt bitarr)
                   :exec (if (< elt (bits-length bitarr))
                             (get-bit elt bitarr)
                           0))))
      (cons (cons elt bit)
            (nbalist-stobj-nbalist$c-aux (1+ (lnfix n)) acl2::intstack bitarr)))))




(local (defthm nat-listp-when-u32-listp
         (implies (acl2::u32-listp x)
                  (nat-listp x))))

(define nbalist-stobj-nbalist$c (nbalist-stobj$c)
  :returns (nbalist)
  (mbe :logic (non-exec
               (nbalist-stobj-nbalist$c-logic (nth *nbalist-stack$c* nbalist-stobj$c)
                                               (nth *nbalist-bits$c* nbalist-stobj$c)))
       :exec (stobj-let ((bitarr (nbalist-bits$c nbalist-stobj$c))
                         (acl2::intstack (nbalist-stack$c nbalist-stobj$c)))
                        (nbalist)
                        (nbalist-stobj-nbalist$c-aux 0 acl2::intstack bitarr)
                        nbalist))
  ///
  (defret lookup-in-nbalist-stobj-nbalist$c
    (equal (hons-assoc-equal key nbalist)
           (and (natp key)
                (member key (acl2::nat-list-fix (nth *nbalist-stack$c* nbalist-stobj$c)))
                (cons key (bfix (nth key (nth *nbalist-bits$c* nbalist-stobj$c)))))))

  (defret nbalistp-of-nbalist-stobj-nbalist$c
    (implies (nbalist-stobj$cp nbalist-stobj$c)
             (nbalistp nbalist)))
  
  (defret len-of-<fn>
    (implies (nbalist-stobj$cp nbalist-stobj$c)
             (equal (len nbalist)
                    (len (nth *nbalist-stack$c* nbalist-stobj$c))))))

(defun-sk nbalist-stobj$c-size-ok (nbalist-stobj$c)
  (forall id
          (implies (member id (acl2::nat-list-fix (nth *nbalist-stack$c* nbalist-stobj$c)))
                   (< id (len (nth *nbalist-bits$c* nbalist-stobj$c)))))
  :rewrite :direct)

(in-theory (disable nbalist-stobj$c-size-ok
                    nbalist-stobj$c-size-ok-necc))
(local (in-theory (enable nbalist-stobj$c-size-ok-necc)))

(define nbalist-len$c (nbalist-stobj$c)
  :returns (len natp :rule-classes :type-prescription)
  :enabled t
  (mbe :logic (len (nbalist-stobj-nbalist$c nbalist-stobj$c))
       :exec (stobj-let ((acl2::intstack (nbalist-stack$c nbalist-stobj$c)))
                        (len)
                        (acl2::intstack-count acl2::intstack)
                        len)))


(define nbalist-lookup$c ((id natp :type (unsigned-byte 32))
                          nbalist-stobj$c)
  :guard (non-exec (ec-call (nbalist-stobj$c-size-ok nbalist-stobj$c)))
  :returns (ans acl2::maybe-bitp :rule-classes :type-prescription)
  (mbe :logic (cdr (hons-assoc-equal (nfix id)
                                     (nbalist-stobj-nbalist$c nbalist-stobj$c)))
       :exec (stobj-let ((acl2::intstack (nbalist-stack$c nbalist-stobj$c))
                         (bitarr (nbalist-bits$c nbalist-stobj$c)))
                        (ans)
                        (and (acl2::intstack-member^ id acl2::intstack)
                             (get-bit id bitarr))
                        ans)))

(define nbalist-push$c ((id natp :type (unsigned-byte 32))
                        (val bitp)
                        nbalist-stobj$c)
  :guard (and (non-exec (ec-call (nbalist-stobj$c-size-ok nbalist-stobj$c)))
              (not (nbalist-lookup$c id nbalist-stobj$c)))
  :returns (new-nbalist-stobj$c)
  (mbe :logic (if (nbalist-lookup$c id nbalist-stobj$c)
                  nbalist-stobj$c
                (stobj-let ((acl2::intstack (nbalist-stack$c nbalist-stobj$c))
                            (bitarr (nbalist-bits$c nbalist-stobj$c)))
                           (acl2::intstack bitarr)
                           (b* ((acl2::intstack (non-exec (acl2::nat-list-fix acl2::intstack)))
                                (acl2::intstack (acl2::intstack-push^ id acl2::intstack))
                                (bitarr (if (< (nfix id) (bits-length bitarr))
                                            bitarr
                                          (resize-bits (max 16 (* 2 (nfix id))) bitarr)))
                                (bitarr (set-bit id val bitarr)))
                             (mv acl2::intstack bitarr))
                           nbalist-stobj$c))
       :exec (stobj-let ((acl2::intstack (nbalist-stack$c nbalist-stobj$c))
                         (bitarr (nbalist-bits$c nbalist-stobj$c)))
                        (acl2::intstack bitarr)
                        (b* ((acl2::intstack (acl2::intstack-push^ id acl2::intstack))
                             (bitarr (if (< id (bits-length bitarr))
                                         bitarr
                                       (resize-bits (max 16 (* 2 id)) bitarr)))
                             (bitarr (set-bit id val bitarr)))
                          (mv acl2::intstack bitarr))
                        nbalist-stobj$c))
  ///

  (defret nbalist-stobj-nbalist$c-of-nbalist-push$c
    (equal (nbalist-stobj-nbalist$c new-nbalist-stobj$c)
           (b* ((old-nbalist (nbalist-stobj-nbalist$c nbalist-stobj$c)))
             (if (hons-assoc-equal (nfix id) old-nbalist)
                 old-nbalist
               (cons (cons (nfix id) (bfix val)) old-nbalist))))
    :hints(("Goal" :in-theory (enable nbalist-stobj-nbalist$c
                                      nbalist-stobj-nbalist$c-logic
                                      nbalist-lookup$c))))

  (defret nbalist-stobj$c-size-ok-of-<fn>
    (implies (nbalist-stobj$c-size-ok nbalist-stobj$c)
             (nbalist-stobj$c-size-ok new-nbalist-stobj$c))
    :hints ((and stable-under-simplificationp
                 (let ((lit (assoc 'nbalist-stobj$c-size-ok clause)))
                   `(:expand (,lit)
                     :use ((:instance nbalist-stobj$c-size-ok-necc
                            (id (nbalist-stobj$c-size-ok-witness . ,(cdr lit)))))
                     :in-theory (disable nbalist-stobj$c-size-ok-necc)))))))

(define nbalist-pop$c (nbalist-stobj$c)
  :guard (not (equal 0 (nbalist-len$c nbalist-stobj$c)))
  :returns new-nbalist-stobj$c
  (stobj-let ((acl2::intstack (nbalist-stack$c nbalist-stobj$c)))
             (acl2::intstack)
             (acl2::intstack-pop acl2::intstack)
             nbalist-stobj$c)
  ///
  (defret nbalist-stobj-nbalist$c-of-nbalist-pop$c
    (equal (nbalist-stobj-nbalist$c new-nbalist-stobj$c)
           (cdr (nbalist-stobj-nbalist$c nbalist-stobj$c)))
    :hints(("Goal" :in-theory (enable nbalist-stobj-nbalist$c
                                      nbalist-stobj-nbalist$c-logic))))

  (defret nbalist-stobj$c-size-ok-of-<fn>
    (implies (nbalist-stobj$c-size-ok nbalist-stobj$c)
             (nbalist-stobj$c-size-ok new-nbalist-stobj$c))
    :hints ((and stable-under-simplificationp
                 (let ((lit (assoc 'nbalist-stobj$c-size-ok clause)))
                   `(:computed-hint-replacement
                     ((and stable-under-simplificationp
                           '(:in-theory (enable acl2::nat-list-fix))))
                     :expand (,lit)
                     :use ((:instance nbalist-stobj$c-size-ok-necc
                            (id (nbalist-stobj$c-size-ok-witness . ,(cdr lit)))))
                     :in-theory (e/d ()
                                     (nbalist-stobj$c-size-ok-necc))))))))


(define nbalist-stobj-nthkey$c ((n natp)
                                nbalist-stobj$c)
  :guard (< n (nbalist-len$c nbalist-stobj$c))
  (stobj-let ((acl2::intstack (nbalist-stack$c nbalist-stobj$c)))
             (elt)
             (acl2::intstack-nth n acl2::intstack)
             elt))



(define nbalist-stobj$ap (nbalist)
  :enabled t
  (nbalistp nbalist))

(define create-nbalist-stobj$a () nil)

(define nbalist-stobj-len$a ((nbalist nbalist-stobj$ap))
  :enabled t
  (len (nbalist-fix nbalist)))

(define nbalist-lookup ((id natp)
                        (nbalist nbalistp))
  :returns ans
  (cdr (hons-get (nfix id) (nbalist-fix nbalist))))

(local (in-theory (enable nbalist-lookup)))

(define nbalist-stobj-lookup$a ((id (unsigned-byte-p 32 id))
                                (nbalist nbalist-stobj$ap))
  :enabled t
  (nbalist-lookup id nbalist))

(define nbalist-stobj-push$a ((id (unsigned-byte-p 32 id))
                              (val bitp)
                              (nbalist nbalist-stobj$ap))
  :guard (not (nbalist-stobj-lookup$a id nbalist))
  :enabled t
  (nbalist-fix (cons (cons id val) nbalist)))

(define nbalist-stobj-pop$a ((nbalist nbalist-stobj$ap))
  :enabled t
  :guard (not (equal 0 (nbalist-stobj-len$a nbalist)))
  :prepwork ((local (in-theory (enable nbalistp))))
  (cdr (nbalist-fix nbalist)))


  
(define nbalist-stobj-nbalist$a ((nbalist nbalist-stobj$ap))
  :enabled t
  (nbalist-fix nbalist))


(local (defthm consp-of-nth-when-nbalistp
         (implies (and (nbalistp x)
                       (< (nfix n) (len x)))
                  (consp (nth n x)))
         :hints(("Goal" :in-theory (enable nth nbalistp)))))

(local (defthm true-listp-when-nbalistp
         (implies (nbalistp x)
                  (true-listp x))
         :hints(("Goal" :in-theory (enable nbalistp)))))

(define nbalist-stobj-nthkey$a ((n natp)
                                (nbalist nbalist-stobj$ap))
  :guard (< n (nbalist-stobj-len$a nbalist))
  :enabled t
  (car (nth n (nbalist-fix nbalist))))

;; (define nbalist-stobj-nthval$a ((n natp)
;;                                 (nbalist nbalist-stobj$ap))
;;   :guard (< n (nbalist-stobj-len$a nbalist))
;;   (cdr (nth n (nbalist-fix nbalist))))



(encapsulate nil
  (local
   (define nbalist-stobj-corr (nbalist-stobj$c nbalist)
     :enabled t
     :verify-guards nil
     (and (equal nbalist (nbalist-stobj-nbalist$c nbalist-stobj$c))
          (nbalist-stobj$c-size-ok nbalist-stobj$c))))

  (local (defthm nbalist-stobj$c-size-ok-of-empty
           (nbalist-stobj$c-size-ok '(nil nil))
           :hints(("Goal" :in-theory (enable nbalist-stobj$c-size-ok)))))

  (local (defthm nbalist-stobj-nbalist$c-of-empty
           (not (nbalist-stobj-nbalist$c '(nil nil)))
           :hints(("Goal" :in-theory (e/d (nbalist-stobj-nbalist$c)
                                          ((nbalist-stobj-nbalist$c)))))))

  (local (in-theory (enable nbalist-lookup$c
                            nbalist-stobj-nthkey$a
                            nbalist-stobj-nthkey$c
                            nbalist-stobj-nbalist$c)))

  (defabsstobj-events nbalist-stobj
    :concrete nbalist-stobj$c
    :corr-fn nbalist-stobj-corr
    :recognizer (nbalist-stobjp :logic nbalist-stobj$ap
                               :exec nbalist-stobj$cp)
    :creator (create-nbalist-stobj :logic create-nbalist-stobj$a
                                  :exec create-nbalist-stobj$c)
    :exports ((nbalist-stobj-lookup^ :logic nbalist-stobj-lookup$a
                                   :exec nbalist-lookup$c)
              (nbalist-stobj-len :logic nbalist-stobj-len$a
                                :exec nbalist-len$c)
              (nbalist-stobj-push^ :logic nbalist-stobj-push$a
                                  :exec nbalist-push$c
                                  :protect t)
              (nbalist-stobj-pop :logic nbalist-stobj-pop$a
                                :exec nbalist-pop$c
                                :protect t)
              (nbalist-stobj-nbalist :logic nbalist-stobj-nbalist$a
                                     :exec nbalist-stobj-nbalist$c)

              (nbalist-stobj-nthkey :logic nbalist-stobj-nthkey$a
                                     :exec nbalist-stobj-nthkey$c))))
  

(define nbalist-stobj-lookup ((id natp)
                              nbalist-stobj)
  :enabled t
  (mbe :logic (non-exec (nbalist-lookup id nbalist-stobj))
       :exec (if (<= id #xfffffff)
                 (nbalist-stobj-lookup^ id nbalist-stobj)
               (ec-call (nbalist-stobj-lookup^ id nbalist-stobj)))))

(define nbalist-stobj-push ((id natp)
                            (val bitp)
                            nbalist-stobj)
  :enabled t
  :guard (not (nbalist-stobj-lookup id nbalist-stobj))
  (mbe :logic (non-exec (nbalist-fix (cons (cons id val) nbalist-stobj)))
       :exec (if (<= id #xfffffff)
                 (nbalist-stobj-push^ id val nbalist-stobj)
               (ec-call (nbalist-stobj-push^ id val nbalist-stobj)))))

