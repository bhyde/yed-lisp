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
                 (loop 
                    for (nil from to) in edges
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
                  (uiop:die -1 "File not found: ~A" graph-namestring))
                graph-namestring)
               (_
                (uiop:die -1 "~&ERROR: malform args, try --help")))))
        (read-and-report (get-graph-namestring)))
    (error (e) 
      (uiop:die -1 "~&ERROR: ~A" e))))
