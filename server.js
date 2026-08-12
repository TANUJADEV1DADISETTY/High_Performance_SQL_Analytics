const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = process.env.PORT || 3000;
const PUBLIC_DIR = path.join(__dirname, 'public');

const MIME_TYPES = {
    '.html': 'text/html',
    '.css': 'text/css',
    '.js': 'text/javascript',
    '.json': 'application/json',
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.svg': 'image/svg+xml'
};

const server = http.createServer((req, res) => {
    // API routes
    if (req.url === '/api/benchmarks') {
        const benchmarksPath = path.join(__dirname, 'results', 'benchmarks.json');
        if (fs.existsSync(benchmarksPath)) {
            res.writeHead(200, { 'Content-Type': 'application/json' });
            return res.end(fs.readFileSync(benchmarksPath, 'utf8'));
        } else {
            res.writeHead(404, { 'Content-Type': 'application/json' });
            return res.end(JSON.stringify({ error: 'Benchmarks not found' }));
        }
    }

    if (req.url.startsWith('/api/queries')) {
        const queriesDir = path.join(__dirname, 'queries');
        const files = fs.readdirSync(queriesDir);
        const queryData = {};
        files.forEach(file => {
            if (file.endsWith('.sql')) {
                queryData[file] = fs.readFileSync(path.join(queriesDir, file), 'utf8');
            }
        });
        res.writeHead(200, { 'Content-Type': 'application/json' });
        return res.end(JSON.stringify(queryData));
    }

    // Static file serving
    let filePath = path.join(PUBLIC_DIR, req.url === '/' ? 'index.html' : req.url);
    const ext = path.extname(filePath).toLowerCase();

    fs.readFile(filePath, (err, content) => {
        if (err) {
            if (err.code === 'ENOENT') {
                res.writeHead(404, { 'Content-Type': 'text/html' });
                res.end('<h1>404 Not Found</h1>');
            } else {
                res.writeHead(500);
                res.end(`Server Error: ${err.code}`);
            }
        } else {
            res.writeHead(200, { 'Content-Type': MIME_TYPES[ext] || 'text/plain' });
            res.end(content, 'utf-8');
        }
    });
});

server.listen(PORT, () => {
    console.log(`Analytics Dashboard Server running at http://localhost:${PORT}`);
});
