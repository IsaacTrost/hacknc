import os
from flask import render_template
from back_end.flaskblog import app
from flaskblog.forms import ChatForm
from flaskblog import db

@app.route("/chat", methods=['GET', 'POST'])
def chat():
    form = ChatForm()

    if form.valudate_on_submit():
        chat = ChatForm(content=form.content.data)#how do i use the current grid id
        db.session.add(chat)
        db.session.commit()