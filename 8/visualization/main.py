import csv

with open('../clusterized.csv', 'r') as file:
    csv_reader = csv.DictReader(file)
    colors = [row for row in csv_reader]

html = """
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Visualization</title>
</head>
<body>
"""

sorted_by_cluster_colors = sorted(colors, key=lambda x: x['centroid_id'])

clusters = []
for color in sorted_by_cluster_colors:

    cluster = color['centroid_id']

    if cluster not in clusters:
        html += f'<h2>Cluster {cluster}</h>'
        clusters.append(cluster)

    color_attribute = f'rgb({color["r"]}, {color["g"]}, {color["b"]})'
    html += f'<div style="width: 300px; background: {color_attribute}">{"r: " + color["r"] + " g: " + color["g"] + " b: " + color["b"]}</div>'

html += """
</body>
</html>
"""

with open('visualization.html', 'w') as file:
    file.write(html)
