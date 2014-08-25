#!/usr/local/bin/cl -l ccl -S ~/w/selected-asd -s yed-lisp -E main --
# -*- mode: common-lisp -*-
(in-package #:cl-user)
(defun main (argv)
  (multiple-value-bind (nodes edges)
      (yed-lisp:extract-topology (yed-lisp:load-graph (pop argv)))
    (flet ((node-name (node) (second (assoc node nodes))))
      (loop for (nil from to) in edges
         do (format t "~&~A -> ~A"
                    (node-name from) (node-name to))))))

