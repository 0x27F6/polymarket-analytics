import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv('../polymarket_analytics/exports/mart_power_law_volume.csv')
df = df[df['volume_rank'] <= 1000].sort_values('volume_rank')

highlights = [1, 100, 500, 1000]
highlight_data = df[df['volume_rank'].isin(highlights)][['volume_rank', 'cumulative_vol_pct']].set_index('volume_rank')

plt.rcParams['font.family'] = 'DejaVu Sans'
fig, ax = plt.subplots(figsize=(10, 6))

ax.plot(df[df['volume_rank'] <= 100]['volume_rank'],
        df[df['volume_rank'] <= 100]['cumulative_vol_pct'],
        color='#4a90c4', linewidth=2)
ax.plot(df[df['volume_rank'] > 100]['volume_rank'],
        df[df['volume_rank'] > 100]['cumulative_vol_pct'],
        color='#4a90c4', linewidth=2, linestyle='--', alpha=0.6)

offsets = {
    1:    (40, 2),
    100:  (50, -2),
    500:  (50, -2),
    1000: (-120, -3),
}

for rank in highlights:
    if rank not in highlight_data.index:
        continue
    pct = round(highlight_data.loc[rank, 'cumulative_vol_pct'], 2)
    dx, dy = offsets[rank]
    ax.scatter(rank, pct, color='#c0392b', zorder=5, s=40)
    ax.annotate(f'Rank {rank}: {pct}%',
                xy=(rank, pct),
                xytext=(rank + dx, pct + dy),
                fontsize=8.5,
                color='#c0392b',
                arrowprops=dict(arrowstyle='->', color='#c0392b', lw=0.8))

ax.set_title("Polymarket's Volume Power Law", fontsize=13)
ax.set_xlabel('Market Rank (Ordered by Volume)')
ax.set_ylabel('% of Total Cumulative Volume ($28.08B)')
ax.set_xlim(0, 1050)
ax.set_ylim(0, 50)

ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
ax.spines['left'].set_color('#e0e0e0')
ax.spines['bottom'].set_color('#e0e0e0')
ax.yaxis.grid(True, color='#f0f0f0', linewidth=0.8)
ax.set_axisbelow(True)
ax.tick_params(colors='#404040')

total_markets = df['total_markets'].iloc[0]
ax.text(0.02, 0.95, f'Total markets: {total_markets:,}',
        transform=ax.transAxes, fontsize=9, color='#404040', va='top')

ax.annotate('Data source: dune.com', xy=(0.01, 0.01),
            xycoords='figure fraction', fontsize=8, color='gray')

plt.tight_layout()
plt.savefig('../polymarket_analytics/assets/charts/power_law_chart.png', dpi=150)
plt.show()