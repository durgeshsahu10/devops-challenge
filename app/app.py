from flask import Flask, request, jsonify
import datetime

app = Flask(__name__)

@app.route('/')
def home():
    # Get current time in UTC as a timezone-aware object
    current_time = datetime.datetime.now(datetime.timezone.utc).isoformat()
    visitor_ip = request.remote_addr
    return jsonify(timestamp=current_time, ip=visitor_ip)

if __name__ == '__main__':
    # Run the server on port 8080
    app.run(host='0.0.0.0', port=8080)
