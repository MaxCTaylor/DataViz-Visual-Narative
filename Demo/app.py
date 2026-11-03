from dash import Dash, dcc, html, Input, Output
import plotly.express as px

app = Dash(__name__)
app.layout = html.Div([
    dcc.Slider(1, 5, 1, id="minimum"),
    dcc.Graph(id="chart"),
])

@app.callback(Output("chart", "figure"), Input("minimum", "value"))
def update_chart(minimum):
    df = px.data.iris()
    return px.scatter(df[df.sepal_length >= minimum],
                      x="sepal_width", y="sepal_length",
                      color="species")

if __name__ == "__main__":
    app.run(debug=True)