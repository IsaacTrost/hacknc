from flaskblog import db

from utils import GRID_SIZE

class Grid(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    inhabitants = db.relationship('User', backref='grid')
    latitude = db.Column(db.Double)
    longitude = db.Column(db.Double)
    chat_history = db.relationship('Chat', backref='grid')

    def __repr__(self):
        return f"User('{self.id}', '{self.x}', '{self.y}')"

class Chat(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    grid_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    content = db.Column(db.Text, nullable=False)

    def __repr__(self):
        return f"Post('{self.content}')"

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    grid_id = db.Column(db.Integer, db.ForeignKey('grid.id'))
    lat = db.Column(db.Integer)
    long = db.Column(db.Integer)

    def __repr__(self):
        return f"User('{self.id}', '{self.x}', '{self.y}')"
