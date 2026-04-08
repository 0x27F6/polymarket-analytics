import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdates

df = pd.read_csv('../polymarket_analytics/exports/mart_market_creation.csv')
df['month'] = pd.to_datetime(df['month'])

top_cats = ['Politics', 'Sports', 'Crypto']
df_filtered = df[df['category'].isin(top_cats)]
df_pivot = df_filtered.groupby(['month', 'category'])['total_volume'].sum().unstack(fill_value=0)
df_pivot = df_pivot[df_pivot.index >= pd.Timestamp('2024-05-01')]

colors = {
    'Politics': '#4a90c4',
    'Sports':   '#5aab78',
    'Crypto':   '#e6a832',
}

plt.rcParams['font.family'] = 'DejaVu Sans'
fig, ax = plt.subplots(figsize=(12, 6))

for cat in top_cats:
    if cat in df_pivot.columns:
        ax.plot(df_pivot.index, df_pivot[cat] / 1e6, label=cat,
                color=colors[cat], linewidth=2)

# Annotations
annotations = [
    {
        'date': pd.Timestamp('2024-09-01'),
        'category': 'Sports',
        'label': 'NFL, US Open,\nEPL season open',
        'text_offset': (pd.Timestamp('2024-06-15'), 800),
    },
    {
        'date': pd.Timestamp('2024-11-01'),
        'category': 'Politics',
        'label': '2024 US\nPresidential Election',
        'text_offset': (pd.Timestamp('2024-08-01'), 1800),
    },
    {
        'date': pd.Timestamp('2025-07-01'),
        'category': 'Politics',
        'label': 'NYC Mayoral Election +\nGeopolitical surge',
        'text_offset': (pd.Timestamp('2025-03-01'), 1200),
    },
]

for a in annotations:
    if a['date'] in df_pivot.index and a['category'] in df_pivot.columns:
        y_val = df_pivot.loc[a['date'], a['category']] / 1e6
        ax.annotate(a['label'],
                    xy=(a['date'], y_val),
                    xytext=a['text_offset'],
                    fontsize=7.5,
                    color='#404040',
                    arrowprops=dict(arrowstyle='->', color='#888888', lw=1),
                    ha='center')

ax.set_title('Polymarket: Monthly Volume by Category (Top 3)', fontsize=13)
ax.set_xlabel('Month')
ax.set_ylabel('Volume (USD millions)')
ax.legend(loc='upper left', fontsize=9)
ax.tick_params(axis='x', rotation=45, colors='#404040')
ax.tick_params(axis='y', colors='#404040')
ax.xaxis.set_major_formatter(mdates.DateFormatter('%b %Y'))
ax.xaxis.set_major_locator(mdates.MonthLocator(interval=2))
ax.set_xlim(pd.Timestamp('2024-04-15'), df_pivot.index.max() + pd.Timedelta(days=20))

ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
ax.spines['left'].set_color('#e0e0e0')
ax.spines['bottom'].set_color('#e0e0e0')
ax.yaxis.grid(True, color='#f0f0f0', linewidth=0.8)
ax.set_axisbelow(True)

ax.annotate('Data source: dune.com', xy=(0.01, 0.01), xycoords='figure fraction',
            fontsize=8, color='gray')

plt.tight_layout()
plt.savefig('../polymarket_analytics/assets/charts/volume_by_category_chart.png', dpi=150)
plt.show()