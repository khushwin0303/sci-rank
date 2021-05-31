"""Created on Sat Feb 27 15:13:35 2021

This file is responsible for interacting with the front-end and other elements of the web

author: Daniel Broderick"""

import numpy as np
import io
import requests
import nltk
import PyPDF2
import pdfplumber

# from scihub import SciHub
nltk.download("punkt")
nltk.download('vader_lexicon')
from nltk.sentiment.vader import SentimentIntensityAnalyzer
from serpapi import GoogleSearch

api_key = "d3794c0470001e53e2ca4209bfd14dcd8f5ca707e2c63879263ee0e5ab8023b4"

from flask import Flask, jsonify, request

app = Flask(__name__)


@app.route("/")
def index():
    # displayed when you view the base url http://danjoe4.pythonanywhere.com/
    return """Here's a brief api description:
    {"doi" :"10.1242/jeb.02155"} is the format for POST requests.json
    
    you should post to http://danjoe4.pythonanywhere.com/doi

    a dictionary is returned in the form 
    {"abstract" : "text", 
    "date" : "7 February 2006",
    "sentiment" : "The overall sentiment of this article was {positve/negative}"}

    note that date may return "This may be the wrong date: 7 February 2006" 
    depending on the certainty

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
        info["date"] = get_date(pdf_text[1])

        pdf_tokens = full_sentence_tokenize(pdf_text)
        info["sentiment"] = get_sentiment(pdf_tokens)

        return info 


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


def full_sentence_tokenize(text):
    # concats the pages and creates a list of sentence strings
    full_text = ""
    for page in text.values():  # break into sentences
        full_text += page
    
    sentences = nltk.tokenize.sent_tokenize(full_text)
    #print(sentences)
    return sentences


def get_abstract(first_page):
    # pulls the abstract from the first page
    text = nltk.tokenize.word_tokenize(first_page)
    text = nltk.text.Text(text)  # a usable text object
    # searches for the start index, indicated by the "abstract or "summary" title
    # These are case sensitive, this increases accuracy because headers should always
    # be capitalized
    print(text[0:])

    start = None
    try:
        for x in ["Summary", "Abstract"]:
            if x in text:
                start = text.index(x)
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
                print("heredabfoivcberdsohvbaoudsvbuodfbcv")
                break
    except ValueError:
        pass
    finally:
        if end == None:
            # print("No abstract found")
            return "No abstract found"

    # use our indices to extract the abstract body
    #print(text[start + 1 : end])
    clipped_abstract = " ".join([str(word) for word in text[start + 1 : end]])
    #print(clipped_abstract)

    return clipped_abstract


def get_date(first_page):
    # gets the papers date
    text = nltk.tokenize.word_tokenize(first_page)
    text = nltk.text.Text(text)  # a usable text object

    #print(text[0:])
    try:
        start = text.index("Accepted")
    except ValueError:
        return "No date found"

    clipped_date = text[start + 1 : start + 4]

    months = ["january", "february", "march", "april", "may", "june", "july", "august",
        "september", "october", "november", "december"]
    # express uncertainly if the month or year are not the expected format
    if clipped_date[1].lower() not in months or len(clipped_date[2]) != 4:
        out = " ".join([str(word) for word in clipped_date])
        return "This may be the wrong date: " + out

    out = " ".join([str(word) for word in clipped_date])
    return out


def get_sentiment(text):
    sid = SentimentIntensityAnalyzer()
    scores = [] # a list of the sentiment scores
    for sentence in text:
        score_dict = sid.polarity_scores(sentence)
        scores.append(score_dict)

    # extract the compound (combined negativity/positivity/neutrality) scores
    compound_scores = [score["compound"] for score in scores]
    # find their mean
    mean = np.mean(compound_scores)

    # ratings dict
    ratings = {'1': "very positive", '2': "mostly positive", '3': "slightly positive",
                '4': "neutral", '5': "slightly negative", '6': "mostly negative", '7': "very negative"}
    
    # turn our numberical rating into a description
    if mean > .11: 
        rating = 1
    elif mean > .08:
        rating = 2
    elif mean > .05:
        rating = 3
    elif mean < -.11: 
        rating = 5
    elif mean < -.08:
        rating = 6
    elif mean < -.05:
        rating = 7
    else: 
        rating = 4
    
    rating_txt = ratings[str(rating)]
    out = f"The overall sentiment of this article was {rating_txt}"
    return out



if __name__ == "__main__":
    app.run(debug=True)
    # paper =retrieve_paper("10.1242/jeb.02155")
    # out = get_file("https://www2.clarku.edu/faculty/pbergmann/research/Bergmann%20and%20Irschick%202006.pdf")
    # print(paper)
    # main()
    # tokenize({"1": "here i am how are you. I am good. \n", "2": "n = 5"})
    # get_abstract("her i am how are you Abstract i am cool Introduction here we are")
    # get_date("here i am how are you. Some title stuff. Accepted 7 February 2006")
    #get_sentiment(["I am very happy.", "I am kind of sad.", "This is my presentation"])