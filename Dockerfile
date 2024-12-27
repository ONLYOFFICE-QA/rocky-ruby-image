FROM rockylinux:9.3
LABEL org.opencontainers.image.authors=askonev007@gmail.com

ENV HOME "/root"

# https://www.ruby-lang.org/en/news/2024/12/25/ruby-3-4-1-released/
ENV RUBY_VERSION 3.4.1
ENV RUBY_DOWNLOAD_URL https://cache.ruby-lang.org/pub/ruby/3.4/ruby-3.4.1.tar.gz
ENV RUBY_DOWNLOAD_SHA256 3d385e5d22d368b064c817a13ed8e3cc3f71a7705d7ed1bae78013c33aa7c87f

RUN dnf install -y dnf-plugins-core \
                   epel-release && \
    dnf config-manager --set-enabled crb && \
    dnf -y install file-devel \
                   file \
                   gcc \
                   gcc-c++ \
                   make \
                   git \
                   ImageMagick \
                   ImageMagick-devel \
                   poppler-utils \
                   openssl-devel \
                   zlib-devel \
                   libffi-devel \
                   readline-devel \
                   sqlite-devel \
                   libyaml-devel \
                   xz

RUN curl -fsSLO $RUBY_DOWNLOAD_URL && \
    echo "$RUBY_DOWNLOAD_SHA256 ruby-$RUBY_VERSION.tar.gz" | sha256sum --check --strict && \
    tar -xzf "ruby-$RUBY_VERSION.tar.gz"

# https://github.com/ruby/ruby/blob/master/doc/contributing/building_ruby.md
RUN cd "ruby-$RUBY_VERSION" && \
    mkdir  "${HOME}/.rubies" && \
    ./configure --prefix="${HOME}/.rubies/ruby-master" && \
    make && \
    make test OPTS=-v && \
    make install

ENV PATH "${HOME}/.rubies/ruby-master/bin":"$PATH"

# don't create ".bundle" in all our apps
ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_SILENCE_ROOT_WARNING=1 \
	BUNDLE_APP_CONFIG="$GEM_HOME"
ENV PATH $GEM_HOME/bin:$PATH

# adjust permissions of a few directories for running "gem install" as an arbitrary user
RUN mkdir -p "$GEM_HOME" && chmod 1777 "$GEM_HOME"

CMD echo $(ruby -v)
