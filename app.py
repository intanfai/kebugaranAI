from flask import Flask, request, jsonify
import pickle
import pandas as pd
from datetime import datetime

app = Flask(__name__)

# Load model
model = pickle.load(open("model_kebugaran.pkl", "rb"))

# Tempat penyimpanan riwayat prediksi sementara (in-memory)
riwayat_prediksi = []

@app.route("/predict", methods=["POST"])
def predict():
    data = request.json
    df = pd.DataFrame([data])
    result = model.predict(df)[0]

    label = "Bugar" if result == 1 else "Kurang Bugar"

    # Buat saran otomatis
    saran = []
    if result == 0:
        if df["Olahraga (menit)"][0] < 15:
            saran.append("Tingkatkan olahraga.")
        if df["Jam Tidur"][0] < 6:
            saran.append("Tidur minimal 6 jam.")
        if df["Minum Air (liter)"][0] < 2:
            saran.append("Minum minimal 2 liter air.")
    else:
        saran.append("Pertahankan gaya hidup sehatmu!")

    # Tambahkan ke riwayat
    nilai = 90 if result == 1 else 60  # nilai untuk grafik
    riwayat_prediksi.append({
        "tanggal": datetime.now().strftime('%Y-%m-%d'),
        "hasil": label,
        "nilai": nilai
    })

    return jsonify({
        "prediksi": label,
        "saran": " ".join(saran)
    })

@app.route("/riwayat", methods=["GET"])
def get_riwayat():
    return jsonify(riwayat_prediksi)

if __name__ == "__main__":
    # Ubah host agar bisa diakses dari perangkat lain (misal HP Android)
    app.run(host="0.0.0.0", port=5000, debug=False)
