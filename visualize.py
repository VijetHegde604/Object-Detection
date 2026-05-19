import cv2
import pandas as pd

df = pd.read_csv("Annotation/Annotation_For3Class.csv")

row = df.iloc[0]

image_path = f"images/{row['ImagePath']}"

img = cv2.imread(image_path)

x0 = int(row["X0"])
y0 = int(row["Y0"])
x1 = int(row["X1"])
y1 = int(row["Y1"])

cv2.rectangle(img, (x0, y0), (x1, y1), (0, 255, 0), 2)

cv2.putText(
    img, row["Class"], (x0, y0 - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2
)

cv2.imshow("Annotation", img)

cv2.waitKey(0)
cv2.destroyAllWindows()
