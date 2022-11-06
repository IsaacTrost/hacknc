import os
from flask import render_template
from back_end.grid import app
from flaskblog.forms import ChatForm
from flaskblog import db
from utils import distance, insideGrid, GRID_SIZE
from models import Grid

from flask import request

GRID_SIZE = 100  # grid size in meters


@app.route("/chat", methods=['GET', 'POST'])
def chat():
    form = ChatForm()

    if form.valudate_on_submit():
        # how do i use the current grid id
        chat = ChatForm(content=form.content.data,
                        grid_id=request.args['current_grid'])
        db.session.add(chat)
        db.session.commit()


@app.route("/heartbeat", methods=['POST'])
def heartbeat():
    # current lat and long
    latitude_1 = request.args['latitude_1']
    longitude_1 = request.args['longitude_2']
    user_id = request.args['user_id']
    current_grid_id = request.args['current_grid']

    if current_grid_id is not None:
        # lat and long of grid
        grid = Grid.query.filter_by(id=current_grid_id)
        latitude_2 = grid['latitude_2']
        longitude_2 = grid['longitude_2']

        # finding distance relative to lat and long of center of grid
        d = distance(lat1=latitude_1, lat2=latitude_2,
                     long1=longitude_1, long2=longitude_2)

    if d > GRID_SIZE:
        # remove user from current grid
        if current_grid_id is not None:
            grid.inhabitants.remove(user_id)
            db.session.commit()

        # add them to new one
        all = Grid.query.all()
        for g in all:
            if insideGrid(latitude_1, longitude_2, latitude_2, longitude_2):
                g.inhabitants.add(user_id)
                db.session.commit()
                return # return if we find a grid

        # else, create a new grid
        grid = Grid(latitude_1, latitude_2) 
        db.session.add(grid)
        db.session.commit()
    

