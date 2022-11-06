from backend import db

from backend.utils import GRID_SIZE

class Grid(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    inhabitants = db.relationship('User', backref='grid')
    latitude = db.Column(db.Float)
    longitude = db.Column(db.Float)
    chat_history = db.relationship('Chat', backref='grid')

    def __repr__(self):
        return f"Grid('{self.id}', '{self.inhabitants}', '{self.latitude}', '{self.longitude}', '{self.chat_history}')"

class Chat(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    grid_id = db.Column(db.Integer, db.ForeignKey('grid.id'))
    content = db.Column(db.Text, nullable=False)

    def __repr__(self):
        return f"Post('{self.content}')"

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    grid_id = db.Column(db.Integer, db.ForeignKey('grid.id'))
    lat = db.Column(db.Integer)
    long = db.Column(db.Integer)

    def __repr__(self):
        return f"User('{self.id}', '{self.grid_id}', '{self.lat}', '{self.long}')"
