#!/usr/bin/env bash
# Serve the static horror-game build in the foreground on PORT (default 3000).
# Build output (dist/) stays inside PROJECT_DIR; only worker metadata goes to OPENCODE_WEB_DIR.
set -euo pipefail
cd "$(dirname "$0")"
/usr/bin/time -p bash -c 'PROJECT_ROOT="$(pwd)"; test -f "$PROJECT_ROOT/jogo-terror-3d.html"'
PROJECT_ROOT="$(pwd)"
DIST_DIR="$PROJECT_ROOT/dist"
PORT="${PORT:-3000}"
WEB_DIR="${OPENCODE_WEB_DIR:-/home/runner/work/_temp/omgithub-web}"
/usr/bin/time -p mkdir -p "$DIST_DIR"
/usr/bin/time -p cp -f "$PROJECT_ROOT/jogo-terror-3d.html" "$DIST_DIR/index.html"
/usr/bin/time -p test -f "$DIST_DIR/index.html"
if [[ -f "$PROJECT_ROOT/package.json" ]]; then
  /usr/bin/time -p npm install --no-audit --no-fund
  /usr/bin/time -p npm run build
fi
/usr/bin/time -p node -e 'const fs=require("fs");const path=require("path");const project=process.cwd();const dir=path.join(project,"dist");const web=process.env.OPENCODE_WEB_DIR||"/home/runner/work/_temp/omgithub-web";fs.mkdirSync(web,{recursive:true});fs.writeFileSync(path.join(web,"deployment-output.json"),JSON.stringify({project:project,directory:dir}));console.log("deployment-output: "+path.join(web,"deployment-output.json")+" -> "+dir);'
/usr/bin/time -p node -e 'const http=require("http"),fs=require("fs"),path=require("path");const root=path.join(process.cwd(),"dist");const port=Number(process.env.PORT||3000);const mime={".html":"text/html",".js":"application/javascript",".css":"text/css",".json":"application/json",".png":"image/png",".jpg":"image/jpeg",".svg":"image/svg+xml",".ico":"image/x-icon",".wasm":"application/wasm"};const server=http.createServer((req,res)=>{try{const u=new URL(req.url,"http://localhost");let p=path.normalize(path.join(root,decodeURIComponent(u.pathname)));if(p!==root&&!p.startsWith(root+path.sep)){res.writeHead(404);res.end("Not found");return;}try{if(fs.statSync(p).isDirectory()){p=path.join(p,"index.html");}}catch(e){res.writeHead(404);res.end("Not found");return;}fs.readFile(p,(e,d)=>{if(e){res.writeHead(404);res.end("Not found");return;}res.writeHead(200,{"Content-Type":mime[path.extname(p)]||"application/octet-stream","Cache-Control":"no-cache"});res.end(d);});}catch(e){res.writeHead(500);res.end("error");}});server.listen(port,"0.0.0.0",()=>console.log("serving "+root+" on port "+port));'
