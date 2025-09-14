#!/usr/bin/env node
const http = require('http');
const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

const PORT = 3000;
const OUTDIR = path.join(__dirname, 'result', 'examples', 'todo-app');
const WATCH_DIRS = [
  path.join(__dirname, 'src'),
  path.join(__dirname, 'examples', 'todo-app'),
  path.join(__dirname, 'flake.nix'),
];

let clients = [];

function serveFile(filePath, res) {
  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.writeHead(404);
      res.end('Not found');
    } else {
      if (filePath.endsWith('.css')) res.setHeader('Content-Type', 'text/css');
      else if (filePath.endsWith('.js')) res.setHeader('Content-Type', 'application/javascript');
      else if (filePath.endsWith('.html')) res.setHeader('Content-Type', 'text/html');
      res.end(data);
    }
  });
}

const server = http.createServer((req, res) => {
  let reqPath = req.url.split('?')[0];
  if (reqPath === '/') reqPath = '/index.html';
  const filePath = path.join(OUTDIR, reqPath);
  if (reqPath === '/__livereload') {
    clients.push(res);
    req.on('close', () => {
      clients = clients.filter(c => c !== res);
    });
    return;
  }
  serveFile(filePath, res);
});

server.listen(PORT, () => {
  console.log(`NixUI dev server running at http://localhost:${PORT}`);
});

function notifyClients() {
  clients.forEach(res => {
    res.write('data: reload\n\n');
    res.end();
  });
  clients = [];
}

function buildAndReload() {
  console.log('Rebuilding...');
  const build = spawn('nix', ['build', '.#nixui']);
  build.stdout.on('data', d => process.stdout.write(d));
  build.stderr.on('data', d => process.stderr.write(d));
  build.on('close', code => {
    if (code === 0) {
      console.log('Build succeeded. Reloading browser.');
      notifyClients();
    } else {
      console.log('Build failed.');
    }
  });
}

let debounceTimer = null;
function watchDirs() {
  WATCH_DIRS.forEach(dir => {
    if (fs.existsSync(dir)) {
      fs.watch(dir, { recursive: true }, (event, filename) => {
        if (debounceTimer) clearTimeout(debounceTimer);
        debounceTimer = setTimeout(buildAndReload, 300);
      });
    }
  });
}

watchDirs();

// Inject live reload script into index.html
const origServeFile = serveFile;
serveFile = function(filePath, res) {
  if (filePath.endsWith('index.html')) {
    fs.readFile(filePath, 'utf8', (err, data) => {
      if (err) {
        res.writeHead(404);
        res.end('Not found');
      } else {
        // Inject live reload script
        const injected = data.replace('</body>', `<script>
          const es = new EventSource('/__livereload');
          es.onmessage = () => location.reload();
        </script></body>`);
        res.setHeader('Content-Type', 'text/html');
        res.end(injected);
      }
    });
  } else {
    origServeFile(filePath, res);
  }
};

// Initial build
buildAndReload();
