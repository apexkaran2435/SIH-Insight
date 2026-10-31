"""Fetch archived SIH 2025/2026 datasets and generate MySQL INSERT statements.

The 2025 workbook and 2026 JSON are community-maintained exports of SIH portal
records. The official portal URLs are recorded in the generated SQL for provenance.
No student/team/project/result records are fabricated by this script.
"""
from pathlib import Path
from datetime import date
import json, re, sys
import requests
from openpyxl import load_workbook

ROOT = Path(__file__).resolve().parent
OUT = ROOT / '02_original_sih_data.sql'
URL_2025 = 'https://raw.githubusercontent.com/sathish126/SIH-2025-PROBLEM-STATEMENTS/main/SIH%202025%20PS.xlsx'
URL_2026 = 'https://raw.githubusercontent.com/iamsayanmanna/SIH-2026-Problem-Statements/main/data/sih-2026.json'
OFFICIAL_2025 = 'https://www.sih.gov.in/sih2025PS'
OFFICIAL_2026 = 'https://www.sih.gov.in/sih2026PS'


def fetch(url, dest):
    print('Downloading:', url)
    r = requests.get(url, timeout=90, headers={'User-Agent':'SIH-Insight-Student-DBMS-Project/1.0'})
    r.raise_for_status()
    dest.write_bytes(r.content)
    return dest


def clean(v):
    if v is None: return ''
    return re.sub(r'\s+', ' ', str(v)).strip()


def norm(s):
    return re.sub(r'[^a-z0-9]+', '', clean(s).lower())


def sql(v):
    if v is None or v == '': return 'NULL'
    return "'" + str(v).replace('\\', '\\\\').replace("'", "''").replace('\x00','') + "'"


def find_col(headers, aliases):
    nh = [norm(x) for x in headers]
    for alias in aliases:
        a = norm(alias)
        for i, h in enumerate(nh):
            if h == a or a in h or h in a:
                return i
    return None


def read_2025(path):
    wb = load_workbook(path, read_only=True, data_only=True)
    out=[]
    for ws in wb.worksheets:
        rows = ws.iter_rows(values_only=True)
        all_rows = list(rows)
        header_i = None
        for i, row in enumerate(all_rows[:20]):
            hs=[clean(x) for x in row]
            joined=' '.join(norm(x) for x in hs)
            if ('problemstatement' in joined or 'problemstatementtitle' in joined) and ('psnumber' in joined or 'psid' in joined):
                header_i=i; break
        if header_i is None: continue
        headers=[clean(x) for x in all_rows[header_i]]
        idx={
          'id':find_col(headers,['PS Number','Problem Statement ID','PS ID','Problem ID']),
          'title':find_col(headers,['Problem Statement Title','Title','Problem Statement']),
          'org':find_col(headers,['Organization','Organisation','Ministry']),
          'category':find_col(headers,['Category','Type']),
          'theme':find_col(headers,['Theme','Domain']),
          'ideas':find_col(headers,['Submitted Idea(s) Count','Ideas Submitted','Idea Count']),
          'description':find_col(headers,['Description','Problem Statement Description','Background']),
          'department':find_col(headers,['Department','Sponsoring Department']),
          'deadline':find_col(headers,['Deadline','Submission Deadline'])
        }
        if idx['id'] is None or idx['title'] is None: continue
        for row in all_rows[header_i+1:]:
            def get(k):
                j=idx[k]
                return clean(row[j]) if j is not None and j < len(row) else ''
            psid=get('id'); title=get('title')
            if not psid or not title: continue
            # Keep the published PS identifier as it appears in the workbook.
            out.append({'id':psid,'title':title,'organization':get('org'),
                        'category':get('category'),'theme':get('theme'),
                        'ideas_submitted':get('ideas'),'description':get('description'),
                        'department':get('department'),'deadline':get('deadline'),
                        'edition_year':2025,'official_url':OFFICIAL_2025,
                        'dataset_url':URL_2025,'snapshot_date':None})
    # Deduplicate only identical PS IDs; keep first occurrence from workbook.
    unique={}
    for x in out: unique.setdefault(x['id'],x)
    if not unique:
        raise RuntimeError('Could not detect SIH 2025 workbook columns. Inspect the downloaded workbook headers before importing; no guessed rows were generated.')
    return list(unique.values())


def read_2026(path):
    data=json.loads(path.read_text(encoding='utf-8-sig'))
    problems=data.get('problems', data if isinstance(data,list) else [])
    out=[]
    for p in problems:
        out.append({'id':clean(p.get('id')),'title':clean(p.get('title')),
          'organization':clean(p.get('organization')),'category':clean(p.get('category')),
          'theme':clean(p.get('theme')),'ideas_submitted':clean(p.get('ideas_submitted')),
          'description':p.get('description') or p.get('summary') or '',
          'department':clean(p.get('department')),'deadline':clean(p.get('deadline')),
          'edition_year':2026,'official_url':OFFICIAL_2026,'dataset_url':URL_2026,
          'snapshot_date':'2026-08-21'})
    out=[x for x in out if x['id'] and x['title']]
    unique={}
    for x in out: unique.setdefault(x['id'],x)
    if not unique: raise RuntimeError('No SIH 2026 records found in the downloaded JSON.')
    return list(unique.values())


def chunks(items, size=100):
    for i in range(0,len(items),size): yield items[i:i+size]


def main():
    try:
        p25=fetch(URL_2025, ROOT/'source_sih_2025.xlsx')
        p26=fetch(URL_2026, ROOT/'source_sih_2026.json')
        records=read_2025(p25)+read_2026(p26)
    except Exception as e:
        print('\nDATA GENERATION STOPPED:',e)
        print('No incomplete SQL file has been generated. Check internet access and source file structure.')
        sys.exit(1)

    orgs=sorted({x['organization'] for x in records if x['organization']})
    themes=sorted({x['theme'] for x in records if x['theme']})
    lines=['USE SIH_Insight;','SET NAMES utf8mb4;','START TRANSACTION;','',
      '-- Original problem-statement records from archived SIH portal exports.',
      '-- SIH 2025 workbook and SIH 2026 canonical JSON are community-hosted exports.',
      '-- Official portal source URLs are stored on every record.',
      '-- 2025 description fields remain NULL if the source workbook does not provide them.',
      '-- This file contains no invented SIH problem statements.','']
    for year,name in [(2025,'Smart India Hackathon 2025'),(2026,'Smart India Hackathon 2026')]:
        lines.append(f"INSERT IGNORE INTO Edition (edition_year, edition_name) VALUES ({year}, {sql(name)});")
    lines.append('')
    for org in orgs:
        lines.append(f"INSERT INTO Organization (organization_name) VALUES ({sql(org)}) ON DUPLICATE KEY UPDATE organization_name=VALUES(organization_name);")
    lines.append('')
    for theme in themes:
        lines.append(f"INSERT INTO Theme (theme_name) VALUES ({sql(theme)}) ON DUPLICATE KEY UPDATE theme_name=VALUES(theme_name);")
    lines.append('')
    cols='ps_id, edition_year, title, category, theme_id, organization_id, department, description, deadline, ideas_submitted, official_source_url, dataset_source_url, snapshot_date'
    for batch in chunks(records,50):
        vals=[]
        for x in batch:
            theme_expr=f"(SELECT theme_id FROM Theme WHERE theme_name={sql(x['theme'])})" if x['theme'] else 'NULL'
            org_expr=f"(SELECT organization_id FROM Organization WHERE organization_name={sql(x['organization'])})" if x['organization'] else 'NULL'
            snap=sql(x['snapshot_date']) if x['snapshot_date'] else 'NULL'
            vals.append('(' + ', '.join([sql(x['id']),str(x['edition_year']),sql(x['title']),sql(x['category']),theme_expr,org_expr,sql(x['department']),sql(x['description']),sql(x['deadline']),sql(x['ideas_submitted']),sql(x['official_url']),sql(x['dataset_url']),snap]) + ')')
        lines.append(f"INSERT INTO Problem_Statement ({cols}) VALUES\n"+',\n'.join(vals)+"\nON DUPLICATE KEY UPDATE title=VALUES(title), category=VALUES(category), theme_id=VALUES(theme_id), organization_id=VALUES(organization_id), department=VALUES(department), description=VALUES(description), deadline=VALUES(deadline), ideas_submitted=VALUES(ideas_submitted), official_source_url=VALUES(official_source_url), dataset_source_url=VALUES(dataset_source_url), snapshot_date=VALUES(snapshot_date);")
        lines.append('')
    lines += ['COMMIT;','', '-- Verify imported original records:',
      'SELECT edition_year, COUNT(*) AS imported_problem_statements FROM Problem_Statement GROUP BY edition_year ORDER BY edition_year;',
      'SELECT COUNT(*) AS total_original_problem_statements FROM Problem_Statement;','']
    OUT.write_text('\n'.join(lines),encoding='utf-8')
    n25=sum(x['edition_year']==2025 for x in records); n26=sum(x['edition_year']==2026 for x in records)
    print(f'Generated {OUT.name}: {n25} SIH 2025 records + {n26} SIH 2026 records = {len(records)} total.')
    print('The generated file contains SQL INSERT statements with original source fields.')

if __name__=='__main__': main()
