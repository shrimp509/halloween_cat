FROM ruby:3.0.0-alpine3.13
LABEL maintainer="sam.ho@relacs-studio.com"

RUN apk update && apk add git make gcc g++ libc-dev pkgconfig build-base \
    libxml2-dev libxslt-dev postgresql-dev coreutils curl wget bash \
    gnupg tar linux-headers bison readline-dev readline zlib-dev \
    zlib yaml-dev autoconf ncurses-dev curl-dev apache2-dev \
    libx11-dev libffi-dev tcl-dev tk-dev vim gcompat imagemagick ffmpeg nodejs yarn

# Set an environment variable to store where the app is installed to inside
# of the Docker image.
ARG RAILS_ENV=development
ARG RAILS_MASTER_KEY=key
ENV RAILS_ENV $RAILS_ENV
ENV DATABASE_HOST postgres
ENV REDIS_HOST redis
ENV RAILS_MASTER_KEY $RAILS_MASTER_KEY

# Set current workdir
WORKDIR /halloween-cat

# Install gems
ADD Gemfile* /halloween-cat/
RUN bundle install -j4 --retry 3

# Add the Rails app
ADD . .

# Precompile assets
RUN bundle exec rake assets:precompile

# Expose Puma port
EXPOSE 3000

# Start up
ENTRYPOINT ["bundle", "exec"]
CMD ["puma", "-C", "config/puma.rb"]
