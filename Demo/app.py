import pandas as pd
import plotly.express as px
import streamlit as st

st.title("Sales explorer")
df = pd.DataFrame({"region": ["East", "East", "West", "West"],
                   "month": ["Jan", "Feb", "Jan", "Feb"],
                   "sales": [120, 160, 90, 140]})
region = st.selectbox("Region", sorted(df["region"].unique()))
view = df[df["region"] == region]

view["month_region"] = view["month"] + " - " + view["region"]

# 3. Create a static color map so colors stay consistent when filtering
color_mapping = {
    "Jan - East": "#1f77b4",  # Dark Blue
    "Feb - East": "#aec7e8",  # Light Blue
    "Jan - West": "#ff7f0e",  # Dark Orange
    "Feb - West": "#ffbb78"   # Light Orange
}


st.metric("Total sales", f"${view['sales'].sum():,.0f}")
st.plotly_chart(px.bar(view, x="month", y="sales", color = "month_region",
                       color_discrete_map=color_mapping),
                use_container_width=True)
st.dataframe(view)