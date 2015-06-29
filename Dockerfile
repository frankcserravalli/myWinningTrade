FROM ruby:2.0.0

MAINTAINER Eric D. Santos Sosa

# Add Node JS for JS RunTime
RUN curl -sL https://deb.nodesource.com/setup_0.12 | bash -

# Install Everything needed in Container
RUN apt-get update && \
    apt-get install -y \
    libpq-dev \
    postgresql-client-9.4 \
    postgresql-client-common \
    nodejs
    
# Setup the enviroment and working directory
ENV APP_HOME /myapp
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# Link the gemfiles to the container gemfiles
COPY Gemfile $APP_HOME/Gemfile
COPY Gemfile.lock $APP_HOME/Gemfile.lock

# Setup bundler
ENV BUNDLE_GEMFILE=$APP_HOME/Gemfile \
    BUNDLE_JOBS=4

# Run bundler to setup the rails app
RUN bundle install