#!/usr/local/bin/cl -s yed-lisp -E main -X --
; -*- mode:common-lisp -*-

(in-package #:cl-user)

(defun main (argv)
  (handler-case
      (flet
          ((read-and-report (graph-namestring)
             (multiple-value-bind (nodes edges)
                 (yed-lisp:extract-topology 
                  (yed-lisp:load-graph graph-namestring))
               (flet ((node-name (node) (second (assoc node nodes))))
                 (loop for (nil from to) in edges
                    do (format t "~&~A -> ~A"
                               (node-name from) (node-name to))))))
           (get-graph-namestring ()
             (optima:match argv
               ((or (list "-h")
                    (list "--help"))
                (format t "Usage: <prog> <graphML file>")
                (uiop:quit))
               ((list (optima:guard graph-namestring (stringp graph-namestring)))
                (unless (probe-file graph-namestring)
                  (format *error-output* "File not found: ~A" graph-namestring)
                  (uiop:quit -1))
                graph-namestring)
               (_
                (format *error-output* "~&ERROR: malform args, try --help")
                (uiop:quit -1)))))
        (read-and-report (get-graph-namestring)))
    (error (e) 
      (format *error-output* "~&ERROR: ~A" e)
      (uiop:quit -1))))
