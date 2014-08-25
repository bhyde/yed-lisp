(defsystem yed-lisp
  :depends-on ("asdf" ;; for asdf:system-relative-pathname 
               "xmls" ;; to load the graphml files
               "fare-quasiquote-optima" "optima.ppcre" ;; to tidy up the xmls
               "parse-number")
  :components ((:file "packages")
               (:file "main")))
