import numpy as np
import pandas as pd

df = pd.read_csv("Annotation/Annotation_For3Class.csv")

print(df.head())

print("\nClasses")
print(df["Class"].unique())

print("\nNo. of Images")
print(df["ImagePath"].nunique())

print("\nTotal annotations:")
print(len(df))
