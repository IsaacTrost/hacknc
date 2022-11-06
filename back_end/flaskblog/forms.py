from flask_wtf import FlaskForm
from wtforms import StringField, IntegerField
from wtforms.validators import DataRequired

class ChatForm(FlaskForm):
  content = StringField('Content', validators=[DataRequired()])


