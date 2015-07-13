from flask import Flask, render_template, request
app = Flask(__name__)
app.config.update(
    DEBUG=True,
    HOST='0.0.0.0',
    PORT=8000
)

@app.route("/")
def index():
    return render_template('index.html')

@app.route('/search')
def search():
	args = request.args
	if(args.get('method') == 'compare'):
		return render_template('compare.html', queries=args['q'])
	else:
		return render_template('search.html', queries=args['q'])
if __name__ == "__main__":
    app.run()