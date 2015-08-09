from flask import Flask, render_template, request, flash, redirect, url_for
import rpy2.robjects as ro
import os, string, random, json
from jinja2 import Template
BASE_DIR = os.path.dirname(os.path.realpath(__file__))
app = Flask(__name__)
func = None
app.config.update(
    DEBUG=False,
    HOST='0.0.0.0',
    PORT=8000,
    SECRET_KEY="abcdefghijklmnopqrstuvwxyz001"
)
SINGLE_DIR = "/static/data/single/"
MULTI_DIR  = "/static/data/multi/"
TOTAL_IMAGES = 3
def dir_gen(size=6, chars=string.ascii_uppercase + string.digits):
    return ''.join(random.choice(chars) for _ in range(size))

#######################################CODE
@app.route("/")
def index():
    return render_template('index.html')
@app.route('/search')
def search1():
    args = request.args
    QueryString = [x.strip() for x in args.get('q').split(',')]
    out = {}
    out['genes'] = []
    xnum = -1
    list_item = []
    for x in QueryString:
        data = {}
        urls = {}
        url=BASE_DIR + SINGLE_DIR + x
        static_url = SINGLE_DIR + x
        xnum += 1
        if not(os.path.isdir(url)):
            try:
                func(SINGLE_DIR+x+"/","testrun1",x)
            except:
                flash("Enter a valid gene identifier")
                return redirect(url_for('index'))
        #else:print("Already Cached: " + x)
        urls['gene_name'] = x
        urls['brainspan'] = static_url + '/brainspan.svg'
        urls['bodymap'] = static_url + '/bodymap.svg'
        urls['celltypes'] = static_url + '/celltypes.svg'
        data['gene'] = urls
        out['genes'].append(data)
        foo = str(render_template("list.html",data=out))
        out['genes'] = []
        list_item.append(foo)
    return json.dumps(list_item).lstrip()

if __name__ == "__main__":
    ro.r.source("PlotGenes.R")
    #run through r script
    func = ro.globalenv['makeGraphs']
    #load function for making plots into memory
    app.run()