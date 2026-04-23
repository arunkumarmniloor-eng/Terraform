from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def home():
        return jsonify({
                    "message": "Flask backend is running 🚀"
                        })

        @app.route('/api/data')
        def data():
                return jsonify({
                            "name": "Arun",
                                    "role": "DevOps Engineer",
                                            "project": "Flask + Express Deployment"
                                                })

                if __name__ == '__main__':
                        app.run(host='0.0.0.0', port=5000)
