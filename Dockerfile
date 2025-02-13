FROM ubuntu:latest

RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install sbcl cl-quicklisp libyaml-0-2 ca-certificates -y

# ARG QUICKLISP_DIST_URL=http://dist.shirakumo.org/shirakumo.txt

RUN useradd -ms /bin/bash limmy

WORKDIR /home/limmy

USER limmy

RUN sbcl --non-interactive \
    --load /usr/share/common-lisp/source/quicklisp/quicklisp.lisp \
    --eval "(quicklisp-quickstart:install)" \
    --eval "(ql-util:without-prompting (ql:add-to-init-file))" \
    --eval "(ql-util:without-prompting (ql-dist:install-dist \"http://dist.shirakumo.org/shirakumo.txt\"))"

RUN sbcl --non-interactive \
    --eval "(ql:quickload '(:cl-dotenv :cl-yaml :lispcord :scheduler :drakma :cl-json :local-time))"

ENTRYPOINT ["sbcl", "--noinform", "--disable-debugger"]

CMD ["--eval", "(ql:quickload :limmy)", "--eval", "(limmy::start)"]

RUN touch limmy.yaml

COPY limmy.asd *.lisp .

RUN mkdir -p /home/limmy/common-lisp && ln -sf /home/limmy/limmy.asd /home/limmy/common-lisp/limmy.asd

