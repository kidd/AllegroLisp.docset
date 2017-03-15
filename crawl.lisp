(let ((quicklisp-init (merge-pathnames "quicklisp/setup.lisp"
                                       (user-homedir-pathname))))
  (when (probe-file quicklisp-init)
    (load quicklisp-init)))

(defun file-string (path)
  (with-open-file (stream path)
    (let ((data (make-string (file-length stream))))
      (read-sequence data stream)
      data)))

(ql:quickload :clss)
(ql:quickload :cl-ppcre)
(ql:quickload :plump)

(defun process-file (letter)
  (let* ((fpath (format nil "/home/rgrau/programmingStuff/allegroweb/franz.com/support/documentation/10.0/doc/nocg-index-~a.htm" letter))
         (page (file-string fpath))
         (links (clss:select "li > a" (plump:parse page))))
    (map 'list (lambda (x) `(:text ,(plump:text x)
                     :link ,(plump:attribute x "href")))
            links)))

(defun sanitize (str)
  (replace-re
   (replace-re
    (replace-re str "'" "\\\'")
    "\\n"
    "")
   "\""
   "\\\""))

(defun add-package (item)
  (multiple-value-bind (full matches)
      (cl-ppcre::scan-to-strings "operators/(.+?)/"
                                 (getf item :link))
    (when full
        (setf (getf item :text)
              (format nil "~a:~a" (aref matches 0) (getf item :text))))))

(defun text-with-package (item)
  (multiple-value-bind (full matches)
      (cl-ppcre::scan-to-strings "operators/(.+?)/"
                                 (getf item :link))
    (if full
        (format nil "~a:~a" (aref matches 0) (getf item :text))
        (getf item :text))))

(let ((insert-statment "sqlite3 docSet.dsidx \"insert into searchIndex(name,type,path) VALUES ('~a','~a','~a')\"~%")
      (*print-right-margin* 190)
      (excl::*default-right-margin* 190)
      (everything (append
                   (loop for letter in (coerce "abcdefghijklmnopqrstuvw" 'list)
                         append (process-file letter))
                   (process-file "xyz")
                   (process-file "other"))))
  (with-open-file (f "./functions.sh"
                     :direction :output
                     :if-exists :supersede
                     :if-does-not-exist :create)
    (format f
            "sqlite3 docSet.dsidx  'create table searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT);  CREATE UNIQUE INDEX anchr  ON searchIndex (name, type, path);'~%")
    (mapc (lambda (x)
            (when (not (excl:match-re "^\\\.\\\." (getf x :link)))
              (format f insert-statment
                      (sanitize (text-with-package x))
                      "Function"
                      (sanitize (getf x :link)))))
          everything)))

;; (setf elems (clss:select "li > a" (plump:parse p)))
;; (plump:attribute e "href")
;; (plump:text e)
