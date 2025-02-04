#!/bin/bash

# 1. Изменить PermitRootLogin на yes в sshd_config
sudo sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# 2. Изменить PasswordAuthentication на yes в конфигурационных файлах
sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config.d/*.conf

# 3. Копировать authorized_keys в директорию root
sudo cp /home/ubuntu/.ssh/authorized_keys /root/.ssh/authorized_keys

# 4. Перезапустить SSH-сервер
sudo systemctl restart ssh

# 5. Очистить всю историю
cat /dev/null > ~/.bash_history && history -c

# 6. Удалить сам скрипт
rm -- "$0"
