FROM python:3.6-slim

RUN apt update && apt install -y git gcc make curl

RUN python -m pip install --upgrade pip

ADD ./bot.requirements.txt /tmp

RUN pip install --upgrade pip && pip install -r /tmp/bot.requirements.txt
RUN python -c "import nltk; nltk.download('stopwords');"

ADD ./bot /bot
ADD ./scripts /scripts

WORKDIR /bot

ENV TRAINING_EPOCHS=20                    \
    ROCKETCHAT_URL=rocketchat:3000         \
    MAX_TYPING_TIME=10                     \
    MIN_TYPING_TIME=1                      \
    WORDS_PER_SECOND_TYPING=5              \
    ROCKETCHAT_ADMIN_USERNAME=admin        \
    ROCKETCHAT_ADMIN_PASSWORD=admin        \
    ROCKETCHAT_BOT_USERNAME=bot            \
    ROCKETCHAT_BOT_PASSWORD=bot            \
    ENVIRONMENT_NAME=localhost             \
    BOT_VERSION=last-commit-hash           \
    ENABLE_ANALYTICS=False                 \
    ELASTICSEARCH_URL=elasticsearch:9200

RUN apt-get -yq autoremove && \
    apt-get clean && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD python /scripts/bot_config.py -r $ROCKETCHAT_URL                        \
           -an $ROCKETCHAT_ADMIN_USERNAME -ap $ROCKETCHAT_ADMIN_PASSWORD    \
           -bu $ROCKETCHAT_BOT_USERNAME -bp $ROCKETCHAT_BOT_PASSWORD     && \
    make train && make run-rocketchat
