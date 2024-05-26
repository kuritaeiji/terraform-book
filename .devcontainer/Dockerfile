FROM golang:1.22.3-bullseye

WORKDIR /go/terraform

ARG USER_ID=1000
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY

# DockerユーザーをホストマシンのユーザーIDと同じにする
RUN useradd -m --disabled-password -u ${USER_ID} ubuntu
USER ubuntu

# AWSのアクセスキーとシークレットアクセスキーを環境変数として設定する
ENV AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
ENV AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}

# gopls: 言語サーバー  dlv: デバッガー  goimports: フォーマッター  glangci-lint: リンター
RUN apt update && \
    go install golang.org/x/tools/gopls@latest && \
    go install github.com/go-delve/delve/cmd/dlv@latest && \
    go install golang.org/x/tools/cmd/goimports@latest && \
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.55.2

# tfenvをインストールする
RUN git clone --depth=1 https://github.com/tfutils/tfenv.git ~/.tfenv
ENV PATH=${HOME}/.tfenv/bin:${PATH}

