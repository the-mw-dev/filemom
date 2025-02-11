#!/bin/bash

# Проверяем, что скрипт выполняется с правами root
if [ "$EUID" -ne 0 ]; then
  echo "Пожалуйста, запустите этот скрипт с правами root: sudo $0"
  exit 1
fi

# Установка зависимостей
echo "Устанавливаем необходимые пакеты..."
apt update && apt install -y curl tar wget screen

# Переменные
XMRIG_VERSION="6.22.2"
ARCH=$(uname -m)
if [ "$ARCH" == "x86_64" ]; then
  ARCH="x64"
elif [ "$ARCH" == "aarch64" ]; then
  ARCH="arm64"
else
  echo "Ошибка: архитектура $ARCH не поддерживается."
  exit 1
fi

ROOT_DIR="$HOME/xmrig"
XMRIG_URL="https://github.com/xmrig/xmrig/releases/download/v${XMRIG_VERSION}/xmrig-${XMRIG_VERSION}-linux-static-${ARCH}.tar.gz"

# Создание рабочей директории
echo "Создаем рабочую директорию: $ROOT_DIR"
mkdir -p $ROOT_DIR && cd $ROOT_DIR

# Загрузка XMRig
echo "Загружаем XMRig..."
curl -Lo xmrig.tar.gz $XMRIG_URL

# Проверка загруженного файла
if file xmrig.tar.gz | grep -q "gzip compressed data"; then
  echo "Файл загружен успешно."
else
  echo "Ошибка: файл не является архивом gzip. Проверьте URL и попробуйте снова."
  exit 1
fi

# Распаковка архива
echo "Распаковываем XMRig..."
tar -xzf xmrig.tar.gz --strip-components=1 && rm xmrig.tar.gz

# Проверка наличия исполняемого файла
if [ ! -f "./xmrig" ]; then
  echo "Ошибка: исполняемый файл xmrig не найден после распаковки."
  exit 1
fi

# Запуск XMRig в screen
echo "Запускаем XMRig в фоновом режиме с помощью screen..."
screen -dmS xmrig ./xmrig -o sal.kryptex.network:7777 \
  -u krxYMKE2RD.worker -k --coin monero -a rx/0

# Уведомление пользователя
echo "XMRig запущен в фоновом режиме."
echo "Вы можете подключиться к screen-сессии с помощью команды: screen -r xmrig"
