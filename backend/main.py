# -*- coding: utf-8 -*-
"""
Created on Sat Feb 27 15:13:35 2021

@author: Daniel Broderick
"""
import numpy as np
import pdfminer
import nltk

from flask import Flask, jsonify, request
app = Flask(__name__)

@app.route('/')
def index():
    return 'the server is up'

@app.route("/name", methods=["POST"])
def setName():
    if request.method=='POST':
        posted_data = request.get_json()
        data = posted_data['data']
        return jsonify(str("Successfully stored  " + str(data)))

@app.route("/message", methods=["GET"])
def message():
    posted_data = request.get_json()
    name = posted_data['name']
    return jsonify(" Hope you are having a good time " +  name + "!!!")

def hello():
    return 'Hello, world!' 

    
    
    


if __name__ == "__main__":
    app.run(debug=True)