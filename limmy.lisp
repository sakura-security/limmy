(in-package :limmy)

;; load discord token
(defparameter +discord-token+
  (uiop:getenv "DISCORD_TOKEN"))

;; load config file
(defparameter +limmy-config+
  (cl-yaml:parse #p"limmy.yaml"))

;; create scheduler
(defparameter +scheduler+
  (make-instance 'scheduler:in-memory-scheduler))

;; bot configuration
(defbot +limmy-bot+ +discord-token+)

(defun message-create (msg)
  (when (and (not (botp (lc:author msg))))
    (format t "[Content] ~A~%" (lc:content msg))
    (let ((cmd (string-trim " " (remove-mention (me) (lc:content msg)))))
      (cond ((string= cmd "ping!")
	     (format t "[Channel] ~A~%" (lc:channel-id msg))
	     (reply msg "pong!"))))))

(add-event-handler :on-message-create 'message-create)

;; serious code
(defun reconfigure ()
  (setf +limmy-config+ (cl-yaml:parse #p"limmy.yaml")))

(defun start ()
  (reconfigure)
  (connect +limmy-bot+)
  (bt:make-thread (lambda () (scheduler:start-scheduler +scheduler+))))

(defun stop ()
  (scheduler:stop-scheduler +scheduler+)
  (disconnect +limmy-bot+))

(defun unschedule-all ()
  (loop for schedule in (scheduler:list-scheduler-tasks +scheduler+)
	do (scheduler:delete-scheduler-task +scheduler+ schedule)))
