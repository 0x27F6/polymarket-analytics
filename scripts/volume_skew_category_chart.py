import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv('../polymarket_analytics/exports/mart_market_duration.csv')
df = df.sort_values('mean_to_median_volume_ratio', ascending=True)

colors_map = {
    'Politics': '#4a90c4',
    'Crypto':   '#e6a832',
}

colors = [colors_map.get(cat, '#b0aaa8') for cat in df['category']]

plt.rcParams['font.family'] = 'DejaVu Sans'
fig, ax = plt.subplots(figsize=(10, 6))

bars = ax.barh(df['category'], df['mean_to_median_volume_ratio'], color=colors)

for bar, val in zip(bars, df['mean_to_median_volume_ratio']):
    ax.text(bar.get_width() + 0.1, bar.get_y() + bar.get_height() / 2,
            f'{val:.1f}x', va='center', fontsize=9, color='#404040')

ax.set_title('Volume Skew by Category: Mean vs. Median Market Volume', fontsize=13)
ax.set_xlabel('Mean / Median Volume Ratio')
ax.set_xlim(0, df['mean_to_median_volume_ratio'].max() + 2)

ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
ax.spines['left'].set_color('#e0e0e0')
ax.spines['bottom'].set_color('#e0e0e0')
ax.xaxis.grid(True, color='#f0f0f0', linewidth=0.8)
ax.set_axisbelow(True)
ax.tick_params(colors='#404040')

ax.text(0.98, 0.05, 'Higher ratio = more volume concentrated\nin a small number of markets',
        transform=ax.transAxes, fontsize=8, color='gray', ha='right', va='bottom')

ax.annotate('Data source: dune.com', xy=(0.01, 0.01), xycoords='figure fraction',
            fontsize=8, color='gray')

plt.tight_layout()
plt.savefig('../polymarket_analytics/assets/charts/volume_skew_chart.png', dpi=150)
plt.show()