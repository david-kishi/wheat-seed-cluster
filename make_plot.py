import matplotlib.pyplot as plt
import pandas as pd

actual = "data/actual.csv"
output = "data/output.csv"
centroids = "data/centroids.csv"

df_actual = pd.read_csv(actual)
df_output = pd.read_csv(output)
df_centroids = pd.read_csv(centroids)

# Scatterplot for actual
plt.scatter(df_actual.a[0:60], df_actual.b[0:60], marker="o")
plt.scatter(df_actual.a[60:120], df_actual.b[60:120], marker="x")
plt.scatter(df_actual.a[120:180], df_actual.b[120:180], marker="+")
plt.xlabel("A")
plt.ylabel("B")
plt.savefig("plots/actual.png")
plt.close()

# Scatterplot for 1-pass of k-means clustering
class_a_x = []
class_a_y = []
class_b_x = []
class_b_y = []
class_c_x = []
class_c_y = []
for i in range(len(df_output['class'])):
  if df_output['class'][i] == 1.0:
    class_a_x.append(df_output.a[i])
    class_a_y.append(df_output.b[i])
  elif df_output['class'][i] == 2.0:
    class_b_x.append(df_output.a[i])
    class_b_y.append(df_output.b[i])
  else:
    class_c_x.append(df_output.a[i])
    class_c_y.append(df_output.b[i])

plt.scatter(class_a_x, class_a_y, marker="o")
plt.scatter(class_b_x, class_b_y, marker="x")
plt.scatter(class_c_x, class_c_y, marker="+")
plt.scatter(df_centroids.x[0], df_centroids.y[0], marker="H", s=100)
plt.scatter(df_centroids.x[1], df_centroids.y[1], marker="H", s=100)
plt.scatter(df_centroids.x[2], df_centroids.y[2], marker="H", s=100)
plt.xlabel("A")
plt.ylabel("B")
plt.savefig("plots/output.png")
plt.close()
