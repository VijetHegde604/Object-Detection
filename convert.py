from pathlib import Path
from tkinter import image_names

import numpy as np
import pandas as pd
from PIL import Image

data = pd.read_csv("Annotation/Annotation_For3Class.csv")

print(data.head())

labels_dir = Path(my_dataset / labels)
labels_dir.mkdir(exist_ok=True)

class_map = {"ADVISORY SPEED MPH": 0}

for _,row in data.iterrows():
    image_name = row["ImagePath"]
