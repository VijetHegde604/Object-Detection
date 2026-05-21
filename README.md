# Object Detection
## TL;DR
- **Task:** 3-class object detection
- **Model family:** YOLOv8n (Tried YOLOv8s and YOLOv8m but couldnt train due to low VRAM)
- **Best run so far:** `runs/detect/train-3`
- **Best metric:** **mAP50-95 = 0.85836** (epoch 54)
- **Classes:**
  - `ADVISORY_SPEED_MPH`
  - `DIRECTIONAL_ARROW_AUXILIARY`
  - `DO_NOT_ENTER`

## Training workflow used
This is the general workflow followed in the notebook:

1. **Start with pretrained YOLOv8 weights.**
2. **Train baseline run** (`runs/detect/train`) 
3. **Iterate training length and settings** (e.g., 20 → 50 → 60 epochs).
4. **Compare runs using `results.csv`** Took help of AI here 
5. **Pick the best weights**

- `train-3` gave the strongest **overall localization + classification quality** (mAP50-95).
- `train-2` had decent precision/recall but didn’t convert into the best mAP50-95.
- More epochs helped in this case, but the gain was not perfectly linear every run.

## Looked Good
- High Precision and recall near 0.95 
- loss decreased over time
- validation set showed pretty accurate predictions 
- model worked nicely on the Unseen Video


## Should be improved 
- Detects ADVISORY_SPEED_LIMIT_MPH and DO_NOT_ENTER nicely but DIRECTIONAL_ARROW_AUXILIARY class has less detections 
- Many false positives for **ADVISORY_SPEED_LIMIT**
- Missed some detctions in crowded images and some false detections of similar looking objects
  - Example: A school zone sign detected as a Speed limit sign


## Possible Causes
-  Less image size caused the model to not recognize the small arrow signs during training
  - Tried increasing the image size but didn't had enough ram to get that into memory 
  - Lack of GPU for training (Found that CPU training is not as effective as GPU * ChatGPT)


  **Tried my best in two days** 
  **Looking forward to your suggestions**
