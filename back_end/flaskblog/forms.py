from flask_wtf import FlaskForm
from wtforms import StringField, IntegerField, TextAreaField
from wtforms.validators import DataRequired

class ChatForm(FlaskForm):
  content = TextAreaField('Content', validators=[DataRequired()])


