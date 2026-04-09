import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

df = pd.read_csv('../polymarket_analytics/exports/mart_power_law_volume.csv')

# Sort smallest to largest (reverse rank order)
df = df.sort_values('volume_rank', ascending=False)

total_volume = df['total_volume'].iloc[0]
total_markets = df['total_markets'].iloc[0]

# Recalculate cumulative volume from smallest to largest
df['cumulative_vol_pct_lorenz'] = (df['total_volume_usdc'].cumsum() / total_volume * 100)
df['pct_of_markets'] = (df['volume_rank'].rank(ascending=False) / total_markets * 100)

plt.rcParams['font.family'] = 'DejaVu Sans'
fig, ax = plt.subplots(figsize=(10, 8))

ax.plot([0, 100], [0, 100], color='#b0aaa8', linewidth=1.5,
        linestyle='--', label='Perfect equality')

ax.plot(df['pct_of_markets'], df['cumulative_vol_pct_lorenz'],
        color='#4a90c4', linewidth=2, label='Polymarket volume distribution')

ax.fill_between(df['pct_of_markets'], df['cumulative_vol_pct_lorenz'],
                df['pct_of_markets'], alpha=0.07, color='#4a90c4')

# Interpolate exact y values at annotation points
x_points = [50, 90]
y_points = [np.interp(x, df['pct_of_markets'], df['cumulative_vol_pct_lorenz']) for x in x_points]

labels = [
    'Bottom 50% = {:.1f}% of volume',
    'Bottom 90% =\n{:.1f}% of volume',
]

text_offsets = [(-2, -3), (2, -3)]

for x, y, label, (dx, dy) in zip(x_points, y_points, labels, text_offsets):
    ax.scatter(x, y, color='#c0392b', zorder=5, s=40)
    ax.text(x + dx, y + dy, label.format(y),
            fontsize=8, color='#c0392b', va='bottom')

ax.set_title("Polymarket Volume Distribution: Lorenz Curve", fontsize=13)
ax.set_xlabel('Cumulative % of Markets (smallest to largest)')
ax.set_ylabel('Cumulative % of Total Volume')
ax.legend(fontsize=9, loc='upper left')
ax.set_xlim(0, 100)
ax.set_ylim(0, 100)

ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
ax.spines['left'].set_color('#e0e0e0')
ax.spines['bottom'].set_color('#e0e0e0')
ax.yaxis.grid(True, color='#f0f0f0', linewidth=0.8)
ax.xaxis.grid(True, color='#f0f0f0', linewidth=0.8)
ax.set_axisbelow(True)
ax.tick_params(colors='#404040')

ax.annotate('Data source: dune.com', xy=(0.01, 0.01),
            xycoords='figure fraction', fontsize=8, color='gray')

plt.tight_layout()
plt.savefig('../polymarket_analytics/assets/charts/lorenz_curve.png', dpi=150)
plt.show()