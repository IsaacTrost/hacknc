from back_end.app import db


  

class User(db.Model):
  id = db.Column(db.Integer, primary_key=True)
  x = db.Column(db.Integer)
  y = db.Column(db.Integer)


  def __repr__(self):
    return f"User('{self.id}', '{self.x}', '{self.y}')"

class Chatter(db.Model):
  id = db.Column(db.Integer, primary_key=True)
  grid_id = db.Column(db.Integer, unique=True) # should correlate to grid ID
  sender = db.Column(db.String(48), unique=True, nullable=False)
  message = db.Column(db.String(198), nullable=False)

  def __repr__(self):
    return f'Chatter({self.grid_id}, {self.sender}, {self.message})'