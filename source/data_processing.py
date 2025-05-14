# put WHO classification of PM2_5 health risks into table
dwho = {
    'risk': ['good','moderate','unhealthy for sensitive groups','unhealthy','very unhealthy'],
    'pm25_low': [0, 10, 25, 35, 55],
    'pm25_high': [10, 25, 35, 55,1000],
    'text': ['good air quality',
             'acceptable for short-term exposure but may affect sensitive groups over long-term exposure',
             'increased risk for vulnerable populations such as children, elderly, and people with pre-existing health conditions',
             'significant risk to the general population, especially with prolonged exposure',
             'severe health risk to the general public']
}
dwho = pd.DataFrame(dwho)

#	subset to Kampala, Uganda
dp_kampala = db.loc[db['city'] == "Kampala",['city', 'country', 'date', 'hour', 'site_id', 'site_latitude', 'site_longitude', 'pm2_5']]
dp_kampala['date'] = pd.to_datetime(dp_kampala['date'], format = '%Y-%m-%d')
dp_kampala['year'] = dp_kampala['date'].dt.strftime('%Y')
dp_kampala['month'] = dp_kampala['date'].dt.strftime('%m')

# name sites and merge
dp_sites = dp_kampala.loc[:,['city', 'site_id','site_latitude', 'site_longitude']].drop_duplicates()
dp_sites['site_name'] = ['site-' + str(i) for i in range(1,len(dp_sites)+1)]
dp_kampala = pd.merge(dp_kampala, dp_sites, on = ['city','site_id','site_latitude', 'site_longitude'])

# Select specific sites and rename them
dp = dp_kampala[dp_kampala['site_name'].isin(['site-4', 'site-9'])]
dp.loc[:,['site_name']] = dp['site_name'].replace({'site-4': 'Buwate', 'site-9': 'Kyebando'})
