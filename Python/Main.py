from flask import Flask, render_template, request, flash, redirect, url_for
import rpy2.robjects as ro
import os, string, random, json, re
from bson import json_util
from bson.json_util import dumps
from pymongo import MongoClient
from jinja2 import Template
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
MULTI_DIR  = "/static/data/multi/"
#mongo
MONGODB_HOST = 'localhost'
MONGODB_PORT = 27017
MONGODB_DB_NAME = "smfg"
MONGODB_C_HUMANBODYMAP = "humanbodymap"
MONGODB_C_HUMANANNOTATION = "humanannotation"

#mongo
def dir_gen(size=6, chars=string.ascii_uppercase + string.digits):
    return ''.join(random.choice(chars) for _ in range(size))

#######################################CODE
@app.route("/")
def index():
    return render_template('index.html')
@app.route('/search')
def search():
    args = request.args
    QueryArray = [x.strip() for x in args.get('q').split(',')]
    out = {}
    out['genes'] = []
    xnum = -1
    list_item = []
    for x in QueryArray:
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
@app.route("/searchjsonapi")
def json_search_api():
    query = request.args['q']
    args = request.args
    QueryArray = [x.strip() for x in args.get('q').split(',')]
    connection = MongoClient(MONGODB_HOST, MONGODB_PORT)
    bodymap = bodymapify(connection,QueryArray[0])
    data = []
    for x in QueryArray:
        data.append(bodymapify(connection,x))
    connection.close()
    print(json.dumps(data))
    return json.dumps(data)
def bodymapify(connection,gene):
    collection = connection[MONGODB_DB_NAME][MONGODB_C_HUMANANNOTATION]
    match = {}
    geneID = collection.find_one({"geneID": re.compile(gene, re.IGNORECASE)},{'_id': False,"id" : False}) #regex the search term    
    geneName = collection.find_one({"geneName": re.compile(gene, re.IGNORECASE)},{'_id': False,"id" : False}) #regex the search term    
    if geneID == None:
        match = geneName
    else:
        match = geneID
    collection = connection[MONGODB_DB_NAME][MONGODB_C_HUMANBODYMAP]
    data = collection.find_one({"id": re.compile(match['geneID'], re.IGNORECASE)},{'_id': False,"id" : False})
    out = [match['geneName'].upper()+ "|" + match['geneID'].upper()] #In case wanting geneid also -> + "|" + match['geneID'].upper()
    category = []
    for key in data:
        category.append(key.title()) #Want the axis to have capital letters
        out.append(data[key])
    return {'bodymap' : {'category' : category ,'data' : out }}
@app.route("/searchj")
def json_search():
    return render_template("d3index.html")
if __name__ == "__main__":
    ro.r.source("PlotGenes.R")
    #run through r script
    func = ro.globalenv['makeGraphs']
    #load function for making plots into memory
    app.run()