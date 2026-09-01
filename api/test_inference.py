from pathlib import Path
import sys
import torch

BASE_DIR = Path(__file__).resolve().parent
YOLO_DIR = BASE_DIR / "yolov5"
MODEL_PATH = BASE_DIR / "weights" / "best.pt"
IMAGE_PATH = BASE_DIR / "test-detect.jpg"

# Allow imports from the local YOLOv5 folder
sys.path.insert(0, str(YOLO_DIR))

from models.common import AutoShape

print("Loading model...")

model = torch.hub.load(
    str(YOLO_DIR),
    "custom",
    path=str(MODEL_PATH),
    source="local",
)

print("Loaded model type:", type(model))

# Your checkpoint is loading as a raw DetectionModel.
# Wrap it so it can accept image paths / PIL / numpy images.
if not isinstance(model, AutoShape):
    print("Wrapping model with AutoShape...")
    model = AutoShape(model)

model.eval()

print("Model ready.")
print("Classes:", model.names)

print("\nRunning detection on:")
print(IMAGE_PATH)

results = model(str(IMAGE_PATH), size=640)

print("\nDetections:")

df = results.pandas().xyxy[0]

if df.empty:
    print("No detections found.")
else:
    print(df)

    print("\nSimplified results:")

    for _, row in df.iterrows():
        confidence = float(row["confidence"]) * 100
        disease = str(row["name"])

        print(f"{disease}: {confidence:.2f}%")