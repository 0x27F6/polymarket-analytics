import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdates

df = pd.read_csv('../polymarket_analytics/exports/mart_market_creation.csv')
df['month'] = pd.to_datetime(df['month'])

# Remap categories
def remap(cat):
    if cat in ['Politics', 'Sports', 'Crypto']:
        return cat
    return 'Other'

df['category_grouped'] = df['category'].apply(remap)
df_grouped = df.groupby(['month', 'category_grouped'])['markets_created'].sum().unstack(fill_value=0)
df_grouped = df_grouped[df_grouped.index >= pd.Timestamp('2024-05-01')]

colors = {
    'Politics': '#4a90c4',
    'Sports':   '#5aab78',
    'Crypto':   '#e6a832',
    'Other':    '#b0aaa8',
}

cat_order = ['Politics', 'Sports', 'Crypto', 'Other']

plt.rcParams['font.family'] = 'DejaVu Sans'
fig, ax = plt.subplots(figsize=(12, 6))

bottom = pd.Series(0, index=df_grouped.index)
for cat in cat_order:
    if cat in df_grouped.columns:
        ax.bar(df_grouped.index, df_grouped[cat], bottom=bottom,
               label=cat, color=colors[cat], width=20)
        bottom += df_grouped[cat]

ax.set_title('Polymarket: Monthly Market Creation by Category', fontsize=13)
ax.set_xlabel('Month')
ax.set_ylabel('Markets Created')
ax.legend(loc='upper left', fontsize=9)
ax.tick_params(axis='x', rotation=45, colors='#404040')
ax.tick_params(axis='y', colors='#404040')
ax.set_xlim(pd.Timestamp('2024-04-15'), df_grouped.index.max() + pd.Timedelta(days=20))

ax.xaxis.set_major_formatter(mdates.DateFormatter('%b %Y'))
ax.xaxis.set_major_locator(mdates.MonthLocator(interval=2))

ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
ax.spines['left'].set_color('#e0e0e0')
ax.spines['bottom'].set_color('#e0e0e0')
ax.yaxis.grid(True, color='#f0f0f0', linewidth=0.8)
ax.set_axisbelow(True)

ax.annotate('Data source: dune.com', xy=(0.01, 0.01), xycoords='figure fraction',
            fontsize=8, color='gray')

plt.tight_layout()
plt.savefig('../polymarket_analytics/assets/charts/market_creation_chart', dpi=150)
plt.show()