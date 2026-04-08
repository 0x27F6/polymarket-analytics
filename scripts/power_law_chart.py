import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv('../polymarket_analytics/exports/mart_power_law_volume.csv')
df = df[df['volume_rank'] <= 1000].sort_values('volume_rank')

# Pull actual values from data
highlights = [1, 100, 500, 1000]
highlight_data = df[df['volume_rank'].isin(highlights)][['volume_rank', 'cumulative_vol_pct']].set_index('volume_rank')

fig, ax = plt.subplots(figsize=(10, 6))

ax.plot(df[df['volume_rank'] <= 100]['volume_rank'], df[df['volume_rank'] <= 100]['cumulative_vol_pct'], color='steelblue', linewidth=2)
ax.plot(df[df['volume_rank'] > 100]['volume_rank'], df[df['volume_rank'] > 100]['cumulative_vol_pct'], color='steelblue', linewidth=2, linestyle='--', alpha=0.6)

# Annotation offsets per point
offsets = {
    1:    (30, 1),
    100:  (20, -1.5),
    500:  (20, -1.5),
    1000: (-100, -3),
}

for rank in highlights:
    pct = round(highlight_data.loc[rank, 'cumulative_vol_pct'], 2)
    dx, dy = offsets[rank]
    ax.scatter(rank, pct, color='red', zorder=5, s=40)
    ax.annotate(f'Rank {rank}: {pct}%', xy=(rank, pct), xytext=(rank + dx, pct + dy),
                fontsize=9, color='red')

ax.set_title("Polymarket's Volume Power Law", fontsize=13)
ax.set_xlabel('Market Rank (Ordered by Volume)')
ax.set_ylabel('% of Total Cumulative Volume ($28.08B)')
ax.set_xlim(0, 1050)
ax.set_ylim(0, 40)
ax.grid(axis='y', linestyle='--', alpha=0.4)
ax.annotate('Data source: dune.com', xy=(0.01, 0.01), xycoords='figure fraction', fontsize=8, color='gray')

total_markets = df['total_markets'].iloc[0]
ax.text(0.02, 0.95, f'Total markets: {total_markets:,}', transform=ax.transAxes, fontsize=9, color='#404040', va='top')

plt.tight_layout()
plt.savefig('/Users/indi/workspace/polymarket_analytics/exports/power_law_chart.png', dpi=150)
plt.show()