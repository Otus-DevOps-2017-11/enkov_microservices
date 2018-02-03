FROM ruby:2.2

ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292
ENV APP_HOME /app

RUN mkdir $APP_HOME
RUN apt-get update -qq && apt-get install -y build-essential

# COPY Gemfile* $APP_HOME/
COPY . $APP_HOME

WORKDIR $APP_HOME

RUN bundle install

CMD ["puma"]
