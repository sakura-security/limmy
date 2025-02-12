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

;; launch bot
(defbot +limmy-bot+ +discord-token+)

;; bot configuration
(defun message-create (msg)
  (when (and (not (botp (lc:author msg))))
    (format t "[Content] ~A~%" (lc:content msg))
    (let ((cmd (string-trim " " (remove-mention (me) (lc:content msg)))))
      (cond ((string= cmd "ping!")
	     (format t "[Channel] ~A~%" (lc:channel-id msg))
	     (reply msg "pong!"))))))

(add-event-handler :on-message-create 'message-create)

;; playground
(defun count-cryptohack-solves (username)
  (length (cdr (assoc :solved--challenges (cl-json:decode-json (drakma:http-request (format nil "https://cryptohack.org/api/user/~A/" username) :want-stream t))))))

(defun print-cryptohack-progress ()
  (loop with tuturued-channels = (list)
	for config-block in (gethash "cryptohackTracker" +limmy-config+)
	for channel = (gethash "channel" config-block)
	for discord-username = (gethash "discord" config-block)
	for cryptohack-username = (gethash "cryptohack" config-block)
	unless (member channel tuturued-channels)
	  do (progn
	       (create "Too~ tooroo~"
		       (from-id channel :channel))
	       (create "https://tenor.com/view/tuturu-mayuri-tootooroo-steinsgate-gif-9868521318091589737"
		       (from-id channel :channel))
	       (create "Time for today's cryptohack progress update~ ^>^"
		       (from-id channel :channel))
	       (push channel tuturued-channels))
	do (if cryptohack-username
	       (create (format nil "<@~A> has solved ~D challenges!"
			       discord-username
			       (count-cryptohack-solves cryptohack-username))
		       (from-id channel :channel))
	       (create (format nil "<@~A> is hiding their cryptohack skills from the organization!"
			       discord-username)
		       (from-id channel :channel)))))

(scheduler:create-scheduler-task +scheduler+ (cons "0 10 * * *" (lambda () (print-cryptohack-progress))))

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
