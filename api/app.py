from pathlib import Path
import sys
import io
import time

import torch
from PIL import Image, ImageOps
from flask import Flask, request, jsonify
from flask_cors import CORS


# ================================================================
# PATHS
# ================================================================

BASE_DIR = Path(__file__).resolve().parent
YOLO_DIR = BASE_DIR / "yolov5"
MODEL_PATH = BASE_DIR / "weights" / "best.pt"


# ================================================================
# YOLO IMPORT
# ================================================================

sys.path.insert(0, str(YOLO_DIR))

from models.common import AutoShape


# ================================================================
# FLASK
# ================================================================

app = Flask(__name__)
CORS(app)

app.config["MAX_CONTENT_LENGTH"] = 10 * 1024 * 1024


# ================================================================
# LOAD MODEL
# ================================================================

print("Loading YOLOv5 model...")

model = torch.hub.load(
    str(YOLO_DIR),
    "custom",
    path=str(MODEL_PATH),
    source="local",
)

if not isinstance(model, AutoShape):
    print("Wrapping model with AutoShape...")
    model = AutoShape(model)

model.eval()

print("Model loaded successfully!")
print("Classes:", model.names)


# ================================================================
# HEALTH CHECK
# ================================================================

@app.route("/health", methods=["GET"])
def health():
    return jsonify(
        {
            "ok": True,
            "status": "CalaSense YOLO API is running",
            "classes": model.names,
        }
    )


# ================================================================
# PREDICTION
# ================================================================

@app.route("/predict", methods=["POST"])
def predict():

    # ------------------------------------------------------------
    # CHECK IMAGE
    # ------------------------------------------------------------

    if "image" not in request.files:
        return jsonify(
            {
                "ok": False,
                "error": "No image provided",
            }
        ), 400

    file = request.files["image"]

    if file.filename == "":
        return jsonify(
            {
                "ok": False,
                "error": "No image selected",
            }
        ), 400


    # ------------------------------------------------------------
    # READ IMAGE
    # ------------------------------------------------------------

    try:
        image_bytes = file.read()

        image = Image.open(
            io.BytesIO(image_bytes)
        )

        # ========================================================
        # IMPORTANT:
        # APPLY EXIF ORIENTATION BEFORE YOLO
        # ========================================================

        image = ImageOps.exif_transpose(image)

        # Convert after orientation has been corrected
        image = image.convert("RGB")

    except Exception as error:
        return jsonify(
            {
                "ok": False,
                "error": f"Invalid image: {str(error)}",
            }
        ), 400


    # ------------------------------------------------------------
    # IMAGE SIZE AFTER EXIF CORRECTION
    # ------------------------------------------------------------

    original_width = image.width
    original_height = image.height

    print(
        f"Corrected image size: "
        f"{original_width} x {original_height}"
    )


    # ------------------------------------------------------------
    # RUN YOLO
    # ------------------------------------------------------------

    try:
        start_time = time.time()

        results = model(
            image,
            size=640,
        )

        dataframe = results.pandas().xyxy[0]


        # --------------------------------------------------------
        # CONVERT YOLO RESULTS
        # --------------------------------------------------------

        detections = []

        for _, row in dataframe.iterrows():

            detection = {
                "class_id": int(row["class"]),

                "class_name": str(
                    row["name"]
                ),

                "confidence": float(
                    row["confidence"]
                ),

                "bbox": [
                    float(row["xmin"]),
                    float(row["ymin"]),
                    float(row["xmax"]),
                    float(row["ymax"]),
                ],
            }

            detections.append(
                detection
            )


        # --------------------------------------------------------
        # BEST DETECTION
        # --------------------------------------------------------

        best_detection = None

        if detections:
            best_detection = max(
                detections,
                key=lambda detection:
                    detection["confidence"],
            )


        # --------------------------------------------------------
        # INFERENCE TIME
        # --------------------------------------------------------

        inference_ms = int(
            (time.time() - start_time) * 1000
        )


        # --------------------------------------------------------
        # RESPONSE
        # --------------------------------------------------------

        return jsonify(
            {
                "ok": True,

                "best_detection":
                    best_detection,

                "detections":
                    detections,

                "meta": {
                    "inference_ms":
                        inference_ms,

                    # IMPORTANT:
                    # dimensions now match
                    # the EXIF-corrected image
                    "width":
                        original_width,

                    "height":
                        original_height,
                },
            }
        )


    except Exception as error:

        print(
            "Prediction error:",
            error,
        )

        return jsonify(
            {
                "ok": False,
                "error": str(error),
            }
        ), 500


# ================================================================
# START SERVER
# ================================================================

if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=5000,
        debug=True,
        use_reloader=False,
    )