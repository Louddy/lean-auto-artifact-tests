FROM ubuntu:22.04

ENV TZ=America/Los_Angeles
SHELL ["/bin/bash", "-c"]

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update
RUN apt-get install -y python3 python3-pip wget
RUN yes | apt-get install unzip build-essential make cmake git \
  && yes | apt-get install bubblewrap libgmp3-dev pkg-config \
  && yes | apt-get install expect curl vim

WORKDIR /home

# Install z3
RUN wget https://github.com/Z3Prover/z3/releases/download/z3-4.13.4/z3-4.13.4-x64-glibc-2.35.zip \
  && unzip -q z3-4.13.4-x64-glibc-2.35.zip -d . \
  && rm z3-4.13.4-x64-glibc-2.35.zip \
  && cp /home/z3-4.13.4-x64-glibc-2.35/bin/z3 /usr/bin/z3

# Install cvc5
RUN wget https://github.com/cvc5/cvc5/releases/download/cvc5-1.2.0/cvc5-Linux-x86_64-static.zip \
  && unzip -q cvc5-Linux-x86_64-static.zip -d . \
  && rm cvc5-Linux-x86_64-static.zip \
  && cp /home/cvc5-Linux-x86_64-static/bin/cvc5 /usr/bin/cvc5

# Install zipperposition
COPY install_zipperpn_scripts /home/install_zipperpn_scripts
RUN bash /home/install_zipperpn_scripts/install_zipperpn.sh

# Install Lean and Lean libraries
RUN wget https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh \
  && bash elan-init.sh -y \
  && rm elan-init.sh \
  && git clone https://github.com/leanprover-community/lean-auto \
  && cd lean-auto && git checkout d7d55ccc6148d2c581beb42f9f7125a8a4a5e720 && cd .. \
  && git clone https://github.com/leanprover-community/duper \
  && cd duper && git checkout 9cd4d4d1d71034d456d06aef2e4d07c911b88c65 && cd ..

# Build lean_hammertest_lw (most part of it would be building Mathlib)
COPY lean_hammertest_lw /home/lean_hammertest_lw
RUN source /root/.elan/env && cd /home/lean_hammertest_lw && lake build

# Copy Test Scripts
COPY test_scripts /home/test_scripts

# Install Python Modules in a new virtual environment `result-analysis-env`
# Use `source /home/result-analysis-env/bin/activate` to activate the environment
RUN yes | apt install python3-venv
RUN python3 -m venv result-analysis-env \
  && source result-analysis-env/bin/activate \
  && pip install pandas numpy matplotlib

# Copy Result Analysis Scripts
COPY result_analysis /home/result_analysis