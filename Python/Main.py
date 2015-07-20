from flask import Flask, render_template, request, flash, redirect, url_for
import rpy2.robjects as ro
import os
BASE_DIR = os.path.dirname(os.path.realpath(__file__))
app = Flask(__name__)
func = None
app.config.update(
    DEBUG=True,
    HOST='0.0.0.0',
    PORT=8000,
    SECRET_KEY="abcdefghijklmnopqrstuvwxyz001"
)
SINGLE_DIR = "/static/data/single/"
@app.route("/")
def index():
    return render_template('index.html')
@app.route('/search')
def search():
    args = request.args
    if(args.get('method') == 'compare'):
        return render_template('compare.html', queries=args['q'])
    else:
        if not(os.path.isdir(BASE_DIR + SINGLE_DIR + args.get("q"))):
            print("Creating Cache")
            try:
                func(SINGLE_DIR+args.get('q')+"/","testrun1",args.get('q'))
            except:
                flash("Enter a valid gene identifier")
                return redirect(url_for('index'))
        else:
            print("Already Cached")
        return redirect(url_for('gene',gene_id=args.get('q')))
@app.route('/gene/<gene_id>')
def gene(gene_id):
    if not(os.path.isdir(BASE_DIR + SINGLE_DIR + gene_id)):
        return redirect(url_for('search',q=gene_id))
    return render_template('gene.html', queries=gene_id, geneurl=SINGLE_DIR+gene_id)
if __name__ == "__main__":
    ro.r.source("PlotGenes.R")
    func = ro.globalenv['makeGraphs']
    app.run()