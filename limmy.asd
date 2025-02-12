(defsystem "limmy"
  :version "0.1.0"
  :author "calx"
  :licence "MIT"
  :description "a cute bot"

  :components ((:file "package")
	       (:file "limmy"))

  :build-pathname "limmy"
  :entry-point "limmy::start"

  :depends-on (:cl-dotenv :cl-yaml :lispcord :scheduler :drakma :cl-json))
