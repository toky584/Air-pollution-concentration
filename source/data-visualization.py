plt.figure(figsize=(10, 6))
custom_palette = sns.color_palette(["#073344FF", "#0B7C9AFF"])

# Create a rectangle for the WHO PM2.5 range
for _, row in dwho.iterrows():
    plt.fill_between(
        [dp['date'].min() - timedelta(days=10), dp['date'].max() + timedelta(days=10)],
        row['pm25_low'], row['pm25_high'],
        color=sns.color_palette("OrRd", len(dwho))[_], alpha=0.5, label=row['risk']
    )
# Plot PM2.5 data points
sns.scatterplot(
    data=dp, x='date', y='pm2_5', hue='site_name', palette=custom_palette, s=50
)

# Customizing the plot
plt.xlim([dp['date'].min() - timedelta(days=10), dp['date'].max() + timedelta(days=10)])
plt.ylim([0, max(dp['pm2_5']) * 1.05])
plt.xlabel('')
plt.ylabel('PM2.5 concentration')
plt.title('PM2.5 Measurements in Kampala')
plt.legend(title='Location')
