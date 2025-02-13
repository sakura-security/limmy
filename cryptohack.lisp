(in-package :limmy)

(defun get-cryptohack-solves (cryptohack-username)
  (cl-json:decode-json
   (drakma:http-request (format nil "https://cryptohack.org/api/user/~A/" cryptohack-username)
			:want-stream t)))

(defun count-cryptohack-solves (cryptohack-username)
  (length
   (cdr (assoc :solved--challenges
	       (get-cryptohack-solves cryptohack-username)))))

(defun yesterday? (date)
  (string= date
	   (local-time:format-timestring nil
					 (local-time:timestamp- (local-time:today) 1 :day)
					 :format '(:day " " :short-month " " :year))))

(defun count-yesterday-cryptohack-solves (cryptohack-username)
  (loop for solve in (cdr (assoc :solved--challenges
				 (get-cryptohack-solves cryptohack-username)))
	for solve-date = (cdr (assoc :date solve))
	count (yesterday? solve-date)))

(defun too-tooroo-channel (to-ping channel-id)
  (create "Too~ tooroo~"
	  channel-id)
  (create "https://tenor.com/view/tuturu-mayuri-tootooroo-steinsgate-gif-9868521318091589737"
	  channel-id)
  (create (format nil "<@~A> Cryptohack news!" to-ping)
	  channel-id))

(defun praise-user (discord-userid channel-id solves)
  (create (format nil "<@~A> solved ~D challenges yesterday!"
		  discord-userid
		  solves)
	  channel-id))

(defun show-cryptohack-progress ()
  (loop with too-tooroo-ed	= nil
	with config-block	= (gethash "cryptohackTracker" +limmy-config+)
	with channel		= (gethash "channel" config-block)
	with channel-id		= (from-id channel :channel)
	with to-ping		= (gethash "toPing" config-block)

	for user-config		in (gethash "users" config-block)
	for discord-userid	= (gethash "discord" user-config)
	for cryptohack-username = (gethash "cryptohack" user-config)

	for solve-count		= (if cryptohack-username
				      (count-yesterday-cryptohack-solves cryptohack-username) 0)

	when (not (zerop solve-count))
	  do (progn
	       (unless too-tooroo-ed
		 (too-tooroo-channel to-ping channel-id)
		 (setf too-tooroo-ed t))
	       (praise-user discord-userid channel-id solve-count))))

(scheduler:create-scheduler-task +scheduler+ (cons "30 03 * * *" (lambda () (show-cryptohack-progress))))
