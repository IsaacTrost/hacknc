import os
from flask import render_template
from back_end.flaskblog import app
from flaskblog import 

@app.route("/", methods=['GET', 'POST'])
def home():
    return render_template('home.html')
    form = ChatForm()
    print(form.validate_on_submit())

    if form.valudate_on_submit():
        chat = Chat(id = , grid_id=)