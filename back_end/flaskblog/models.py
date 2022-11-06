from flaskblog import db


  

class Grid(db.Model):
  id = db.Column(db.Integer, primary_key=True)#
  inhabitants = db.relationship('Inhabitants', backref='grid')
  x = db.Column(db.Integer)
  y = db.Column(db.Integer)
  size = db.Column(db.Integer)
  chat_history = db.relationship('Chat', backref='grid')

  def __repr__(self):
    return f"User('{self.id}', '{self.x}', '{self.y}')"

class Chat(db.Model):
  id = db.Column(db.Integer, primary_key = True)
  grid_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
  content = db.Column(db.Text, nullable=False)

  def __repr__(self):
    return f"Post('{self.content}')"

class Inhabitants (db.Model):
  grid_id = db.Column(db.Integer, db.ForeignKey('grid.id'), primary_key = True)
  user_id = db.Column(db.Integer, db.ForeignKey('user.id'))

  def __repr__(self):
    return f"Post('{self.grid_id}')"