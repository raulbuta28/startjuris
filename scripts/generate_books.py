import json, os, re

base = os.path.join('assets', 'carti')

books = [
    {"id": "civil_1", "title": "Despre persoane", "image": "carti/1.png", "content": "Sample content"},
    {"id": "civil_2", "title": "Căsătoria", "image": "carti/2.png", "content": "Sample content"},
]

# civil images 3.png..29.png
def is_png(name):
    return name.endswith('.png') and name != 'default.png'

for name in sorted(os.listdir(base)):
    if not is_png(name):
        continue
    if name in ('1.png', '2.png'):
        continue
    num = os.path.splitext(name)[0]
    books.append({
        "id": f"civil_{num}",
        "title": f"Cartea {num}",
        "image": f"carti/{name}",
        "content": "Sample content"
    })

# dpc
for name in sorted(os.listdir(os.path.join(base,'cartidpc'))):
    if is_png(name):
        num = os.path.splitext(name)[0]
        books.append({
            "id": f"dpc_{num}",
            "title": f"DPC {num}",
            "image": f"carti/cartidpc/{name}",
            "content": "Sample content"
        })

# dp
for name in sorted(os.listdir(os.path.join(base,'cartidp'))):
    if is_png(name):
        num = os.path.splitext(name)[0]
        books.append({
            "id": f"dp_{num}",
            "title": f"DP {num}",
            "image": f"carti/cartidp/{name}",
            "content": "Sample content"
        })

# dpp
for name in sorted(os.listdir(os.path.join(base,'cartidpp'))):
    if is_png(name):
        num = os.path.splitext(name)[0]
        books.append({
            "id": f"dpp_{num}",
            "title": f"DPP {num}",
            "image": f"carti/cartidpp/{name}",
            "content": "Sample content"
        })

with open(os.path.join('dashbord-react','books.json'),'w') as f:
    json.dump(books,f,indent=2,ensure_ascii=False)
