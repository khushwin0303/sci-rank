"""Created on Sat Feb 27 15:13:35 2021

This file is responsible for interacting with the front-end and other elements of the web

author: Daniel Broderick"""

import io
import requests
import nltk
import PyPDF2
import pdfplumber

# from scihub import SciHub
nltk.download("punkt")
from serpapi import GoogleSearch

api_key = "d3794c0470001e53e2ca4209bfd14dcd8f5ca707e2c63879263ee0e5ab8023b4"


from flask import Flask, jsonify, request

app = Flask(__name__)


@app.route("/")
def index():
    return """Here's a brief api description:
    {"doi" :"10.1242/jeb.02155"} is the format for POST requests.json
    
    you should post to http://danjoe4.pythonanywhere.com/doi

    a dictionary is returned in the form 
    {"abstract" : "text", 
    "date" : "not implemented yet",
    "n_value" : "not implement yet"}
    """


@app.route("/doi", methods=["POST"])
def store_doi():
    if request.method == "POST":  # handle the post request and extract the doi
        posted_data = request.get_json()
        doi = posted_data["doi"]
        pdf_link = retrieve_paper(doi)  # get the pdf link
        pdf_text = get_text(pdf_link)  # extract the text from the pdf

        # gather our info
        info = {}
        info["abstract"] = get_abstract(pdf_text[1])  # only requires the first page
        # info["date"] = get_date(pdf_text[1])

        # pdf_tokens = tokenize(pdf_text)  # turn the string into a list of strings
        # info["n_value"] = get_nvalue(pdf_tokens)

        return info


@app.route("/message", methods=["GET"])
def message():
    posted_data = request.get_json()
    name = posted_data["name"]
    return jsonify(" Hope you are having a good time " + name + "!!!")


def retrieve_paper(doi):
    """query google scholar api for the article"""
    params = {"engine": "google_scholar", "q": doi, "api_key": api_key}
    search = GoogleSearch(params)
    results = search.get_dict()

    # now we need to parse through the huge json returned
    # to actually find the pdf link
    pdflink = results["organic_results"][0]["resources"][0]["link"]
    return pdflink


def get_text(url):
    """download the pdf"""
    # fetch the pdf, represented as bytes
    response = requests.get(url)
    byte_stream = io.BytesIO(response.content)

    # extract the fulltext and put it in a dict by pagenumber
    fulltext = {}
    with pdfplumber.open(byte_stream) as pdf:
        for page in pdf.pages:
            fulltext[page.page_number] = page.extract_text()

    return fulltext


def tokenize(text):
    # turn the text into a useable format
    sentences = []
    for page in text.values():  # break into sentences
        sentences += nltk.tokenize.sent_tokenize(page)
    sentences = [nltk.tokenize.word_tokenize(sent) for sent in sentences]  # words
    # sentences = [nltk.tokenize.pos_tag(sent) for sent in sentences]  # part of speech tagging
    print(sentences)
    return sentences


def get_abstract(first_page):
    # pulls the abstract from the first page
    text = nltk.tokenize.word_tokenize(first_page)
    text = nltk.text.Text(text)  # a usable text object
    # searches for the start index, indicated by the "abstract or "summary" title
    # These are case sensitive, this increases accuracy because headers should always
    # be capitalized
    start = None
    try:
        for x in ["Summary", "Abstract"]:
            start = text.index(x)
            if start != None:
                break
    except ValueError:
        pass
    finally:
        if start == None:
            # print("No abstract found")
            return "No abstract found"

    # searches for the end index, indicated by the introduction/background header
    # or by keywords, a common
    end = None
    try:
        for x in ["Introduction", "Background"]:
            end = text.index(x)
            if end != None:
                break
    except ValueError:
        pass
    finally:
        if end == None:
            # print("No abstract found")
            return "No abstract found"

    # use our indices to extract the abstract body
    print(text[start + 1 : end])
    clipped_abstract = " ".join([str(word) for word in text[start + 1 : end]])
    print(clipped_abstract)

    return clipped_abstract


def get_date(first_page):
    # gets the papers date
    nltk.tokenize.word_tokenize(first_page)
    return ""


def get_nvalue(text):
    # we basically look for "n=" and do a word frequency analysis for the
    # following value; assumes the most frequent value is correct

    return ""


if __name__ == "__main__":
    app.run(debug=True)
    # paper =retrieve_paper("10.1242/jeb.02155")
    # out = get_file("https://www2.clarku.edu/faculty/pbergmann/research/Bergmann%20and%20Irschick%202006.pdf")
    # print(paper)
    # main()
    # tokenize({"1": "here i am how are you. I am good. \n", "2": "n = 5"})
    # get_date([['here', 'i', 'am', 'how', 'are', 'you', '.'], ['I', 'am', 'good', '.'], ['n', '=', '5']])
    # get_abstract("her i am how are you Abstract i am cool Introduction here we are")
