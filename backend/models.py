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
    name = db.Column(db.ForeignKey('user.name'))
    content = db.Column(db.String)
    time_stamp = db.Column(db.String, nullable=False)

    def __repr__(self):
        return f"Post('{self.content}')"

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(20), nullable=False)
    grid_id = db.Column(db.Integer, db.ForeignKey('grid.id'), nullable=True)
    latitude = db.Column(db.Integer)
    longitude = db.Column(db.Integer)

    def __repr__(self):
        return f"User('{self.id}', '{self.grid_id}', '{self.lat}', '{self.long}')"
