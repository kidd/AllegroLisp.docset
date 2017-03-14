(defun file-string (path)
  (with-open-file (stream path)
    (let ((data (make-string (file-length stream))))
      (read-sequence data stream)
      data)))

(ql:quickload :clss)
(ql:quickload :cl-ppcre)
(ql:quickload :plump)
(setf p (file-string "/home/rgrau/programmingStuff/allegroweb/franz.com/support/documentation/10.0/doc/nocg-index-a.htm"))

(defun process-file (letter)
  (let* ((fpath (format nil "/home/rgrau/programmingStuff/allegroweb/franz.com/support/documentation/10.0/doc/nocg-index-~a.htm" letter))
         (page (file-string fpath))
         (links (clss:select "li > a" (plump:parse page))))
    (map 'list (lambda (x) `(:text ,(plump:text x)
                     :link ,(plump:attribute x "href")))
            links)))


(setf *everythingg* nil)

(setf *everythingg*
      (append
       (loop for letter in (coerce "abcdefghijklmnopqrstuvw" 'list)
             append (process-file letter))
       (process-file "xyz")
       (process-file "other")
       ))

(defun sanitize (str)
  (replace-re
   (replace-re str "'" "\\\'")
   "\\n"
   ""
   ))


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

(setq excl::*default-right-margin* 190)

(let ((insert-statment "sqlite3 docSet.dsidx \"insert into searchIndex(name,type,path) VALUES ('~a','~a','~a')\"~%")
      (*print-right-margin* 190)
      (excl:: *default-right-margin* 190))
 (with-open-file (f "/tmp/functions.sh"
                    :direction :output
                    :if-exists :overwrite
                    :if-does-not-exist :create)
    (format f
            "sqlite3 docSet.dsidx  'create table searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT);  CREATE UNIQUE INDEX anchr  ON searchIndex (name, type, path);'~%")
   (mapc (lambda (x)
           (when (not (excl:match-re "^\\\.\\\." (getf x :link)))
             (format f insert-statment
                     (sanitize (text-with-package x))
                     "Function"
                     (sanitize (getf x :link)))))
         *everythingg*)))

;; (setf elems (clss:select "li > a" (plump:parse p)))
;; (plump:attribute e "href")
;; (plump:text e)
