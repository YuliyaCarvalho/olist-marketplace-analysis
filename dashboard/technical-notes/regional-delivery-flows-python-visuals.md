# Regional Delivery Flows — Python Visuals

This document describes the Python-based heatmaps used on the **Regional Delivery Flows** page of the Olist dashboard. It complements the business-facing page documentation by capturing the technical implementation, plotting logic, and formatting choices behind the four route-level visuals.

---

## 1. Purpose of this file

The **Regional Delivery Flows** page uses Python visuals in Power BI, rather than native visuals, because the analysis requires a route-level heatmap layout with:

- seller region on rows
- customer region on columns
- annotated cell values
- subgroup-specific color normalization
- centered diverging color scales for easier route comparison

These design requirements are easier to control with Python, than with standard Power BI visuals (such as Matrix).

---

## 2. Visuals covered

This file covers four Python heatmaps:

1. **Regional Delivery Performance: Average Delivery Time (Days) — Single-Seller Orders**
2. **Regional Delivery Performance: Average Delivery Time (Days) — Multi-Seller Orders**
3. **Regional Delivery Performance: Late Delivery Rate (%) — Single-Seller Orders**
4. **Regional Delivery Performance: Late Delivery Rate (%) — Multi-Seller Orders**

---

## 3. Common implementation logic

All four visuals follow the same overall pattern:

- a route matrix is built using Seller Region as rows and Customer Region as columns
- the matrix is rendered as a heatmap with cell annotations
- a custom diverging color scale is used
- the color midpoint is centered on the subgroup mean
- the colorbar is labeled using subgroup-specific low / midpoint / high reference values

---

### 3.1 Row / column structure

All heatmaps are built on a **Seller Region × Customer Region** matrix:

- **Rows:** `Seller Region`
- **Columns:** `Customer Region`

This structure allows each cell to represent a distinct regional delivery corridor, rather than a one-dimensional geography summary.

---

### 3.2 Color scaling approach

Each heatmap uses:

- `vmin` = 10th percentile of the matrix values
- `vmax` = 90th percentile of the matrix values
- `vcenter` = mean of the matrix values

This helps reduce the visual dominance of extreme outliers while keeping the color scale interpretable.

---

### 3.3 Colormap design

A custom diverging colormap is used:

- green for relatively better-performing routes
- white for near-average routes
- red for relatively worse-performing routes

```python
colors = ['#7FA03B', 'white', '#E5543A']
cmap = LinearSegmentedColormap.from_list("custom_heatmap", colors)
```

---

### 3.4 Normalization method

The visuals use `TwoSlopeNorm` so the color transition is centered around the subgroup mean:

```python
norm = TwoSlopeNorm(vmin=vmin, vcenter=vcenter, vmax=vmax)
```

This is important because the goal is not only to show absolute values, but to make it visually clear which routes perform below or above the subgroup’s central tendency.

---

### 3.5 Annotation logic

All cells are annotated directly with their numeric value:

- average delivery time heatmaps use `fmt=".1f"`
- late delivery rate heatmaps use `fmt=".1%"`

This preserves exact interpretability and avoids relying on color alone.

### 3.6 Styling choices

The Python visuals use consistent formatting choices:

- `Segoe UI` font for axis titles, ticks, and annotations
- larger font sizes for readability inside Power BI
- rotated x-axis tick labels for route readability
- compact colorbars with subgroup-specific tick labels
- a horizontal marker line at the color midpoint in the colorbar

---

## 4. Average Delivery Time heatmaps

### 4.1 Analytical purpose

These visuals show **average end-to-end delivery duration** across seller-region → customer-region routes.

They are intended to answer:

- which delivery corridors are structurally slower?
- whether route-level speed patterns differ between single-seller and multi-seller orders

---

### 4.2 Input matrix construction

```python
heatmap_data = dataset.pivot(
    index='Seller Region',
    columns='Customer Region',
    values='Avg Delivery Time (Days)'
)
```

---

### 4.3 Plotting code template

```python
import matplotlib.pyplot as plt
import seaborn as sns
from matplotlib.colors import LinearSegmentedColormap, TwoSlopeNorm
import numpy as np

heatmap_data = dataset.pivot(
    index='Seller Region',
    columns='Customer Region',
    values='Avg Delivery Time (Days)'
)

vmin = np.nanpercentile(heatmap_data.values, 10)
vmax = np.nanpercentile(heatmap_data.values, 90)
vcenter = np.nanmean(heatmap_data.values)

colors = ['#7FA03B', 'white', '#E5543A']
cmap = LinearSegmentedColormap.from_list("custom_heatmap", colors)

norm = TwoSlopeNorm(vmin=vmin, vcenter=vcenter, vmax=vmax)

plt.figure(figsize=(7,5))

ax = sns.heatmap(
    heatmap_data,
    cmap=cmap,
    annot=True,
    fmt=".1f",
    linewidths=.5,
    norm=norm,
    cbar_kws={
        'shrink': 0.6,
        'pad': 0.02}
)

axis_title_font = {'fontname': 'Segoe UI', 'fontsize': 16, 'color': '#333333'}
tick_font = {'fontname': 'Segoe UI', 'fontsize': 15, 'color': '#333333'}

ax.set_xlabel("Customer Region", **axis_title_font)
ax.set_ylabel("Seller Region", **axis_title_font)

ax.set_xticklabels(ax.get_xticklabels(), **tick_font, rotation=45, ha='right')
ax.set_yticklabels(ax.get_yticklabels(), **tick_font, rotation=0)

for t in ax.texts:
    t.set_fontname('Segoe UI')
    t.set_fontsize(15)
    t.set_color('black')

cbar = ax.collections[0].colorbar
cbar.ax.tick_params(labelsize=12)

cbar.set_ticks([vmin, vcenter, vmax])
cbar.set_ticklabels([f"{vmin:.1f}", f"{vcenter:.1f}", f"{vmax:.1f}"])

cbar.ax.hlines(
    y=vcenter,
    xmin=0,
    xmax=1,
    color='black',
    linewidth=1)

plt.tight_layout()
plt.show()
```
---

### 4.4 Notes

- `pivot()` is used because each route cell should have one value in the visual input
- color interpretation is relative to the subgroup distribution, not to a global fixed benchmark
- exact cell labels are important because route values can differ meaningfully even when colors appear similar

---

## 5. Late Delivery Rate heatmaps

### 5.1 Analytical purpose

These visuals show **late delivery risk** across seller-region → customer-region routes.

They are intended to answer:

- which delivery corridors are least reliable?
- whether speed and reliability highlight the same routes
- whether reliability patterns differ between single-seller and multi-seller flows

---

### 5.2 Input matrix construction

```python
heatmap_data = dataset.pivot_table(
    index='Seller Region',
    columns='Customer Region',
    values='Late Delivery Rate %',
    aggfunc='mean'
)
```

---

### 5.3 Plotting code template

```python
import matplotlib.pyplot as plt
import seaborn as sns
from matplotlib.colors import LinearSegmentedColormap, TwoSlopeNorm
import numpy as np

heatmap_data = dataset.pivot_table(
    index='Seller Region',
    columns='Customer Region',
    values='Late Delivery Rate %',
    aggfunc='mean')

vmin = np.nanpercentile(heatmap_data.values, 10)
vmax = np.nanpercentile(heatmap_data.values, 90)
vcenter = np.nanmean(heatmap_data.values)

colors = ['#7FA03B', 'white', '#E5543A']
cmap = LinearSegmentedColormap.from_list("custom_heatmap", colors)

norm = TwoSlopeNorm(vmin=vmin, vcenter=vcenter, vmax=vmax)

plt.figure(figsize=(7,5))

ax = sns.heatmap(
    heatmap_data,
    cmap=cmap,
    annot=True,
    fmt=".1%",
    linewidths=.5,
    norm=norm,
    cbar_kws={
        'shrink': 0.6,
        'pad': 0.02}
)

axis_title_font = {'fontname': 'Segoe UI', 'fontsize': 16, 'color': '#333333'}
tick_font = {'fontname': 'Segoe UI', 'fontsize': 15, 'color': '#333333'}

ax.set_xlabel("Customer Region", **axis_title_font)
ax.set_ylabel("Seller Region", **axis_title_font)

ax.set_xticklabels(ax.get_xticklabels(), **tick_font, rotation=45, ha='right')
ax.set_yticklabels(ax.get_yticklabels(), **tick_font, rotation=0)

for t in ax.texts:
    t.set_fontname('Segoe UI')
    t.set_fontsize(15)
    t.set_color('black')

cbar = ax.collections[0].colorbar
cbar.ax.tick_params(labelsize=12)

cbar.set_ticks([vmin, vcenter, vmax])
cbar.set_ticklabels([f"{vmin:.1%}", f"{vcenter:.1%}", f"{vmax:.1%}"])

cbar.ax.hlines(
    y=vcenter,
    xmin=0,
    xmax=1,
    color='black',
    linewidth=1.5)

plt.tight_layout()
plt.show()
```

---

### 5.4 Notes

- `pivot_table(..., aggfunc='mean')` is used for the late-rate matrix  
- the displayed values are percentages (not raw counts)  
- route-level percentage values can be more volatile in sparse multi-seller subgroups, so annotations are especially important  

---

## 6. Why Python was used instead of native Power BI heatmaps

These visuals were implemented in Python because the page required:

- route matrices with full control over row–column positioning
- cell-level annotations
- subgroup-specific diverging normalization
- more flexible handling of sparse matrices
- custom colorbar formatting centered on the subgroup mean

Native Power BI visuals (e.g. Matrix) are less flexible for this type of heatmap-driven route diagnosis.

---

## 7. Interpretation caveats

These Python heatmaps should be interpreted with the following constraints in mind:

> - color intensity is relative to the subgroup’s own distribution, not to a universal benchmark shared across all four visuals  
> - multi-seller matrices are much sparser and should be interpreted more cautiously  
> - missing cells usually indicate absent or insufficient route coverage rather than neutral performance  
> - the heatmaps are designed for structural comparison, not for causal attribution  
> - route-level comparisons are strongest when read together across both speed and reliability visuals  

---

