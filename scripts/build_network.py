"""
WheelWay 수도권 네트워크 데이터 생성 스크립트 (실 공공데이터 기반)

데이터 출처(실시간 Firebase Functions 프록시를 통해 조회):
  - /api/facilities?type=elevator  (서울교통공사 편의시설 위치정보 - 엘리베이터)
  - /api/facilities?type=escalator (서울교통공사 편의시설 위치정보 - 에스컬레이터)

방법론 (반드시 아래 규칙을 유지할 것 — 데이터 조작 없이 재현 가능해야 함):
  - 역 이름(stnNm)을 물리적 역의 고유 id로 사용 (여러 노선이 같은 이름으로 겹치면
    자동으로 환승역으로 병합됨 — 예: 교대는 2호선/3호선 데이터에 모두 등장)
  - 각 노선 내 순서는 실제 역번호(stnNo, 예: '211', '211-1')를 정렬해 사용.
    지선(211-1, 211-2 ...)은 본선 역(211)에서 갈라져 나가는 체인으로 연결하고,
    본선 시퀀스로 다시 합류시키지 않음 (실제 위상 오류 방지 — 예: 2호선 성수지선).
  - 2호선은 실제로 순환선이므로 마지막 역(충정로)과 첫 역(시청)을 닫는 간선을 추가.
  - 역간 소요시간(분)은 실측 시간표 데이터가 없어 "평균 역간 운행시간 약 2분"을
    기준으로 추정한 값이며, 역번호 차이(gap)가 1보다 크면(중간에 편의시설 데이터가
    없는 역이 있어 그래프에 빠진 경우) 그만큼 비례해서 늘림. 실제 시간표와 다를 수 있음.
  - capacityKg(엘리베이터 정격하중)는 실측값(pscpWht)의 최댓값 사용 — 실 데이터.
  - doorWidthCm(엘리베이터 문 폭)은 이 공공데이터에 필드 자체가 없어 실측 불가.
    "장애인·노인·임산부 등의 편의증진보장에 관한 법률 시행규칙"상 장애인용 승강설비의
    법정 최소 유효 폭 기준(90cm)을 적용한 추정치이며, doorWidthEstimated:true로 표시함.
    UI에서도 "법정기준 추정치"임을 노출해야 함 — 실측값처럼 보이게 하면 안 됨.
  - 엘리베이터/에스컬레이터 데이터 모두 없는 역(예: 최근 개통 노선 일부, 9호선/공항철도/
    분당선 등 타 운영사 노선)은 이번 생성 대상에서 제외됨 — 별도 데이터 확보 필요.
"""
import json
import re
from collections import defaultdict

import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

with open(os.path.join(ROOT, 'elev.json'), encoding='utf-8') as f:
    elev_rows = json.load(f)['rows']
with open(os.path.join(ROOT, 'escal.json'), encoding='utf-8') as f:
    escal_rows = json.load(f)['rows']


def parse_line(line_nm):
    m = re.match(r'(\d+)호선', line_nm or '')
    return m.group(1) if m else None


def parse_stn_no(stn_no):
    # '211' -> (211, 0) / '211-1' -> (211, 1)
    m = re.match(r'(\d+)(?:-(\d+))?', stn_no or '')
    if not m:
        return (10**9, 0)
    base = int(m.group(1))
    suffix = int(m.group(2)) if m.group(2) else 0
    return (base, suffix)


# ---- 1. 역별 실데이터 집계 ----
elevator_by_name = defaultdict(list)
for r in elev_rows:
    if r.get('stnNm'):
        elevator_by_name[r['stnNm']].append(r)

escalator_by_name = defaultdict(list)
for r in escal_rows:
    if r.get('stnNm'):
        escalator_by_name[r['stnNm']].append(r)

all_names = set(elevator_by_name) | set(escalator_by_name)

stations = {}
for name in all_names:
    erows = elevator_by_name.get(name, [])
    srows = escalator_by_name.get(name, [])
    lines = set()
    for r in erows + srows:
        ln = parse_line(r.get('lineNm'))
        if ln:
            lines.add(ln)
    has_elevator = len(erows) > 0
    has_escalator = len(srows) > 0
    capacity = 0
    for r in erows:
        try:
            capacity = max(capacity, int(r.get('pscpWht') or 0))
        except ValueError:
            pass
    exits_elev = sorted({r.get('vcntEntrcNo') for r in erows if r.get('vcntEntrcNo')}, key=lambda x: (len(x), x))
    exits_escal = sorted({r.get('vcntEntrcNo') for r in srows if r.get('vcntEntrcNo')}, key=lambda x: (len(x), x))

    # vcntEntrcNo(출구 위치) 원본 값은 '7', '내부', '1,2', '천호 방면1-2번 출구'처럼 형식이
    # 제각각이라 "~번 출구"를 기계적으로 붙이면 어색하거나 틀린 문장이 됨. 숫자(콤마 포함)만
    # 있을 때만 "번 출구"를 붙이고, 그 외 자유텍스트는 원문 그대로 둔다.
    def format_exit(token):
        return f'{token}번 출구' if re.fullmatch(r'[0-9,]+', token) else token

    if has_elevator:
        if exits_elev:
            exit_label = ', '.join(format_exit(t) for t in exits_elev[:3])
            note = f'엘리베이터 위치: {exit_label}{" 등" if len(exits_elev) > 3 else ""}'
        else:
            note = '엘리베이터 이용 가능 (세부 위치 미확인)'
    elif has_escalator:
        if exits_escal:
            exit_label = ', '.join(format_exit(t) for t in exits_escal[:3])
            note = f'엘리베이터 없음 · 에스컬레이터 위치: {exit_label}{" 등" if len(exits_escal) > 3 else ""}'
        else:
            note = '엘리베이터 없음 · 에스컬레이터만 이용 가능 (세부 위치 미확인)'
    else:
        note = '편의시설 정보 미확인'

    stations[name] = {
        'name': name,
        'lines': sorted(lines, key=lambda x: int(x)),
        'elevator': has_elevator,
        'escalator': has_escalator,
        'capacityKg': capacity if has_elevator else 0,
        'doorWidthCm': 90 if has_elevator else 0,
        'doorWidthEstimated': has_elevator,
        'note': note,
    }

# ---- 2. 노선별 실제 순서(stnNo) 구성 ----
line_entries = defaultdict(dict)  # line -> {stnNo: name}
for r in elev_rows + escal_rows:
    ln = parse_line(r.get('lineNm'))
    stn_no = r.get('stnNo')
    name = r.get('stnNm')
    if ln and stn_no and name:
        line_entries[ln].setdefault(stn_no, name)

connections = []
AVG_MINUTES = 2

for line, entries in line_entries.items():
    items = sorted(entries.items(), key=lambda kv: parse_stn_no(kv[0]))
    # 본선(스파인): suffix가 없는 항목만
    spine = [(stn_no, name) for stn_no, name in items if parse_stn_no(stn_no)[1] == 0]
    for i in range(len(spine) - 1):
        (no_a, name_a), (no_b, name_b) = spine[i], spine[i + 1]
        gap = max(1, parse_stn_no(no_b)[0] - parse_stn_no(no_a)[0])
        connections.append((name_a, name_b, line, AVG_MINUTES * gap))
    # 지선: 같은 base 번호를 공유하는 suffix>0 항목들을 스파인역에서 체인으로 분기
    by_base = defaultdict(list)
    for stn_no, name in items:
        base, suffix = parse_stn_no(stn_no)
        if suffix > 0:
            by_base[base].append((suffix, name))
    spine_name_by_base = {parse_stn_no(no)[0]: name for no, name in spine}
    for base, branch_items in by_base.items():
        branch_items.sort()
        prev_name = spine_name_by_base.get(base)
        for suffix, name in branch_items:
            if prev_name:
                connections.append((prev_name, name, line, AVG_MINUTES))
            prev_name = name

# 2호선은 순환선 — 마지막 스파인역과 첫 스파인역을 닫는다
if '2' in line_entries:
    spine2 = [(stn_no, name) for stn_no, name in sorted(line_entries['2'].items(), key=lambda kv: parse_stn_no(kv[0])) if parse_stn_no(stn_no)[1] == 0]
    if len(spine2) > 1:
        first_name = spine2[0][1]
        last_name = spine2[-1][1]
        connections.append((last_name, first_name, '2', AVG_MINUTES))

# ---- 3. JS 소스 생성 ----


def esc(s):
    return s.replace('\\', '\\\\').replace("'", "\\'")


# 파일당 500라인 제한(CLAUDE.md 규칙) 준수를 위해 stations/connections/barrel을 분리 생성.

stations_out = []
stations_out.append("// 이 파일은 scripts/build_network.py로 서울교통공사 공개데이터(엘리베이터·에스컬레이터 현황)를")
stations_out.append("// 기반으로 생성되었습니다. 데이터 출처·산정 방식은 스크립트 상단 주석을 참고하세요.")
stations_out.append("// 대상 범위: 1~8호선(서울교통공사 관할) 중 편의시설 데이터가 확인된 역만 포함.")
stations_out.append("// doorWidthCm은 실측값이 아니라 법정 최소 기준(90cm) 추정치입니다 — doorWidthEstimated 참고.")
stations_out.append("export const stations = [")
for name in sorted(stations.keys()):
    s = stations[name]
    stations_out.append(
        "  { id: '%s', name: '%s', lines: [%s], elevator: %s, escalator: %s, capacityKg: %d, doorWidthCm: %d, doorWidthEstimated: %s, note: '%s' },"
        % (
            esc(name), esc(name),
            ', '.join(f"'{l}'" for l in s['lines']),
            'true' if s['elevator'] else 'false',
            'true' if s['escalator'] else 'false',
            s['capacityKg'], s['doorWidthCm'],
            'true' if s['doorWidthEstimated'] else 'false',
            esc(s['note']),
        )
    )
stations_out.append("];")

connections_out = []
connections_out.append("// scripts/build_network.py로 생성됨 — 역간 소요시간(분)은 실측 시간표가 아니라")
connections_out.append("// 평균 역간 운행시간(약 2분) 기준 추정치입니다. network.js 상단 설명 참고.")
connections_out.append("export const connections = [")
for a, b, line, minutes in connections:
    connections_out.append("  ['%s', '%s', '%s', %d]," % (esc(a), esc(b), esc(line), minutes))
connections_out.append("];")

with open(os.path.join(ROOT, 'src', 'data', 'stations.js'), 'w', encoding='utf-8') as f:
    f.write('\n'.join(stations_out) + '\n')

with open(os.path.join(ROOT, 'src', 'data', 'connections.js'), 'w', encoding='utf-8') as f:
    f.write('\n'.join(connections_out) + '\n')

barrel = """// network.js: stations.js/connections.js를 재노출하는 barrel 파일.
// 파일당 500라인 제한(CLAUDE.md)을 지키기 위해 실제 데이터는 두 파일로 분리했습니다.
export { stations } from './stations.js';
export { connections } from './connections.js';

// 노선별 공식 색상(서울교통공사 CI 기준). 데이터셋에 아직 없는 노선(9호선 등)도
// 추후 확장을 대비해 남겨둔다 — 사용되지 않는 키는 무해함.
export const lineColors = {
  '1': '#0d3692', '2': '#00a84d', '3': '#ef7c1c', '4': '#00a5de',
  '5': '#984ea3', '6': '#b5500b', '7': '#697215', '8': '#e6186c',
  '9': '#bb8336', '공항': '#0090d2', '경의중앙': '#77c4a3', '경춘': '#0c8e72', 'X': '#79847f'
};
"""

with open(os.path.join(ROOT, 'src', 'data', 'network.js'), 'w', encoding='utf-8') as f:
    f.write(barrel)

print('stations:', len(stations))
print('connections:', len(connections))
print('lines covered:', sorted(line_entries.keys()))
