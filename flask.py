from flask import Flask, request, redirect
import random
import string

app = Flask(__name__)
lyrics_store = {}

def generate_code():
    return ''.join(random.choices(string.ascii_lowercase + string.digits, k=6))

@app.route('/')
def home():
    return '''
    <form action="/create" method="post">
        <textarea name="lyrics" rows="10" cols="50"></textarea><br>
        <input type="submit" value="Create Show">
    </form>
    '''

@app.route('/create', methods=['POST'])
def create_show():
    code = generate_code()
    lyrics_store[code] = request.form['lyrics']
    return f'Share this link: {request.host_url}show/{code}'

@app.route('/show/<code>')
def show_lyrics(code):
    lyrics = lyrics_store.get(code, "Invalid or expired code")
    return f'''
    <html>
        <body style="background: black; color: white; font-family: monospace;">
            <div id="display"></div>
            <script>
                const lyrics = {repr(lyrics).replace("'", "\\'")};
                let index = 0;
                
                function typeWriter() {{
                    if (index < lyrics.length) {{
                        document.getElementById("display").innerHTML += lyrics[index];
                        index++;
                        setTimeout(typeWriter, 100);
                    }}
                }}
                
                document.body.onclick = typeWriter;  // Start on click
            </script>
        </body>
    </html>
    '''

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)