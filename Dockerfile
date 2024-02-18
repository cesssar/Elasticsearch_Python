FROM python

WORKDIR /app

COPY robo.py /app/

COPY requirements.txt /app/

RUN pip install -r requirements.txt

CMD ["python","robo.py"]