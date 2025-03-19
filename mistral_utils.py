import os, base64, pandas as pd, PyPDF2
from mistralai import Mistral

API_KEY = 'vFxjepA65Sm058X0JYtc6fj9MOHlq7Io'
MODEL = 'pixtral-large-latest'
client = Mistral(api_key=API_KEY)

def analyze_file(file_path, prompt):
    if not file_path:
        return 'Please upload a file.'
    ext = os.path.splitext(file_path)[1].lower()
    if ext in ['.txt','.md']:
        content = open(file_path, encoding='utf-8').read()
    elif ext == '.csv':
        content = pd.read_csv(file_path).to_string()
    elif ext == '.pdf':
        reader = PyPDF2.PdfReader(open(file_path,'rb'))
        content = '\\n'.join(p.extract_text() or '' for p in reader.pages)
    elif ext in ['.jpg','.jpeg','.png','.gif','.webp']:
        mime = f'image/{ext.strip(".")}'
        b64 = base64.b64encode(open(file_path,'rb').read()).decode()
        messages = [{'role':'user','content':[{'type':'text','text':prompt},
                                               {'type':'image_url','image_url':{'url':f'data:{mime};base64,{b64}'}}]}]
        return client.chat.complete(model=MODEL, messages=messages).choices[0].message.content
    else:
        return 'Unsupported file type.'
    messages = [{'role':'user','content':f'{prompt}\\n\\nFile Content:\\n{content}'}]
    return client.chat.complete(model=MODEL, messages=messages).choices[0].message.content
