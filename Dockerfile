FROM ubuntu:22.04

ENV TZ=America/Los_Angeles

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       python3 python3-pip wget unzip build-essential \
       make cmake git bubblewrap libgmp3-dev pkg-config expect curl vim \
       python3-venv opam \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /home

# Install Python Modules in a new virtual environment `result-analysis-env`
# Use `source /home/result-analysis-env/bin/activate` to activate the environment
RUN python3 -m venv result-analysis-env \
  && . result-analysis-env/bin/activate \
  && pip install pandas numpy matplotlib

# Install z3
RUN wget -q https://github.com/Z3Prover/z3/releases/download/z3-4.13.4/z3-4.13.4-arm64-glibc-2.34.zip \
  && unzip -q z3-4.13.4-arm64-glibc-2.34.zip -d . \
  && rm z3-4.13.4-arm64-glibc-2.34.zip \
  && cp /home/z3-4.13.4-arm64-glibc-2.34/bin/z3 /usr/bin/z3

# Install cvc5
RUN wget -q https://github.com/cvc5/cvc5/releases/download/cvc5-1.2.0/cvc5-Linux-arm64-static.zip \
  && unzip -q cvc5-Linux-arm64-static.zip -d . \
  && rm cvc5-Linux-arm64-static.zip \
  && cp /home/cvc5-Linux-arm64-static/bin/cvc5 /usr/bin/cvc5

# Install zipperposition
RUN opam init --compiler 4.14.0 --disable-sandboxing --no-setup \
  && opam install -y zipperposition \
  && opam pin -y -k git "https://github.com/sneeuwballen/zipperposition.git#050072e01d8539f9126993482b595e09f921f66a" \
  && opam clean --all-switches --download-cache --logs --repo-cache

# Install Elan
RUN wget -q https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh \
  && bash elan-init.sh -y --default-toolchain=none \
  && rm elan-init.sh

# Build lean_hammertest_lw dependencies
WORKDIR /home/lean_hammertest_lw
COPY lean_hammertest_lw/lakefile.lean \
  lean_hammertest_lw/lean-toolchain \
  lean_hammertest_lw/lake-manifest.json \
  ./
RUN . /root/.elan/env \
  && lake resolve-deps && (lake exe cache get || true) \
  && lake build Mathlib Auto Duper

# Build lean_hammertest_lw
COPY lean_hammertest_lw/ ./
RUN . /root/.elan/env && lake build

# Copy Test Scripts
WORKDIR /home
COPY test_scripts test_scripts

# Copy Result Analysis Scripts
COPY result_analysis result_analysis

# Add execution privilege
RUN chmod +x test_scripts/*
