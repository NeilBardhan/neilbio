from flask import Flask, render_template
import plotly.express as px
import plotly.io as pio

app = Flask(__name__)

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/resume")
def resume():
    return render_template("resume.html")

@app.route("/projects")
def projects():
    return render_template("projects.html")

@app.route("/projects/demo")
def project_demo():
    # Example: Interactive scatter plot
    df = px.data.iris()
    fig = px.scatter(df, x="sepal_width", y="sepal_length", color="species")

    # Convert to HTML div
    graph_html = pio.to_html(fig, full_html=False)
    return render_template("project_demo.html", graph_html=graph_html)

if __name__ == "__main__":
    app.run(debug=True)
