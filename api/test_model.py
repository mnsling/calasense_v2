from pathlib import Path
import torch

BASE_DIR = Path(__file__).resolve().parent
YOLO_DIR = BASE_DIR / "yolov5"
MODEL_PATH = BASE_DIR / "weights" / "best.pt"

print("YOLO folder:", YOLO_DIR)
print("Model path:", MODEL_PATH)
print("Loading model...")

model = torch.hub.load(
    str(YOLO_DIR),
    "custom",
    path=str(MODEL_PATH),
    source="local",
)

print("Model loaded successfully!")
print("Classes:")
print(model.names)