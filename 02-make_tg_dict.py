import textgrid
import os
from tqdm import tqdm
TEXTGRID_DIR = '/home/matt/timbuck_data/timbuck_textgrids'
DICT_NAME = 'tg_dict.txt'
import re

REPLACEMENTS = {
    'a':'ah',
    'aan':'aa',
    'aen':'ae',
    'ahn':'ah',
    'aon':'ao',
    'awn':'aw',
    'ayn':'ay',
    'ehn':'eh',
    'el':'l',
    'em':'m',
    'en':'n',
    'eng':'ng',
    'er':'r',
    'ern':'r',
    'eyn':'ey',
    'h':'hh',
    'hhn':'hh',
    'ihn':'ih',
    'iyn':'iy',
    'nx':'n',
    'own':'ow',
    'oyn':'oy',
    'tq':'t',
    'uhn':'uh',
    'uwn':'uw',
    '<sil>':'sil'
    }

IGNORE = set([
    '<EXCLUDE-NAME>',
    '<EXCLUDE>',
    'EXCLUDE',
    '<EXCLUDE>',
    'IVER',
    '<IVER>',
    'IVER-LAUGH',
    '<IVER-LAUGH>',
    'LAUGH',
    '<LAUGH>',
    'NOISE',
    '<NOISE>',
    'UNKNOWN',
    '<UNKNOWN>',
    'VOCNOISE',
    '<VOCNOISE>',
    '{B_TRANS}',
    '{E_TRANS}',
    '',
    ])

entries = list()
for fname in tqdm(sorted(os.listdir(TEXTGRID_DIR))):
    p = os.path.join(TEXTGRID_DIR, fname)
    t = textgrid.TextGrid()
    t.read(p)
    base = os.path.splitext(fname)[0]
    tier_num = 1 if fname.startswith('s') else 0
    phones = [re.sub(r'[;\+]', '', x.mark) for x in t.tiers[tier_num]]
    phones = [re.sub(r'[0-9]', '', x) for x in phones]
    phones = [REPLACEMENTS[x.lower()] if x.lower() in REPLACEMENTS else x for x in phones]
    phones = [x for x in phones if x.upper() not in IGNORE]

    entries.append((base.upper(), phones))

with open(DICT_NAME, 'w') as w:
    for headword, phones in tqdm(entries):
        phone_string = ' '.join(phones)
        w.write(f'{headword}  {phone_string}\n')
