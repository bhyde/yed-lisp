(in-package #:yed-lisp)

(defun build-keyword (text)
  (intern (string-upcase text) :keyword))

(defun file-of-mine (name)
  (asdf:system-relative-pathname (asdf:find-system "yed-lisp") name))

(defun load-graph (&optional (pathname-to-graph (file-of-mine "abc.graphml")))
  (labels ((tidy-props (properties)
             (loop
                for (key . value) in properties
                as keyword = (build-keyword key)
                collect
                  (cons keyword
                        (case keyword
                          ((:type :autosizepolicy :alignment :for
                                  :fontstyle)
                           (build-keyword (first value)))
                          (otherwise
                           (ematch value
                             (`("false") nil)
                             (`("true") t)
                             (`(,(ppcre "(\\d+.\\d+)" x)) (parse-number x))
                             (`(,(ppcre "(\\d+)" x)) (parse-integer x))
                             (x x)))))))
           (tidy-xml (xml)
             (ematch xml
               (`((,node . ,_) ,props ,@kids)
                 `(,(build-keyword node) ,(tidy-props props)
                    ,@(mapcar #'tidy-xml kids)))
               ((guard str (stringp str))
                str)
               )))
    (tidy-xml
     (with-open-file (s pathname-to-graph)
       (xmls:parse s)))))

(defun extract-topology (graph)
  (let (nodes edges)
    (labels ((recure (graph)
               (match graph
                 (`(:edge ,(alist (:source . src) (:target . target) (:id . id)) ,@_)
                   (push `(,id ,src ,target) edges))
                 (`(:node ,(alist (:id . id)) ,@kids)
                   (push `(,id ,(get-node-label kids)) nodes))
                 (`(,_ ,_ ,@kids)
                   (map nil #'recure kids))))
             (get-node-label (kids)
               (let ((label ()))
                 (labels ((recure (kid)
                            (ematch kid
                              ((type string)    (push kid label))
                              (`(,_ ,_ ,@kids)  (map nil #'recure kids)))))
                   (map nil #'recure kids))
                 (format nil "~{~A~^ ~}" label))))
      (recure graph))
    (values (nreverse nodes) (nreverse edges))))

