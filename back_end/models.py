from back_end import db


  

class User(db.Model):
  id = db.Column(db.Integer, primary_key=True)
  x = db.Column(db.Integer)
  y = db.Column(db.Integer)


  def __repr__(self):
    return f"User('{self.id}', '{self.x}', '{self.y}')"