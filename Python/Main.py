from flask import Flask, render_template, request, flash, redirect, url_for
import rpy2.robjects as ro
import os, string, random, json, re
from bson import json_util
from bson.json_util import dumps
from pymongo import MongoClient
from jinja2 import Template
from xhtml2pdf import pisa             # import html->pdf gen module

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
PDF_DIR    = "/static/data/pdf/"

#mongo
MONGODB_HOST = 'localhost'
MONGODB_PORT = 27017
MONGODB_DB_NAME = "smfg"
MONGODB_C_HUMANBODYMAP = "humanbodymap"
MONGODB_C_GENE_EXPRESSION = "geneexpression"
MONGODB_C_HUMANANNOTATION = "humanannotation"
MONGODB_C_MOUSEANNOTATION = "mouse_annotation"
NOTHING_FOUND_ERROR = "Nothing found! Sorry"

#mongo
def dir_gen(size=6, chars=string.ascii_uppercase + string.digits):
    return ''.join(random.choice(chars) for _ in range(size))

#######################################CODE
@app.route("/")
def index():
    """
    Return the HTML for the homepage for the search API v1

    Parameters:
    """
    return render_template('index.html')
@app.route('/search')
def search():
    """
    Returns JSON for API v1. Sends template of images that are generated.

    Parameters:
      args(NS)     - Not Supplied; Used to get gene list
    """
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
        urls['brainspan'] = static_url + '/brainspan.png'
        urls['bodymap'] = static_url + '/bodymap.png'
        urls['celltypes'] = static_url + '/celltypes.png'
        urls['pdfbrainspan'] = BASE_DIR+PDF_DIR + 'brainspan.png'
        urls['pdfbodymap'] = BASE_DIR+PDF_DIR + 'bodymap.png'
        urls['pdfcelltypes'] = BASE_DIR+PDF_DIR + 'celltypes.png'
        data['gene'] = urls
        out['genes'].append(data)
        pdfdirgen = dir_gen()
        filename = BASE_DIR + PDF_DIR + pdfdirgen + ".pdf"
        print(str(convertHtmlToPdf(render_template('pdfgen.html',data=out),filename)))
        foo = str(render_template("list.html",data=out))
        out['genes'] = []
        list_item.append(foo)
    return json.dumps(list_item).lstrip()
# Utility function
def convertHtmlToPdf(sourceHtml, outputFilename):
    """
    Does the actual saving of PDF using HTML

    Parameters:
      sourceHtml     - HTML Code that is already
      outputFilename - Name of PDF File
    """
    # open output file for writing (truncated binary)
    resultFile = open(outputFilename, "w+b")
    # convert HTML to PDF
    pisaStatus = pisa.CreatePDF(
            sourceHtml,                # the HTML to convert
            dest=resultFile)           # file handle to recieve result
    # close output file
    resultFile.close()                 # close output file
    # return True on success and False on errors
    return pisaStatus.err
@app.route("/searchjsonapi")
def json_search_api():
    """
    Returns JSON Data for JSON API v2.

    Parameters:
      args(NS)  - Not Supplied; Used to get gene list.

    """
    query = request.args['q']
    args = request.args
    QueryArray = [x.strip() for x in args.get('q').split(',')]
    connection = MongoClient(MONGODB_HOST, MONGODB_PORT)
    data = []
    for x in QueryArray:
        data.append(dict(bodymapify(connection,x).items() + cellType(connection,x).items() + tableify(connection,x).items()))
    connection.close()
    return json.dumps(data)
def tableify(connection,gene):
    """
    Returns a dict of information for the table on page.

    Parameters:
      connection - connection to the mongodb database->collection
      gene       - name of gene to get table data for

    """
    return {'chromosome' : 'ch1', 'source' : 'HAVANA'}
def cellType(connection,gene):
    """
    Return JSON for celltype data for genes

    Parameters:
      connection - connection to the mongodb database->collection
      gene       - name of the gene to get celltype data for

    """
    collection = connection[MONGODB_DB_NAME][MONGODB_C_MOUSEANNOTATION]
    match = {}
    geneID = collection.find_one({"geneID": re.compile(gene, re.IGNORECASE)},{'_id': False,"id" : False}) #regex the search term    
    geneName = collection.find_one({"geneName": re.compile(gene, re.IGNORECASE)},{'_id': False,"id" : False}) #regex the search term    
    if geneID == None:
        match = geneName
    else:
        match = geneID
    collection = connection[MONGODB_DB_NAME][MONGODB_C_GENE_EXPRESSION]
    genelist = []
    try:
        data = collection.find_one({"": re.compile(match['geneID'], re.IGNORECASE)},{'_id': False,"" : False})
        data[''] = match['geneName']
        for key, value in data.iteritems():
            if key != "":
                genelist.append(10**value)
            else:
                genelist.append(value)
        return {'celltype' : {'data' : genelist}}
    except:
        print("NO VALUES FOUND")
        return {"celltype-error":NOTHING_FOUND_ERROR}
    
def relbodymapify(data):
    """
    Planned: Return data from bodify() with relative bodymap arcs. Largest gene = 1. Smallest would be a percentage of largest gene.

    Parameters:
      ?

    """
    return {'bodymapAbsolute':"FOO"}
def bodymapify(connection,gene):
    """
    Return JSON data for bodymap data for genes

    Parameters:
      connection   - connection to the mongodb database->collection
      gene         - name of the gene to get bodymap data for

    """
    collection = connection[MONGODB_DB_NAME][MONGODB_C_HUMANANNOTATION]
    match = {}
    geneID = collection.find_one({"geneID": re.compile(gene, re.IGNORECASE)},{'_id': False,"id" : False}) #regex the search term    
    geneName = collection.find_one({"geneName": re.compile(gene, re.IGNORECASE)},{'_id': False,"id" : False}) #regex the search term    
    if geneID == None:
        match = geneName
    else:
        match = geneID
    if match is not None:
        collection = connection[MONGODB_DB_NAME][MONGODB_C_HUMANBODYMAP]
        ordereddata = []
        data = []
        category = ['x']
        out = [] #[match['geneName'].upper()+ "|" + match['geneID'].upper()] #In case wanting geneid also -> + "|" + match['geneID'].upper()
        data = collection.find_one({"id": re.compile(match['geneID'], re.IGNORECASE)},{'_id': False,"id" : False})
        for key in data:
            out.append(data[key])
        #print(json.dumps(sorted(data,key=data.__getitem__,reverse=True)))
        for x in sorted(data,key=data.__getitem__,reverse=True):
            ordereddata.append(data[x])
            category.append(x.title()) #Want the axis to have capital letters
        return {'bodymapAbsolute' : {'category' : category ,'data' : ordereddata }, 'gene' : match['geneName'].upper(), 'geneID' : match['geneID'].upper(), 'geneBodymapTotal' : sum(data.values())}
    else:
        return {'bodymap-error' : NOTHING_FOUND_ERROR}
@app.route("/searchj")
def json_search():
    """
    Return the HTML for the homepage for the JSON search API v2

    Parameters:
    """
    return render_template("d3index.html")
if __name__ == "__main__":
    ro.r.source("PlotGenes.R")
    #run through r script
    func = ro.globalenv['makeGraphs']
    #load function for making plots into memory
    app.run()