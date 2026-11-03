import pandas as pd
import plotly.express as px
import streamlit as st

st.title("Sales explorer")
df = pd.DataFrame({"region": ["East", "East", "West", "West"],
                   "month": ["Jan", "Feb", "Jan", "Feb"],
                   "sales": [120, 160, 90, 140]})
dropdown_options = ["Both"] + sorted(df["region"].unique().tolist())
region = st.selectbox("Region", dropdown_options)
if region == "Both":
    view = df.copy()
    do_group = "group"
else:
    view = df[df["region"] == region]
    do_group = "relative"
view["month_region"] = view["month"] + " - " + view["region"]

# 3. Create a static color map so colors stay consistent when filtering
color_mapping = {
    "Jan - East": "#1f77b4",  # Dark Blue
    "Feb - East": "#aec7e8",  # Light Blue
    "Jan - West": "#ff7f0e",  # Dark Orange
    "Feb - West": "#ffbb78"   # Light Orange
}


st.metric("Total sales", f"${view['sales'].sum():,.0f}")
st.plotly_chart(px.bar(view, x="month", y="sales",
                       color = "month_region",
                       color_discrete_map=color_mapping,
                       barmode = do_group),
                use_container_width=True)
st.dataframe(view)


uploaded = st.file_uploader("Choose a CSV", type="csv")
if uploaded is not None:
    df = pd.read_csv(uploaded)
    st.write("Rows:", len(df))
    st.dataframe(df.head())
else:
    st.info("Upload a CSV to begin.")


