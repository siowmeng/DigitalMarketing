from statsmodels.stats.proportion import proportions_ztest
import pandas as pd
random = pd.read_csv('/Users/Jialiang/Downloads/DigitalMarketing/random.csv',header= None)
sorted = pd.read_csv('/Users/Jialiang/Downloads/DigitalMarketing/sorted.csv',header= None)

random.columns = ['srch','clicks','bookings','conversion']
sorted.columns = ['srch','clicks','bookings','conversion']

randomC = random[random.bookings==1]
sortedC = sorted[sorted.bookings==1]


rand = np.array([len(randomC), random.shape[0]])
nobs = np.array([len(sortedC), sorted.shape[0]])
proportions_ztest(count, nobs,0)
