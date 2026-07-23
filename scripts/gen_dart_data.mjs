// JS 네트워크 데이터(src/data)를 Flutter 앱용 Dart 소스로 변환한다.
// 데이터 갱신(build_network.py 재실행) 후 이 스크립트를 다시 돌리면 된다.
//   node scripts/gen_dart_data.mjs
import { stations } from '../src/data/stations.js';
import { connections } from '../src/data/connections.js';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const root = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const outDir = path.join(root, 'app', 'lib', 'data');

const q = (s) => "'" + String(s).replaceAll('\\', '\\\\').replaceAll("'", "\\'") + "'";

// stations.dart
let s = '';
s += '// 자동 생성 (scripts/gen_dart_data.mjs — 원본 src/data/stations.js).\n';
s += '// 손으로 수정하지 말 것. doorWidthCm=null(실측 전)은 라우팅 게이팅에 쓰지 않는다.\n';
s += "import '../models/station.dart';\n\n";
s += 'const List<Station> kStations = [\n';
for (const st of stations) {
  const lines = '[' + st.lines.map(q).join(', ') + ']';
  const dw = st.doorWidthCm == null ? 'null' : st.doorWidthCm;
  const dws = st.doorWidthStatus == null ? 'null' : q(st.doorWidthStatus);
  s += `  Station(id: ${q(st.id)}, name: ${q(st.name)}, lines: ${lines}, elevator: ${st.elevator}, escalator: ${st.escalator}, capacityKg: ${st.capacityKg}, doorWidthCm: ${dw}, doorWidthStatus: ${dws}, note: ${q(st.note)}),\n`;
}
s += '];\n';
fs.writeFileSync(path.join(outDir, 'stations.dart'), s);

// connections.dart — records (from, to, line, minutes)
let c = '';
c += '// 자동 생성 (scripts/gen_dart_data.mjs — 원본 src/data/connections.js).\n';
c += '// 손으로 수정하지 말 것. 역간 소요(분)은 평균 역간 운행시간(약 2분) 기준 추정치.\n\n';
c += '// (from, to, line, minutes)\n';
c += 'const List<(String, String, String, int)> kConnections = [\n';
for (const [a, b, line, min] of connections) {
  c += `  (${q(a)}, ${q(b)}, ${q(line)}, ${min}),\n`;
}
c += '];\n';
fs.writeFileSync(path.join(outDir, 'connections.dart'), c);

console.log('generated stations:', stations.length, 'connections:', connections.length);
