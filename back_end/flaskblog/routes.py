import os
from flask import render_template
from back_end.flaskblog import app

@app.route("/")
def home():
    return render_template('home.html')