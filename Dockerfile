FROM amazon/aws-cli

# Install jq (required for parsing commands input)
RUN apk add --no-cache jq

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["sh", "/entrypoint.sh"]