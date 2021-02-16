with open('file.txt', 'r') as file:
  data = file.read().replace('\n', '')
  n = 16
  splt = [data[i:i+n] for i in range(0, len(data), n)]
  for i in splt:
    print(i)
    
#отдельная благодарность за помощь Саше trall Изису
